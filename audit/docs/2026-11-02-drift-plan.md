# shadcn-audit `drift` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A deterministic `drift` subcommand plus a `shadcn-drift` skill that report, weekly, what changed in shadcn under each mapped RubyUI component since its baseline, respecting registered divergences.

**Architecture:** Each map file gains `shadcn_sha` (baseline). `Snapshot` materializes old shadcn trees with `git archive`; `Drift::Diff` compares two `Reference` results; `Drift::Runner` assembles the per-component JSON (reference diff, `.tsx` diff, commits, related divergences) plus global theme and Base UI version. The skill turns that JSON into a pt-BR Slack message and never posts.

**Tech Stack:** Ruby 3.4, Minitest, StandardRB, `git`, `gh`; existing `ShadcnAudit::{Workspace, Reference, Theme, ComponentMap, Divergences, Shell, FakeShell}`.

**Spec:** `audit/docs/2026-11-02-drift-design.md`

## Global Constraints

- Every subcommand prints exactly one JSON object; failures go through `CLI::ERRORS` as `{"error": …}`, exit 1.
- All shell calls go through an injected `shell` (`Shell` / `FakeShell`); no backticks, no `system`.
- `shadcn_sha` is exactly `/\A[0-9a-f]{40}\z/`.
- Snapshot paths archived: `apps/v4/registry/bases/base/ui`, `apps/v4/registry/styles`, `apps/v4/registry/themes.ts`, `apps/v4/package.json`. Cache: `.shadcn-audit/snapshots/<sha>/`.
- `source_diff` truncated at 200 lines.
- Base UI package key: `@base-ui/react`.
- JSON, code and docs in English; only the skill's Slack message is pt-BR.
- Never edit `audit/divergences/`; `drift` writes no repository file, only the workspace clone (`Workspace#sync`) and the snapshot cache.
- Run everything from `audit/`: `mise exec -- bundle exec rake` must be green after each task.

## Review Focus

- Baseline SHA no longer fetchable (force-push, typo that still passes the regex) → that component is `inconclusive` with the git message as `reason`; other components still run. (Task 4)
- shadcn deletes or renames the component's `.tsx` → `missing_upstream`, not a crash and not `unchanged`. (Task 4)
- `gh` unauthenticated or rate-limited → `commits: []` plus `commits_error`, run continues. (Task 4)
- `Reference` emits a new warning at head (scanner gap) with an otherwise empty diff → status `changed`, never `unchanged`. (Tasks 3 and 4)
- `baseline` on a map file with comments and no `shadcn_sha` yet → inserts the line after `shadcn:` and keeps every comment. (Task 5)

---

### Task 1: `shadcn_sha` in the component map

**Files:**
- Modify: `audit/lib/shadcn_audit/component_map.rb`
- Modify: `audit/component_map/README.md` (document the key)
- Test: `audit/test/component_map_test.rb`

**Interfaces:**
- Produces: `ComponentMap#shadcn_sha(folder) -> String | nil`; `ComponentMap::SHA = /\A[0-9a-f]{40}\z/`.

- [ ] **Step 1: Write the failing tests**

```ruby
def test_shadcn_sha_reads_the_baseline
  map = ShadcnAudit::ComponentMap.new({"badge" => {"shadcn" => "badge", "shadcn_sha" => "a" * 40}})
  assert_equal "a" * 40, map.shadcn_sha("badge")
  assert_nil map.shadcn_sha("missing")
end

def test_rejects_a_short_shadcn_sha
  error = assert_raises(ShadcnAudit::ConfigError) do
    ShadcnAudit::ComponentMap.new({"badge" => {"shadcn" => "badge", "shadcn_sha" => "abc123"}})
  end
  assert_match(/shadcn_sha must be a full 40-character commit SHA/, error.message)
end
```

- [ ] **Step 2: Run, expect FAIL** — `mise exec -- bundle exec rake test TEST=test/component_map_test.rb` → `NoMethodError: shadcn_sha`.
- [ ] **Step 3: Implement** `shadcn_sha(folder)` and a check in `validate!` (nil allowed; otherwise must match `SHA`; message `"#{where(folder)}: shadcn_sha must be a full 40-character commit SHA"`). Add the key to the README list: "`shadcn_sha` (optional): shadcn commit the component was last matched against; `drift` diffs from here. Set with `exe/shadcn-audit baseline <folder> <sha>`."
- [ ] **Step 4: Run, expect PASS** — same command, then `mise exec -- bundle exec rake`.
- [ ] **Step 5: Commit** — `git commit -m "[Feature] shadcn-audit: shadcn_sha baseline in component map"`

### Task 2: `Snapshot`

**Files:**
- Create: `audit/lib/shadcn_audit/snapshot.rb` (require it in `audit/lib/shadcn_audit.rb` after `workspace`)
- Test: `audit/test/snapshot_test.rb`

**Interfaces:**
- Consumes: the sparse clone at `<dir>/ui` made by `Workspace`.
- Produces: `Snapshot.new(shell:, dir:)`; `#materialize(sha) -> Pathname` (snapshot root; registry is `root.join("apps/v4/registry")`); `#commit_date(sha) -> String` (ISO 8601, `git show -s --format=%cI <sha>`); `#diff(from, to, path) -> String` (`git diff <from> <to> -- <path>` in the clone). `Snapshot::PATHS` = the four archived paths.

- [ ] **Step 1: Write the failing tests** (FakeShell, tmp dir)

```ruby
def test_materialize_fetches_archives_and_extracts
  root = @snapshot.materialize(SHA)
  assert_equal @dir.join("snapshots", SHA), root
  assert @shell.called?("git", "fetch", "--depth", "1", "origin", SHA)
  archive = @shell.argvs.find { |a| a[0, 2] == %w[git archive] }
  assert_equal ["--format=tar", "--output=#{@dir.join("snapshots", "#{SHA}.tar")}", SHA, *ShadcnAudit::Snapshot::PATHS], archive[2..]
  assert @shell.called?("tar", "-xf", @dir.join("snapshots", "#{SHA}.tar").to_s, "-C", @dir.join("snapshots", "#{SHA}.tmp").to_s)
end

def test_materialize_reuses_an_existing_snapshot
  FileUtils.mkdir_p(@dir.join("snapshots", SHA, "apps/v4"))
  @snapshot.materialize(SHA)
  assert_empty @shell.argvs
end

def test_materialize_rejects_a_short_sha
  assert_raises(ShadcnAudit::ConfigError) { @snapshot.materialize("abc") }
end

def test_materialize_leaves_no_partial_snapshot_when_fetch_fails
  @shell.stub_error(->(a) { a[0, 2] == %w[git fetch] }, "not our ref")
  assert_raises(ShadcnAudit::Shell::Error) { @snapshot.materialize(SHA) }
  refute @dir.join("snapshots", SHA).exist?
end
```

- [ ] **Step 2: Run, expect FAIL** — `rake test TEST=test/snapshot_test.rb` → `uninitialized constant Snapshot`.
- [ ] **Step 3: Implement.** Cache hit = `root.join("apps/v4").directory?`. Extract into `<sha>.tmp`, rename to `<sha>` only on success, delete the `.tar` afterwards. Requires the clone (`ConfigError` "run `workspace` first" otherwise, as `Workspace#current_sha`). All git calls `chdir: <dir>/ui`.
- [ ] **Step 4: Run, expect PASS.**
- [ ] **Step 5: Commit** — `[Feature] shadcn-audit: snapshot old shadcn trees`

### Task 3: `Drift::Diff` (pure)

**Files:**
- Create: `audit/lib/shadcn_audit/drift/diff.rb`
- Test: `audit/test/drift/diff_test.rb`

**Interfaces:**
- Consumes: two `Reference#for` results (`"parts" => {slot => {"effective" => [...]}}`, `"variants" => {cva => {group => {name => [classes]}}}`, `"warnings" => [...]`).
- Produces: `Drift::Diff.compare(before, after) -> Hash` with keys `parts_added`, `parts_removed` (sorted slot arrays), `classes` (`{slot => {"added" => [], "removed" => []}}`, only changed slots present in both), `variants` (`{"cva/group/name" => {"added", "removed"}}`, only changed), `warnings_added`; and `Drift::Diff.empty?(diff) -> Boolean` (every collection empty, `warnings_added` included).

- [ ] **Step 1: Write the failing tests** with literal hashes:
  - `test_reports_added_and_removed_classes_per_slot`: before `checkbox` effective `%w[size-4 rounded-sm]`, after `%w[size-4 rounded-md]` → `{"checkbox" => {"added" => ["rounded-md"], "removed" => ["rounded-sm"]}}`.
  - `test_reports_added_and_removed_parts`.
  - `test_reports_variant_changes_by_path`: key `"buttonVariants/size/sm"`.
  - `test_class_order_change_is_not_a_change`: `%w[a b]` vs `%w[b a]` → `empty?` true.
  - `test_new_warning_alone_is_not_empty`: identical parts, after warnings `["x"]` → `empty?` false, `warnings_added == ["x"]`.
- [ ] **Step 2: Run, expect FAIL.**
- [ ] **Step 3: Implement** with set differences; output arrays sorted.
- [ ] **Step 4: Run, expect PASS.**
- [ ] **Step 5: Commit** — `[Feature] shadcn-audit: diff two Reference results`

### Task 4: `Drift::Runner`

**Files:**
- Create: `audit/lib/shadcn_audit/drift/runner.rb` (require `drift/diff` and `drift/runner` in `audit/lib/shadcn_audit.rb` after `theme`)
- Test: `audit/test/drift/runner_test.rb`

**Interfaces:**
- Consumes: `ComponentMap#all_folders/#entry/#shadcn_sha`, `Divergences#for_component`, `Snapshot#materialize/#commit_date/#diff`, `Reference.new(registry_dir:).for(name)`, `Theme.compare(themes_ts:, rubyui_css:)`, `Drift::Diff`.
- Produces: `Drift::Runner.new(map:, divergences:, snapshot:, shell:, head_sha:, rubyui_css:, components: nil).call -> Hash` with the exact shape in the design's Goal 1 (`head_sha`, `theme`, `base_ui` `{"head" => v, "baselines" => {sha => v}}`, `components` `{folder => {...}}`). Per component keys: `status`, `shadcn`, `baseline_sha`, `reason` (only `inconclusive`), `reference`, `source_diff` `{"path", "diff", "truncated"}`, `commits`, `commits_error`, `related_divergences`.

Rules the tests pin:
- `shadcn: null` → `no_counterpart`; no `shadcn_sha` → `no_baseline`; neither touches the shell.
- `.tsx` missing at head (`Reference` returns `"missing" => true`) → `missing_upstream`.
- `Shell::Error` or `ConfigError` while materializing the baseline or running `Reference` → `inconclusive`, `reason` = error message; next component still runs.
- `changed` iff `!Diff.empty?(reference)` or `source_diff["diff"]` non-empty; else `unchanged` (and then `commits`/`related_divergences` are `[]`, no `gh` call).
- `related_divergences`: entries whose `match.part` is a RubyUI part whose slot (via `parts`) is in `classes` keys ∪ `parts_added` ∪ `parts_removed`, plus every entry without `match`.
- Commits: `gh api -X GET repos/shadcn-ui/ui/commits -f path=apps/v4/registry/bases/base/ui/<shadcn>.tsx -f sha=<head> -f since=<commit_date(baseline)> -f per_page=30 --jq '[.[] | {sha, title: (.commit.message | split("\n")[0]), url: .html_url}]'`, baseline SHA filtered out; `Shell::Error` → `commits: []`, `commits_error: message`.
- `base_ui`: `JSON.parse(<snapshot>/apps/v4/package.json)` → `dependencies["@base-ui/react"] || devDependencies[...]`, at head and each distinct baseline.
- `components:` filter with an unknown folder → `ArgumentError` naming it.

- [ ] **Step 1: Write the failing tests.** Build two registry trees in a tmp dir by copying `test/fixtures/registry` and editing one class in the copy's `bases/base/ui/dialog.tsx`; a fake snapshot object (`materialize` returns the right tree per SHA, `diff` returns canned text, `commit_date` a fixed ISO string) and `FakeShell` for `gh`. One test per rule above, plus `test_new_reference_warning_marks_changed`.
- [ ] **Step 2: Run, expect FAIL.**
- [ ] **Step 3: Implement.** Head snapshot also comes from `snapshot.materialize(head_sha)` so both sides read the same four paths. Truncate `source_diff` to the first 200 lines.
- [ ] **Step 4: Run, expect PASS**, then the full `rake`.
- [ ] **Step 5: Commit** — `[Feature] shadcn-audit: drift runner`

### Task 5: CLI `drift` and `baseline`

**Files:**
- Modify: `audit/lib/shadcn_audit/cli.rb`
- Modify: `audit/README.md` (one paragraph per subcommand)
- Create: `audit/lib/shadcn_audit/baseline.rb`
- Test: `audit/test/cli_drift_test.rb`, `audit/test/baseline_test.rb`

**Interfaces:**
- Produces: `Baseline.write(path:, sha:) -> {"path", "shadcn_sha", "previous"}`. CLI: `drift [--components a,b] [--head SHA]` (no `--head` → `Workspace#sync` to `main`, else `sync(sha:)`; then `Runner` with `rubyui_css: root.join("docs/app/assets/stylesheets/application.tailwind.css")`); `baseline <folder> <sha>`.

- [ ] **Step 1: Write the failing tests.**
  - `test_baseline_replaces_an_existing_line` (`previous` = old SHA).
  - `test_baseline_inserts_after_the_shadcn_line_keeping_comments`: file with a `# comment` line and no `shadcn_sha` → line inserted right after `shadcn: badge`, comment intact, `ComponentMap.load` still parses it.
  - `test_baseline_rejects_short_sha_and_unknown_folder` (via `CLI.run` → JSON `error`, exit 1).
  - `test_drift_passes_components_and_head_to_the_runner`: inject a runner factory dep (`CLI.drift(args, out:, runner_factory: …, shell: FakeShell)`), assert `components: ["badge", "card"]` and the head SHA reached it.
- [ ] **Step 2: Run, expect FAIL.**
- [ ] **Step 3: Implement**; register both in `COMMANDS`.
- [ ] **Step 4: Run, expect PASS**; full `rake`; then a real smoke run: `mise exec -- bundle exec exe/shadcn-audit drift --components badge` → valid JSON (status `no_baseline` before Task 6).
- [ ] **Step 5: Commit** — `[Feature] shadcn-audit: drift and baseline subcommands`

### Task 6: Seed baselines

**Files:**
- Modify: `audit/component_map/{accordion,alert,alert_dialog,aspect_ratio,avatar,badge,breadcrumb,bubble,button,calendar,card,carousel,checkbox,codeblock,collapsible,dialog,form}.yml`

PR per folder (merge time from `gh pr view <n> -R ruby-ui/ruby_ui --json mergedAt`): accordion 596, alert 599, alert_dialog 598, aspect_ratio 601, avatar 602, badge 600, breadcrumb 606, bubble 605, button 607, calendar 609, card 608, carousel 610, checkbox 615 (later of 613/615), codeblock 617, collapsible 618, dialog 583, form 592. `command` and `sheet` stay without baseline.

- [ ] **Step 1:** For each, `sha=$(gh api "repos/shadcn-ui/ui/commits?sha=main&until=<mergedAt>&per_page=1" -q '.[0].sha')` then `exe/shadcn-audit baseline <folder> $sha`.
- [ ] **Step 2:** `rake` green; `exe/shadcn-audit drift` → 17 components not `no_baseline`, `command`/`sheet` `no_baseline`, no `inconclusive`. Paste the status summary into the PR description.
- [ ] **Step 3: Commit** — `[Chore] shadcn-audit: seed shadcn_sha baselines from match PRs`

### Task 7: Skills

**Files:**
- Create: `.claude/skills/shadcn-drift/SKILL.md`
- Modify: `.claude/skills/shadcn-audit/SKILL.md` (wrap-up step)
- Modify: root `CLAUDE.md` (Layout row for `audit/` mentions the drift skill)

`shadcn-drift` SKILL.md content (frontmatter `description` with triggers "/shadcn-drift", "o que mudou no shadcn", "drift do shadcn", "roda o check semanal do shadcn"; exclusions: full audit → shadcn-audit):
1. Run `cd audit && mise exec -- bundle exec exe/shadcn-audit drift`; error JSON → report it, stop.
2. For each `changed`: read `reference`, `source_diff`, `related_divergences`; classify every change as **coberta** (a divergence explains it and its `shadcn:` text still holds), **divergência possivelmente obsoleta** (the change touches the `shadcn:` side of an entry), or **drift novo**. Behavior/ARIA/props come from `source_diff`. `warnings_added` → say the scanner may have missed something.
3. Global: `theme.status == "fail"` and `base_ui` bumps are always reported.
4. Output a Slack mrkdwn message in pt-BR, fixed shape: header with week and `head_sha` short link; one block per component with drift novo / obsoleta (what changed, commit links, why it matters); one line listing components with only covered changes; one line for `no_baseline` / `missing_upstream` / `inconclusive`; final question "Quer que eu rode o audit completo em: X, Y?". Nothing changed → a one-line "sem mudanças" message.
5. Hard rules: never post (the caller posts); never edit `divergences/`; full audit only after a yes, via the shadcn-audit skill per component; advancing baselines only after an explicit ok, by a PR (`[Chore] shadcn-audit: advance baselines`) running `baseline <folder> <head_sha>` for the components the user marked "sem impacto".

shadcn-audit wrap-up addition: "If the audited PR fixes the component, tell the author to run `exe/shadcn-audit baseline <folder> <shadcn_sha>` in the same PR (the report's `shadcn_sha`), so `drift` starts from there."

- [ ] **Step 1:** Write the files.
- [ ] **Step 2:** Dry run: invoke `/shadcn-drift` in a session; check the message follows the shape and lists `command`/`sheet` as sem baseline.
- [ ] **Step 3: Commit** — `[Feature] shadcn-drift skill for the weekly upstream watch`

---

## As built (after review)

The Claude, Codex and Cubic reviews changed the Runner contract beyond Task 4 above. The design doc is current; in short:

- Per component, `dependencies`: the `Reference` diff of each shadcn component a part is rendered through (`<Button>`), resolved in head or baseline, changed ones only. A non-empty `dependencies` marks the component `changed`.
- `Diff` compares a slot's `also` classes with its own.
- `related_divergences` returns every entry of the component when the `.tsx`, a dependency, a variant or the scanner warnings changed.
- `missing_upstream` still carries `source_diff` and `commits`; `commits_truncated` flags a full page of 30.
- Any unexpected error inside one component yields `inconclusive` with `"<Class>: <message>"`.
- `base_ui.baselines` keeps unreadable baselines as `null`.
- `Snapshot#diff`/`#commit_date` refetch a commit missing from the clone.
- `baseline` requires a mapped folder name (`/\A[a-z0-9_]+\z/` with a map entry) and keeps trailing comments.

