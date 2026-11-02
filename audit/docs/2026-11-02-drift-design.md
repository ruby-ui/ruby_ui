# shadcn-audit `drift`: weekly upstream watch

Status: design, approved for planning once reviewed.
Date: 2026-11-02.

## Intent

Components are audited against shadcn (Base UI + vega + neutral) once, when a
"match shadcn" PR lands. shadcn keeps moving afterwards, and today nothing
tells us when it moves under a component we already matched. We want a weekly
routine that points at the possible differences, respects the divergences we
registered as intentional, and asks whether to run the full audit.

The routine will be driven by an agent on lknos that posts to `#dev-rubyui`.
This design covers only what that agent consumes: a deterministic CLI
subcommand and a skill. The agent itself is out of scope.

## Decisions (with the user, 2026-11-02)

- **Semantic diff, not releases.** shadcn releases cover the CLI package;
  registry style changes rarely appear there. A raw GitHub diff is noisy
  (`style-vega.css` is one shared file). The core is `Reference` (effective
  classes per `data-slot` part) computed at the baseline SHA and at `main`,
  then diffed.
- **Baseline per component in `component_map/<folder>.yml`**, as a new
  optional key `shadcn_sha` (40-char SHA): the shadcn commit the component was
  last matched against. One file per component keeps parallel PRs apart.
- **Scope: the mapped components only.** A component enters the watch when its
  map file is created. `shadcn: null` entries are skipped.
- **Post language: pt-BR.** The CLI JSON stays in English, like the rest of
  `audit/`.

## Goals

1. `exe/shadcn-audit drift [--components a,b] [--head SHA]` prints one JSON
   object (same contract as every subcommand). Per mapped component:
   - `status`: `unchanged`, `changed`, `no_baseline`, `no_counterpart`,
     `missing_upstream` (the `.tsx` is gone at head), or `inconclusive`
     (with `reason`, e.g. the baseline SHA can't be fetched).
   - `reference`: `parts_added`, `parts_removed` (data-slots), `classes`
     (per slot: `added`/`removed` effective classes), `variants` (per cva
     group/name: `added`/`removed`), `warnings_added` (new `Reference`
     warnings at head, so a scanner gap never reads as "no change").
   - `source_diff`: unified `git diff` of the component's own `.tsx`
     between baseline and head (ARIA, props, parts, Base UI usage, which
     `Reference` doesn't see), truncated at 200 lines with `truncated: true`.
   - `commits`: shadcn commits touching that `.tsx` since the baseline
     (`sha`, `title`, `url`), via `gh api`. A `gh` failure fills
     `commits_error` and the run goes on.
   - `related_divergences`: entries from `divergences/<folder>.yml` the
     agent must weigh: those whose `match.part` is a RubyUI part mapped to a
     changed slot, plus every entry without `match` (prose, agent-judged).
   Global keys: `head_sha`, `theme` (`Theme.compare` of the neutral theme at
   head against RubyUI's CSS: absolute, needs no baseline), and `base_ui`
   (`@base-ui/react` version in `apps/v4/package.json` at head and at each
   distinct baseline: a bump changes behavior without any shadcn diff).
2. `exe/shadcn-audit baseline <folder> <sha>` writes or replaces
   `shadcn_sha:` in that map file (text edit, keeps comments).
3. Skill `.claude/skills/shadcn-drift/`: runs `drift`, triages each changed
   component (covered by a divergence, divergence possibly stale, or new
   drift), and returns a Slack-ready pt-BR message ending with the question
   "rodo o audit completo em X, Y?". It never posts. After an explicit ok,
   it can open a PR advancing the baseline of components judged "no impact".
4. `shadcn-audit` skill wrap-up tells the fix-PR author to run
   `baseline <folder> <shadcn_sha>` in the same PR.
5. One-off seed: the 17 components with a merged "match shadcn" PR get the
   shadcn `main` SHA at that PR's merge time. `command` and `sheet` have no
   such PR and stay `no_baseline` (the post asks for their full audit).

## How divergences are respected

- `drift` attaches `related_divergences`; it does not decide coverage. A
  Look `match` is about computed CSS (`opacity: 0.5`), while `drift` sees
  Tailwind classes, and no class→property table would be honest.
- The skill classifies each change as **covered** (a divergence explains it
  and still holds), **stale divergence** (the change touches the `shadcn:`
  side of a divergence, e.g. shadcn fixes the span `disabled:opacity-50` that
  `checkbox.yml` documents), or **new drift**. Covered changes appear in the
  post as one line, never as an alert.

## Mechanics

- Head: `Workspace#sync(sha:)` as today.
- Old trees: `Snapshot#materialize(sha)` fetches the commit into the existing
  sparse clone (`git fetch --depth 1 origin <sha>`), then
  `git archive` of `apps/v4/registry/bases/base/ui`, `apps/v4/registry/styles`,
  `apps/v4/registry/themes.ts` and `apps/v4/package.json` into
  `.shadcn-audit/snapshots/<sha>/`, cached. Spiked on 2026-11-02: about 2.5s
  per SHA, 75 files.
- `Reference.new(registry_dir: <snapshot>/apps/v4/registry)` runs unchanged
  at both SHAs. Parts rendered through other components (e.g. carousel's
  Button) are covered because `Reference` already resolves them.
- No browser, no LLM, no write to GitHub: runs on lknos with git, Ruby 3.4
  and an authenticated `gh` (read).

## Non-goals (v1)

- GitHub Actions cron. Possible phase 2 (weekly `drift` into a tracking
  issue); left out so there is a single alert channel.
- Running the full audit from lknos. It needs pnpm, Playwright, the
  chrome-devtools MCP and two dev servers; lknos has no package parity with
  the Macs. Validate before the agent promises it.
- Unmapped components, and `fixture_shadcn` components.
- Deciding divergence coverage in Ruby.
