# audit

Deterministic tooling for the shadcn-fidelity audit skill. Each subcommand prints one JSON object.

```bash
cd audit
mise exec -- bundle exec rake                       # tests + standardrb
mise exec -- bundle exec exe/shadcn-audit workspace [--sha SHA]
```

`workspace` keeps a sparse clone of `shadcn-ui/ui` in `.shadcn-audit/ui` (git-ignored) and checks out `main`, or the given SHA.

Tests use `ShadcnAudit::FakeShell` (`test/test_helper.rb`): stub canned stdout by argv or matcher, then assert on recorded calls.

## Without Claude

Any agent or person can run the tooling directly:

```bash
cd audit && mise exec -- bundle install && mise exec -- bundle exec exe/shadcn-audit workspace
```

The full audit procedure is [`.claude/skills/shadcn-audit/SKILL.md`](../.claude/skills/shadcn-audit/SKILL.md) and its `references/`; any agent can read it and follow it with this CLI. Reference rules are in [`gem/AGENTS.md`](../gem/AGENTS.md#shadcn-reference). In Claude Code, run `/shadcn-audit` instead.
