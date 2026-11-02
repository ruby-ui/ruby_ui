# Divergences

Intentional RubyUI-vs-shadcn differences, one file per RubyUI component:
`<folder>.yml`, where `<folder>` is the component's folder under
`gem/lib/ruby_ui/`. A component's PR adds or edits only its own file, so
parallel PRs don't touch the same lines.

Each file is a list of entries. A divergence listed here makes the matching
finding a `pass` with basis `intentional`.

- `component`: the folder, the same as the file name.
- `dimension`: one of `Look`, `HTML`, `Props`, `ARIA`, `Behavior`, `Animation`, `Native`.
- `rubyui`, `shadcn`: what each side does.
- `reason`: why RubyUI differs (never `TODO`).
- `since`: the date it was registered.
- `match` (optional): `{part, property (Look) | attribute (ARIA, or snapshot), rubyui, shadcn}`
  lets `collect` apply the entry on its own; entries without it are applied by the agent.
