# audit

Deterministic tooling for the shadcn-fidelity audit skill. Each subcommand prints one JSON object.

```bash
cd audit
bundle exec rake                       # tests + standardrb
bundle exec exe/shadcn-audit workspace [--sha SHA]
```

`workspace` keeps a sparse clone of `shadcn-ui/ui` in `.shadcn-audit/ui` (git-ignored) and checks out `main`, or the given SHA.

Tests use `ShadcnAudit::FakeShell` (`test/test_helper.rb`): stub canned stdout by argv or matcher, then assert on recorded calls.
