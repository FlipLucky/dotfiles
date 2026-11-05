export type Diagram = {
  /** The .d2 source, absolute. */
  source: string
  /** The rendered SVG, absolute; what the full view opens. */
  svg?: string
  /** The rendered PNG, absolute; absent until a render succeeded. */
  png?: string
  /** The picture's size in pixels, for the aspect ratio. */
  width: number
  height: number
  /** Bumps on every render, so the pane redraws the new picture. */
  generation: number
  /** What d2 or chrome said when the last render failed. */
  error?: string
}

declare module 'claude-code' {
  interface PluginState {
    'd2-pane': { diagram: Shaped<Diagram | null>; wide: Shaped<boolean> }
  }
}
