import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { Diagram } from '../types'

const PANE = 'd2-pane'
// Own output folder per loaded module, so sessions running side by side
// never delete each other's pictures.
let out: string | undefined
async function outDir($: EngineInterface) {
  if (out === undefined) {
    const made = await $.process.run(['mktemp', '-d', '/tmp/d2-pane.XXXXXX'])
    if (made.exitCode !== 0) throw new Error(`mktemp: ${made.stderr.trim()}`)
    out = made.stdout.trim()
  }
  return out
}
// Change the tag when Diagram's fields change.
const diagram = atom({ plugin: 'd2-pane', key: 'diagram' } as const, null, {
  shape: 'diagram-2',
})
// Whether the dock asks for its widest (45% of the terminal) or its share.
const wide = atom({ plugin: 'd2-pane', key: 'wide' } as const, false, { shape: 'wide-1' })

// Every open carries the width, since each open sets it anew.
async function openPane($: EngineInterface) {
  const isWide = await read($, wide)
  // The surface caps columns at 45% of the terminal, so 255 means "widest".
  return $.ui.open({ id: PANE, title: 'Diagram', ...(isWide ? { columns: 255 } : {}) })
}

async function toggleWide($: EngineInterface) {
  await update($, wide, isWide => !isWide)
  await openPane($)
  return (await read($, wide)) ? 'wide' : 'narrow'
}

// The full view: the SVG in Loupe, detached so it outlives the call.
async function openExternal($: EngineInterface) {
  const now = await read($, diagram)
  if (!now?.svg) return 'no diagram to open yet'
  const run = await $.process.run(['setsid', '-f', 'loupe', now.svg])
  return run.exitCode === 0 ? `opened ${now.svg} in Loupe` : `loupe: ${run.stderr.trim()}`
}

const isD2 = (path: unknown): path is string =>
  typeof path === 'string' && path.endsWith('.d2')

// d2 -> svg (d2's own png export needs a Playwright download that 404s),
// then headless Chrome sized to the svg -> png.
async function render($: EngineInterface, source: string) {
  try {
    await renderOrThrow($, source)
  } catch (err) {
    const previous = await read($, diagram)
    const generation = (previous?.generation ?? 0) + 1
    await update($, diagram, () => ({ source, width: 1, height: 1, generation, error: String(err) }))
    await openPane($)
  }
}

async function renderOrThrow($: EngineInterface, source: string) {
  const previous = await read($, diagram)
  const generation = (previous?.generation ?? 0) + 1
  const dir = await outDir($)
  const svg = `${dir}/diagram.svg`
  const png = `${dir}/diagram-${generation}.png`
  const fail = async (error: string) => {
    await update($, diagram, () => ({ source, width: 1, height: 1, generation, error }))
    await openPane($)
  }

  await $.process.run(['find', dir, '-name', 'diagram-*.png', '-delete'])

  const d2 = await $.process.run(['d2', '--pad', '24', source, svg], { timeoutMs: 60_000 })
  if (d2.exitCode !== 0) return fail(d2.stderr.trim() || `d2 exited ${d2.exitCode}`)

  const text = await $.fs.read(svg)
  const box = /viewBox="[-\d.]+ [-\d.]+ ([\d.]+) ([\d.]+)"/.exec(text)
  const width = Math.max(1, Math.ceil(Number(box?.[1] ?? 1200)))
  const height = Math.max(1, Math.ceil(Number(box?.[2] ?? 800)))

  const chrome = await $.process.run(
    [
      'google-chrome',
      '--headless=new',
      '--disable-gpu',
      '--hide-scrollbars',
      `--screenshot=${png}`,
      `--window-size=${width},${height}`,
      `file://${svg}`,
    ],
    { timeoutMs: 60_000 },
  )
  if (!(await $.fs.exists(png))) return fail(chrome.stderr.trim() || 'chrome wrote no png')

  await update($, diagram, () => ({ source, svg, png, width, height, generation }))
  await openPane($)
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'd2',
      description: 'Diagram pane: /d2 <file> renders, /d2 wide toggles the width, /d2 open shows it in Loupe',
    })
    return next(e)
  })

  on('command.run', { command: 'd2' }, async ($, e) => {
    const arg = e.args.trim()
    if (arg === 'wide') return { text: `d2-pane: ${await toggleWide($)}.` }
    if (arg === 'open') return { text: `d2-pane: ${await openExternal($)}.` }
    if (arg === '') {
      await openPane($)
      // Ask the surface whether the mounted Image really draws: a blit is
      // denied, with the reason, where it shows its alt text instead.
      const now = await read($, diagram)
      if (!now?.png) return { text: 'Diagram pane opened.' }
      const png = await $.fs
        .read(now.png, { as: 'bytes' })
        .then(read => read.base64)
        .catch(() => undefined)
      if (png === undefined) return { text: 'Diagram pane opened (no picture on disk).' }
      const blit = await $.ui.blit({ requestId: PANE, key: 'diagram', source: { png } })
      return {
        text: blit.deny
          ? `Diagram pane opened; the picture does not draw: ${blit.deny}${blit.fix ? ` (fix: ${blit.fix})` : ''}`
          : 'Diagram pane opened; the picture draws.',
      }
    }
    const { stdout, exitCode } = await $.process.run(['realpath', '-e', arg])
    if (exitCode !== 0) return { text: `d2-pane: ${arg} not found.` }
    await render($, stdout.trim())
    const now = await read($, diagram)
    return { text: now?.error ? `d2-pane: render failed: ${now.error}` : `Rendered ${arg}.` }
  })

  // render() never rejects, so a failed render can't fail the Write/Edit.
  on('tool.call', { tool: 'Write' }, async ($, e, next) => {
    const ran = await next(e)
    if (isD2(e.file_path)) await render($, e.file_path)
    return ran
  })
  on('tool.call', { tool: 'Edit' }, async ($, e, next) => {
    const ran = await next(e)
    if (isD2(e.file_path)) await render($, e.file_path)
    return ran
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const elements = $.ui.resolve(e)
    const { Box, Text, Button } = elements
    // Only the terminal surface has Image.
    const Image = 'Image' in elements ? elements.Image : undefined
    const now = await read($, diagram)
    if (now === null) return <Text dimColor>No diagram yet. Write a .d2 file, or /d2 &lt;file&gt;.</Text>

    const name = now.source.split('/').pop()
    if (now.error || !now.png || Image === undefined) {
      return (
        <Box flexDirection="column">
          <Text bold>{name}</Text>
          <Text color="red">{now.error ?? 'This surface cannot draw images.'}</Text>
        </Box>
      )
    }

    // Terminal cells are about twice as tall as wide.
    const maxColumns = Math.min(255, Math.max(1, e.props.bodyColumns))
    const maxRows = Math.min(255, Math.max(1, (e.viewport?.rows ?? 40) - 6))
    let columns = maxColumns
    let rows = Math.max(1, Math.round((columns * now.height) / now.width / 2))
    if (rows > maxRows) {
      rows = maxRows
      columns = Math.max(1, Math.min(maxColumns, Math.round((rows * 2 * now.width) / now.height)))
    }

    const base64 = await $.fs
      .read(now.png, { as: 'bytes' })
      .then(read => read.base64)
      .catch(() => undefined)
    if (base64 === undefined) return <Text dimColor>{name}: rendering…</Text>
    const isWide = await read($, wide)
    return (
      <Box flexDirection="column">
        <Box flexDirection="row" gap={1}>
          <Text dimColor>{name}</Text>
          <Button
            key="wide"
            label={isWide ? 'narrow' : 'wide'}
            hotkey="w"
            dimColor
            onPress={() => void toggleWide($)}
          />
          <Button key="open" label="open" hotkey="o" dimColor onPress={() => void openExternal($)} />
        </Box>
        <Text dimColor wrap="wrap">{now.source}</Text>
        <Image
          key="diagram"
          source={{ png: base64 }}
          columns={columns}
          rows={rows}
          alt={`diagram of ${name}`}
        />
      </Box>
    )
  })
}
