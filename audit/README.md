# audit

Deterministic tooling for the shadcn-fidelity audit skill. Each subcommand prints one JSON object.

```bash
cd audit
mise exec -- bundle exec rake                       # tests + standardrb
mise exec -- bundle exec exe/shadcn-audit workspace [--sha SHA]
```

`workspace` keeps a sparse clone of `shadcn-ui/ui` in `.shadcn-audit/ui` (git-ignored) and checks out `main`, or the given SHA.

`collect <folder> --run <dir> [--preview <path>] [--shadcn-url T] [--rubyui-url T]` drives both fixtures in headless Chromium (playwright-ruby-client) with the sandbox and preview servers running, and writes `<dir>/collect.json`: computed styles, accessibility snapshots, screenshots and pixel diffs per state, plus the objectively graded Look/ARIA lines. It needs `pnpm install && pnpm exec playwright install chromium` here once. Part selectors come from `selectors` in `component_map/<folder>.yml`; a `match` key in `divergences.yml` lets `collect` apply that divergence on its own.

Tests use `ShadcnAudit::FakeShell` (`test/test_helper.rb`): stub canned stdout by argv or matcher, then assert on recorded calls.

## Prerequisites

Ruby 3.4 (via mise, as below, or an equivalent version manager; without mise, drop `mise exec --`), `gh` authenticated (`gh auth status`), Node and pnpm, Playwright's Chromium for `collect` (above), and, for the remaining browser steps, the chrome-devtools MCP. The audit runs its two dev servers in Herdr panes when `HERDR_ENV=1`, otherwise as background shell processes; either way it stops them at the end. `preview` boot commands use `mise exec --` only when `mise` is on PATH.

A component gets its own `component_map/<folder>.yml` (keys in [`component_map/README.md`](component_map/README.md)) and also needs fixtures in `fixtures/<folder>/` (`content.yml`, `shadcn.tsx`, `rubyui.rb`).

## Without Claude

Any agent or person can run the tooling directly:

```bash
cd audit && mise exec -- bundle install && mise exec -- bundle exec exe/shadcn-audit workspace
```

The full audit procedure is [`.claude/skills/shadcn-audit/SKILL.md`](../.claude/skills/shadcn-audit/SKILL.md) and its `references/`; any agent can read it and follow it with this CLI. Reference rules are in [`gem/AGENTS.md`](../gem/AGENTS.md#shadcn-reference). In Claude Code, run `/shadcn-audit` instead.
