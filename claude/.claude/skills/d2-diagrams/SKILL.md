---
name: d2-diagrams
description: Use when making a plan, design or proposal that changes structure — a flow across repos or services, a sequence of calls, a state machine (phases, stages), a data model or a deploy order — or when the user asks for a diagram, a drawing or "show me how it fits". Also when an earlier diagram of the current item needs updating.
---

# d2 diagrams

Draw diagrams for the user in d2. The `d2-pane` mod (`~/.claude/mods/d2-pane`) renders every `.d2` file written or edited with the **Write or Edit tool** into the Diagram pane beside the chat. These diagrams are the user's own working material, like the log and the handovers. They're not project docs.

## When

Draw when the plan changes **structure**: something one picture explains faster than prose (who calls whom, in what order, which states, which tables). A plan that is a list of edits in one file gets no diagram. When the plan changes something that exists, draw the target situation with the changes marked (classes below; an unmarked box is unchanged, add "(check)" to its label when it only needs verifying). Don't draw the current and the new situation side by side. A separate *view* (the flow, the deploy order, the states) is its own file: draw each view the plan needs.

Draw at the plan's level: components and the calls between them, at most about 15 boxes. Labels name the component (`UpdateStatusHandler`), not its path. File paths belong in the plan text.

## Where

`~/worklog/diagrams/<slug>/<name>.d2`. `<slug>` is the work item's slug: the one the user gives, else the `{slug}` on the last line of today's log, else the handover's. `<name>` says what the view shows (`flow`, `phases`, `deploy-order`). Without a work item, use `~/worklog/diagrams/misc/<YYYY-MM-DD>-<name>.d2`.

- If the item has a handover, link each diagram from it under `## Context`, as a path. Without a handover, the path in the plan text is enough.
- Name the path in the plan text too. The plan stays readable without the picture.
- Put a diagram in a repo only when the user asks for it there.

## How

1. Write the file with **Write**, change it with **Edit**. A file written through Bash (heredoc, sed) is not rendered.
2. Run `d2 validate <file>`. The pane shows d2's error instead of the picture when it fails, but check before telling the user it's there.
3. Keep **one view per file**: a flow, *or* a sequence, *or* states. Mixed views lay out wide and shrink to unreadable in a sidebar. Prefer `direction: down` for the pane.
4. The pane shows the last file rendered. The user can bring back another one with `/d2 <path>` (a slash command only the user runs). Editing a file re-renders it too. For a diagram too big for the sidebar, the user has `/d2 wide` (dock at its widest) and `/d2 open` (full view in Loupe), also as buttons on the pane.

## Quick reference

```d2
direction: down

classes: {
  new: {style: {stroke: "#2e7d32"; stroke-width: 3; font-color: "#2e7d32"}}
  changed: {style: {stroke: "#ef6c00"; stroke-width: 3}}
  removed: {style: {stroke: "#c62828"; stroke-dash: 4; opacity: 0.6}}
}

api: backend {                    # container: repo / app / module
  enum: Status.php {class: changed}
  handler: UpdateStatusHandler
}
gw: gateway
db: Postgres {shape: cylinder}    # also: hexagon, queue, person, page, diamond
gw -> api.handler: set status     # nested ids with dots
worker -> gw: update_status {class: new}
legacy: old endpoint {class: removed}
```

Sequence, in a file of its own:

```d2
shape: sequence_diagram
client; gw; api
client -> gw: POST /orders
gw -> api: forward
api -> gw: 201 {style.stroke-dash: 3}   # dashed = response
gw -> client: 201 {style.stroke-dash: 3}
```

States: plain nodes and labelled arrows (`draft -> published: approve`). Quote a label with `:`, `{` or `#` in it: `a -> b: "GET /x?y=1"`.

## Common mistakes

| Mistake | Fix |
|---|---|
| Wrote the `.d2` with a Bash heredoc, so the pane stays empty | Write/Edit tool |
| `d2 file.d2 out.png` fails with a Playwright 404 | Known in d2 0.7.1. The mod renders SVG and converts it with headless Chrome itself, so you never need PNG |
| A flow and a sequence in one file make a tiny, wide picture | Split into two files |
| Diagram saved in the scratchpad | Gone after the session: use `~/worklog/diagrams/` |
| Plan only says "see diagram" | The plan text must stand on its own. The diagram supports it |
