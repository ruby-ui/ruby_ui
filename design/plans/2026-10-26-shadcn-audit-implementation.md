# shadcn Fidelity Audit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A `/shadcn-audit <PR | branch | component>` Claude Code skill in the `ruby_ui` repo that compares the RubyUI components a PR touches against shadcn/ui (Base UI + vega + neutral), checks shadcn against the specs, flags JS that could be native HTML, prints a checklist, builds a side-by-side screenshot page, and posts the checklist on the PR after an explicit ok. Plus the shadcn MIT attribution fix.

**Architecture:** Deterministic work lives in a new Ruby subproject `audit/` (sibling of `gem/`, `docs/`, `mcp/`), exposed as `audit/exe/shadcn-audit <subcommand>` that prints JSON: workspace sync, target resolution, reference extraction, theme diff, sandbox scaffolding, RubyUI preview checkout, report rendering, PR comment upsert. Judgment work (mapping what the browser shows to verdicts, spec checks, native-over-JS) lives in `.claude/skills/shadcn-audit/SKILL.md` + references, which drives the CLI and chrome-devtools MCP and writes a `report.json` the CLI renders. Everything mutable lives in the gitignored `.shadcn-audit/` folder at the repo root.

**Tech Stack:** Ruby 3.4 (stdlib only: json, yaml, erb, open3, fileutils), Minitest, StandardRB; `git`, `gh`; Node/pnpm + shadcn CLI + Vite for the sandbox; chrome-devtools MCP for driving browsers.

**Spec:** `design/2026-10-26-shadcn-audit-design.md`

## Global Constraints

- Reference is shadcn-ui/ui `main`: Base UI base `apps/v4/registry/bases/base/ui/<name>.tsx`, style `apps/v4/registry/styles/style-vega.css`, theme `neutral` (`apps/v4/registry/themes.ts`). Never `new-york-v4`, never the ui.shadcn.com rendering (it is nova).
- Effective shadcn classes for a part = inline classes in the `.tsx` + the `@apply` body of every `cn-*` class it references, resolved from `style-vega.css`.
- HTML, ARIA and behavior verdicts come only from DOM rendered in the sandbox and driven in a browser, never from the `.tsx`.
- Status values: `pass` ✅, `warn` ⚠️, `fail` ❌, `inconclusive` ⏸. Optional `basis` on a `pass`: `intentional` (registered divergence), `native` (native-HTML replacement keeping shadcn's behavior/ARIA), `spec` (RubyUI follows the spec where shadcn doesn't). Nothing unverified is ever `pass`.
- Spec weights: HTML Living Standard / WAI-ARIA / ARIA in HTML are normative (violation); APG is guidance (`warn`, "recommendation"); MDN is explanatory only (prefer pt-BR, fall back to en-US). Every spec finding cites a URL with anchor.
- Pre-existing drift is reported mixed with drift the PR introduced.
- The audit never edits PR code and never pushes. Its only external output is the PR comment, posted only after an explicit "ok" in the session, one comment per PR identified by `<!-- shadcn-audit -->`, and only if the PR head SHA hasn't moved since the run began.
- Workspace: `.shadcn-audit/` at repo root, gitignored. `.shadcn-audit/ui` (shadcn clone, untrusted: read only, never run its scripts), `.shadcn-audit/sandbox` (Vite app), `.shadcn-audit/checkouts/<sha>` (RubyUI at a SHA, via `git archive`, not `git worktree`), `.shadcn-audit/runs/<run-id>/` (report.json, screenshots, report.html).
- Ruby commands run through `mise exec --` (Ruby 3.4.7, as in `gem/.tool-versions`); system Ruby can't run these lockfiles.
- Commits: bracketed prefix (`[Feature]`, `[Documentation]`, `[Bug Fix]`), ending with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Acceptance pins: PR #572 head `a9a5d1faee2257e8e83c144a5be88c378347640d`, base `ddcff1c6e26825512006d732bbe408c48065c5d1`, shadcn `8f04138777c1b6996e709993362a7b0a12888ecf`.

## Review Focus

1. **PR from a fork** — head SHA isn't on `origin`; target resolution must fetch `refs/pull/<n>/head` and still archive the right tree. Test in Task 4.
2. **PR head moves between run and post** — must refuse to post and say so. Test in Task 9.
3. **shadcn renames or drops a `cn-*` rule** referenced by the `.tsx` — must surface as an unresolved class, never be silently dropped (that would make RubyUI look "missing nothing"). Test in Task 5.
4. **Component with no map entry or no shadcn file** — must yield `inconclusive` with a suggested map entry, not crash or `pass`. Test in Tasks 3 and 5.
5. **Re-running on the same PR** — must edit the existing marked comment, not stack a second one; a human-edited body that still carries the marker is still found. Test in Task 9.

---

### Task 1: shadcn MIT attribution

**Files:**
- Modify: `gem/LICENSE.txt` (append third-party section)
- Modify: `gem/README.md:90-92` (License section)
- Test: `gem/test/license_test.rb`

**Interfaces:**
- Produces: nothing consumed by later tasks.

- [ ] **Step 1: Write the failing test** `gem/test/license_test.rb`, class `LicenseTest < Minitest::Test`:
  - `test_license_carries_shadcn_mit_notice`: `File.read(LICENSE)` includes `"Copyright (c) 2023 shadcn"` and the full permission sentence `"The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software."` (whitespace-normalized) at least twice (RubyUI's + shadcn's).
  - `test_gemspec_ships_license`: `Gem::Specification.load("ruby_ui.gemspec").files` includes `"LICENSE.txt"`.
  - `test_readme_license_points_to_own_license`: README's `## License` section links `LICENSE.txt` and mentions shadcn attribution; it no longer links `github.com/shadcn/ui/blob/main/LICENSE.md` as RubyUI's license.
- [ ] **Step 2: Run** `cd gem && mise exec -- bundle exec rake test TEST=test/license_test.rb` — expect 3 failures (the gemspec test may already pass; that's fine).
- [ ] **Step 3: Edit** `gem/LICENSE.txt`: keep RubyUI's MIT text; append a section headed `Third-party notices` → `shadcn/ui (https://github.com/shadcn-ui/ui)`, one line saying RubyUI's component styles, structure and examples are derived from it, then shadcn's MIT license verbatim (`MIT License` / `Copyright (c) 2023 shadcn` / full text). Edit `gem/README.md` License section: "Licensed under the MIT license (see [LICENSE.txt](LICENSE.txt)). Component design derived from [shadcn/ui](https://github.com/shadcn-ui/ui), MIT — notice included in LICENSE.txt."
- [ ] **Step 4: Run** `cd gem && mise exec -- bundle exec rake` — all green, standardrb clean.
- [ ] **Step 5: Commit** `[Documentation] Include shadcn/ui MIT notice in LICENSE.txt`

### Task 2: `audit/` subproject, CLI skeleton, workspace sync

**Files:**
- Create: `audit/Gemfile`, `audit/Rakefile`, `audit/.tool-versions` (`ruby 3.4.7`), `audit/README.md`, `audit/exe/shadcn-audit`, `audit/lib/shadcn_audit.rb`, `audit/lib/shadcn_audit/shell.rb`, `audit/lib/shadcn_audit/workspace.rb`, `audit/lib/shadcn_audit/cli.rb`
- Create: `audit/test/test_helper.rb`, `audit/test/workspace_test.rb`
- Modify: `.gitignore` (add `.shadcn-audit/` and `.superpowers/`)
- Modify: `.github/workflows/ci.yml` (add `audit` job, copy of the `mcp` job with `working-directory: audit`, running `bundle exec rake`)

**Interfaces:**
- Produces: `ShadcnAudit::Shell#capture(*argv, chdir: nil) -> String` (raises `ShadcnAudit::Shell::Error` with stderr on non-zero exit); `ShadcnAudit::FakeShell` in `test_helper.rb` that records calls and returns canned outputs keyed by argv.
- Produces: `ShadcnAudit.root -> Pathname` (repo root), `ShadcnAudit.workspace_dir -> Pathname` (`root/.shadcn-audit`).
- Produces: `ShadcnAudit::Workspace.new(shell:, dir:)#sync(sha: nil) -> {"shadcn_sha" => String, "path" => String}`. Clones `https://github.com/shadcn-ui/ui.git` into `dir/ui` with `--filter=blob:none --sparse` on first run, sparse paths `apps/v4/registry` and `apps/v4/content/docs/changelog`; then `git fetch --depth 1 origin <sha || "main">` + `git checkout --detach FETCH_HEAD` (no `pull`, so a dirty cache never blocks). Returns `git rev-parse HEAD`.
- Produces: `ShadcnAudit::CLI.start(argv, out:)` dispatching subcommands; every subcommand prints one JSON object. Subcommand `workspace [--sha SHA]`.

- [ ] **Step 1: Write failing tests** in `workspace_test.rb`:
  - `test_first_sync_clones_sparse_and_checks_out_main`: with a FakeShell and an empty tmp dir, `sync` issues `git clone --filter=blob:none --sparse https://github.com/shadcn-ui/ui.git <dir>/ui`, then `git sparse-checkout set apps/v4/registry apps/v4/content/docs/changelog`, `git fetch --depth 1 origin main`, `git checkout --detach FETCH_HEAD`; returns the faked `rev-parse` SHA.
  - `test_existing_clone_skips_clone`: with `<dir>/ui/.git` present, no `git clone` call.
  - `test_pinned_sha_fetches_that_sha`: `sync(sha: "8f04138777c1b6996e709993362a7b0a12888ecf")` fetches that SHA.
- [ ] **Step 2: Run** `cd audit && mise exec -- bundle exec rake test` — expect failures (missing constants).
- [ ] **Step 3: Implement** Gemfile (`minitest`, `rake`, `standard`), Rakefile (same shape as `mcp/Rakefile`: test + standard default), `Shell` on `Open3.capture3`, `Workspace#sync`, `CLI.start` with `workspace`; `exe/shadcn-audit` = `require_relative "../lib/shadcn_audit"; ShadcnAudit::CLI.start(ARGV, out: $stdout)`, executable bit set.
- [ ] **Step 4: Run** `cd audit && mise exec -- bundle install && mise exec -- bundle exec rake` — green. Then smoke: `cd audit && mise exec -- bundle exec exe/shadcn-audit workspace --sha 8f04138777c1b6996e709993362a7b0a12888ecf` prints `{"shadcn_sha":"8f04138777c1b6996e709993362a7b0a12888ecf",...}` and `../.shadcn-audit/ui/apps/v4/registry/styles/style-vega.css` exists. `git status` shows nothing under `.shadcn-audit/`.
- [ ] **Step 5: Commit** `[Feature] Add audit subproject with shadcn workspace sync`

### Task 3: Component map and divergences

**Files:**
- Create: `audit/component_map.yml`, `audit/divergences.yml`, `audit/lib/shadcn_audit/component_map.rb`, `audit/lib/shadcn_audit/divergences.rb`, `audit/test/component_map_test.rb`, `audit/test/divergences_test.rb`

**Interfaces:**
- `component_map.yml`, keyed by RubyUI folder:
  ```
  dialog:
    shadcn: dialog          # bases/base/ui/<shadcn>.tsx; null = no shadcn equivalent
    kind: modal             # modal | menu | popover | disclosure | form_control | static
    docs_view: dialog
    parts: {Dialog: dialog, DialogTrigger: dialog-trigger, DialogContent: dialog-content, ...}  # RubyUI class => data-slot
    props: {DialogContent: {showCloseButton: null, size: size}}  # shadcn prop => RubyUI kwarg; null = none
  ```
  Seed entries: `dialog`, `alert_dialog`, `sheet`, `command` (CommandDialog parts map to shadcn `command.tsx`'s dialog parts), filled from the real `.tsx` files and `gem/lib/ruby_ui/<folder>/*.rb`.
- `divergences.yml`: list of `{component:, dimension:, rubyui:, shadcn:, reason:, since:}`. Seed: `{component: dialog, dimension: HTML, rubyui: "<dialog> + showModal()", shadcn: "<div role=\"dialog\">", reason: "Native modal dialog: the browser provides inert, Esc and focus handling.", since: "2026-10-26"}`.
- Produces: `ShadcnAudit::ComponentMap.load(path) ` with `#entry(folder) -> Hash|nil`, `#folder_for_path(path) -> String|nil`, `#folder_for_name(name) -> String|nil` (CamelCase or snake), `#all_folders -> [String]`, `#suggest_entry(folder) -> String` (YAML stub for an unmapped folder, with `shadcn:` guessed by dasherizing). `ShadcnAudit::Divergences.load(path)#find(component:, dimension:) -> Hash|nil`, `#suggest(component:, dimension:, rubyui:, shadcn:) -> String` (YAML ready to paste, `reason: TODO`).
- Validation: `load` raises `ShadcnAudit::ConfigError` naming the entry for an unknown `kind`, a missing `reason`, or an unknown `dimension` (`Look HTML Props ARIA Behavior Animation Native`).

- [ ] **Step 1: Write failing tests:** map lookups (`folder_for_path("gem/lib/ruby_ui/sheet/sheet_content.rb") == "sheet"`, `folder_for_name("CommandDialog") == "command"`), `test_unmapped_folder_returns_nil_and_suggests_entry`, `test_unknown_kind_raises`, divergences `find` hit/miss, `test_divergence_without_reason_raises`, `test_seed_files_load` (the real `audit/*.yml` load without error and every seeded `shadcn:` file exists in the test fixture list or is null).
- [ ] **Step 2: Run** — fail.
- [ ] **Step 3: Implement**; CLI `map <folder>` (prints entry or `{"missing":true,"suggestion":...}`) and `divergences <folder>`.
- [ ] **Step 4: Run** `bundle exec rake` — green.
- [ ] **Step 5: Commit** `[Feature] Add audit component map and divergences registry`

### Task 4: Target resolution

**Files:**
- Create: `audit/lib/shadcn_audit/target.rb`, `audit/test/target_test.rb`

**Interfaces:**
- Consumes: `Shell`, `ShadcnAudit::ComponentMap` (Task 3: `#folder_for_path`, `#folder_for_name`, `#all_folders`; tests may pass a small stub with those methods).
- Produces: `ShadcnAudit::Target.resolve(arg, shell:, map:) -> Hash` with keys `"kind"` (`"pr"|"branch"|"component"`), `"repo"` (`"ruby-ui/ruby_ui"`), `"pr"` (Integer|nil), `"base_sha"`, `"head_sha"`, `"changed_files"` ([String]), `"components"` ([folder names]), `"needs_selection"` (Boolean), `"candidates"` ([folder names]).
  - Integer arg → `gh pr view <n> --repo ruby-ui/ruby_ui --json headRefOid,baseRefOid,files,state`; then `git fetch origin refs/pull/<n>/head` so fork heads are local.
  - Other arg that is a mapped folder (or its CamelCase component name) → `kind: "component"`, base and head = `git rev-parse origin/main`, components `[folder]`.
  - Otherwise a branch → head `git rev-parse <branch>`, base `git merge-base origin/main <branch>`, files `git diff --name-only <base>...<head>`.
  - Shared paths: `gem/lib/ruby_ui/base.rb`, `gem/lib/ruby_ui.rb`, `gem/lib/generators/**`, `docs/app/assets/stylesheets/application.tailwind.css`. If no component folder is touched but a shared path is → `needs_selection: true`, `candidates: map.all_folders`.
- Produces: `ShadcnAudit::Target.head_sha_for_pr(n, shell:) -> String` (used by Task 9).

- [ ] **Step 1: Write failing tests:**
  - `test_pr_resolves_shas_and_components`: FakeShell returns `gh` JSON with files `gem/lib/ruby_ui/dialog/dialog_content.rb`, `gem/test/ruby_ui/sheet_test.rb`, `mcp/data/registry.json` → components `["dialog", "sheet"]`, `needs_selection` false, SHAs as given.
  - `test_pr_fetches_pull_ref_for_fork_heads`: shell received `git fetch origin refs/pull/572/head`.
  - `test_shared_only_change_asks_for_selection`: files `["gem/lib/ruby_ui/base.rb"]` → `components: []`, `needs_selection: true`, `candidates` == stub's `all_folders`.
  - `test_component_name_arg`: `"AlertDialog"` and `"alert_dialog"` both → `kind: "component"`, `components: ["alert_dialog"]`.
  - `test_docs_view_and_controller_paths_map_to_folder`: `docs/app/views/docs/alert_dialog.rb` → `alert_dialog`.
- [ ] **Step 2: Run** `cd audit && mise exec -- bundle exec rake test TEST=test/target_test.rb` — fail.
- [ ] **Step 3: Implement** `Target.resolve` and `head_sha_for_pr`; add CLI subcommand `target <arg>`.
- [ ] **Step 4: Run** tests — pass; `bundle exec rake` green.
- [ ] **Step 5: Commit** `[Feature] Resolve audit targets to pinned SHAs and components`

### Task 5: Reference extraction (Base UI `.tsx` + vega)

**Files:**
- Create: `audit/lib/shadcn_audit/reference.rb`, `audit/test/reference_test.rb`, `audit/test/fixtures/registry/bases/base/ui/dialog.tsx`, `audit/test/fixtures/registry/bases/base/ui/button.tsx`, `audit/test/fixtures/registry/styles/style-vega.css` (trimmed copies from shadcn `8f04138` — only the rules the tests use)

**Interfaces:**
- Consumes: workspace path from Task 2.
- Produces: `ShadcnAudit::Reference.new(registry_dir:, style: "vega")#for(shadcn_name) -> Hash`:
  ```
  {"file" => "bases/base/ui/dialog.tsx", "style_file" => "styles/style-vega.css",
   "parts" => {"dialog-content" => {"function" => "DialogContent", "inline" => [...], "cn" => ["cn-dialog-content"],
                                    "resolved" => [...], "effective" => [...], "props" => ["showCloseButton"]}},
   "variants" => {"buttonVariants" => {"variant" => {"default" => [...]}, "size" => {...}}},
   "unresolved" => ["cn-foo"], "missing" => false}
  ```
  `effective` = inline (minus `cn-*` tokens) + resolved, order kept, duplicates dropped. A part is keyed by its `data-slot`. `props` = destructured names in the function signature other than `className`, `children`, `...props`. `missing: true` (and empty parts) when the `.tsx` doesn't exist. `cn-*` rules are read from `.cn-x { @apply ...; }` blocks in the style file; a referenced `cn-*` with no rule goes to `unresolved`.

- [ ] **Step 1: Write failing tests:**
  - `test_dialog_content_effective_classes`: `effective` for `dialog-content` includes `"fixed"`, `"top-1/2"`, `"rounded-xl"`, `"p-6"`, `"gap-6"`, `"ring-1"`, `"ring-foreground/10"`, `"sm:max-w-md"`, and not `"cn-dialog-content"`.
  - `test_dialog_content_props`: `props` == `["showCloseButton"]`.
  - `test_dialog_overlay_effective_classes`: includes `"bg-black/10"` and `"supports-backdrop-filter:backdrop-blur-xs"`.
  - `test_unresolved_cn_class_is_reported`: with a fixture `.tsx` referencing `cn-dialog-ghost` absent from the CSS → `unresolved` == `["cn-dialog-ghost"]`.
  - `test_button_cva_variants`: `variants["buttonVariants"]["variant"]["default"]` is non-empty and `variants["buttonVariants"]["size"]` has key `"default"`.
  - `test_missing_component`: `for("no-such")` → `missing: true`, `parts: {}`.
- [ ] **Step 2: Run** — fail.
- [ ] **Step 3: Implement** with string scanning, no JS parser: split the file into `function Name(` … blocks; within each, find `data-slot="…"` and the string literals inside the nearest `cn(`/`className=` call; parse `cva(` second-argument `variants: { key: { name: "classes" } }` by brace matching. CLI subcommand `reference <shadcn_name>` (registry dir = `.shadcn-audit/ui/apps/v4/registry`).
- [ ] **Step 4: Run** tests — pass. Smoke against the real clone: `exe/shadcn-audit reference dialog` lists parts `dialog-overlay`, `dialog-content`, `dialog-header`, `dialog-footer`, `dialog-title`, `dialog-description`, `unresolved` empty.
- [ ] **Step 5: Commit** `[Feature] Extract effective shadcn classes from Base UI + vega`

### Task 6: Theme comparison

**Files:**
- Create: `audit/lib/shadcn_audit/theme.rb`, `audit/test/theme_test.rb`, `audit/test/fixtures/registry/themes.ts` (neutral entry only), `audit/test/fixtures/application.tailwind.css`

**Interfaces:**
- Produces: `ShadcnAudit::Theme.compare(themes_ts:, rubyui_css:, name: "neutral") -> {"status" => "pass"|"fail", "diffs" => [{"mode" => "light"|"dark", "token" => String, "rubyui" => String|nil, "shadcn" => String}]}`. Reads the `name: "neutral"` entry's `cssVars.light` / `cssVars.dark` from `themes.ts` and `--token: value;` from `:root { }` / `.dark { }` in the CSS. Only tokens shadcn defines are compared; values compared after whitespace normalization.

- [ ] **Step 1: Write failing tests:** `test_identical_tokens_pass`; `test_changed_dark_token_is_reported` (fixture CSS with `.dark --popover: oklch(0.3 0 0)` → one diff `{"mode"=>"dark","token"=>"popover",...}`); `test_missing_token_is_reported` (`rubyui` nil).
- [ ] **Step 2: Run** — fail.
- [ ] **Step 3: Implement**; CLI `theme [--checkout DIR]` (RubyUI CSS from `<checkout>/docs/app/assets/stylesheets/application.tailwind.css`, default repo root).
- [ ] **Step 4: Run** tests — pass. Smoke on the real repo; record whatever diffs appear (they are real findings, don't "fix" them here).
- [ ] **Step 5: Commit** `[Feature] Compare RubyUI tokens with shadcn neutral theme`

### Task 7: shadcn sandbox (Base UI + vega + neutral, docs-parity environment)

**Files:**
- Create: `audit/lib/shadcn_audit/sandbox.rb`, `audit/test/sandbox_test.rb`
- Create: `audit/fixtures/<folder>/content.yml`, `audit/fixtures/<folder>/shadcn.tsx`, `audit/fixtures/<folder>/rubyui.rb` for `dialog`, `alert_dialog`, `sheet`, `command`
- Create: `audit/sandbox_template/` (files copied over the shadcn-generated app: `src/main.tsx`, `src/parity.css`, `index.html`)

**Interfaces:**
- Fixture contract: `content.yml` holds every visible string (`trigger`, `title`, `description`, `body`, `cancel`, `action`). `shadcn.tsx` default-exports a component rendering the shadcn version with those strings; `rubyui.rb` defines `ShadcnAuditFixtures::<Camel>` (Phlex view) rendering the RubyUI version with the same strings. Both put `data-audit-trigger` on the element that opens the component.
- Produces: `ShadcnAudit::Sandbox.new(shell:, dir:)#prepare -> {"path", "url_template" => "http://localhost:5179/?c={folder}&theme={light|dark}", "lock" => {"shadcn" => ver, "@base-ui/react" => ver, ...}, "created" => Boolean}`.
  - First run: `pnpm dlx shadcn@<pinned> init` with base `base`, style `vega`, base color `neutral`, template `vite`, into `dir/sandbox` (look up the exact non-interactive flags with `pnpm dlx shadcn@<pinned> init --help` and pin the CLI version in `audit/sandbox.yml`); then `shadcn add` the components named by `component_map.yml`'s `shadcn:` values; then copy `sandbox_template/` and every `fixtures/*/shadcn.tsx`.
  - Later runs: re-copy fixtures; reinstall only when `audit/sandbox.yml`'s pinned versions change.
  - Parity (`src/parity.css`): Inter loaded, `@plugin "@tailwindcss/forms"`, `@plugin "@tailwindcss/typography"`, `@import "tw-animate-css"`, and the same `body` base rule as `docs/app/assets/stylesheets/application.tailwind.css:160`; fixed viewport is set by the skill when driving the browser (1280×800).
  - `main.tsx` reads `?c=` and `?theme=` and renders that fixture, toggling `.dark` on `<html>`.
  - `lock` = versions read from the sandbox's `pnpm-lock.yaml`/`package.json`.

- [ ] **Step 1: Write failing tests** (FakeShell, no network): `test_first_prepare_runs_init_with_base_vega_neutral` (init argv contains the base/style/color values), `test_adds_components_from_map`, `test_copies_fixtures_and_parity_css`, `test_second_prepare_skips_init`, `test_fixture_strings_match` (for every `audit/fixtures/*`, each `content.yml` value appears literally in both `shadcn.tsx` and `rubyui.rb`).
- [ ] **Step 2: Run** — fail.
- [ ] **Step 3: Implement** `Sandbox#prepare`, the template and the four fixtures; CLI `sandbox`.
- [ ] **Step 4: Verify** unit tests pass; then real run: `exe/shadcn-audit sandbox`, `cd .shadcn-audit/sandbox && pnpm dev --port 5179`, open `http://localhost:5179/?c=dialog&theme=light`, click the trigger: overlay computed `background-color` is `oklab(0 0 0 / 0.1)` and content has `rounded-xl`/`p-6` (vega, not nova's `p-4`); `components.json` names base `base` and style vega.
- [ ] **Step 5: Commit** `[Feature] Scaffold the shadcn Base UI + vega sandbox with shared fixtures`

### Task 8: RubyUI preview at a pinned SHA

**Files:**
- Create: `audit/lib/shadcn_audit/rubyui_preview.rb`, `audit/test/rubyui_preview_test.rb`
- Create: `audit/preview_overlay/docs/config/initializers/zz_shadcn_audit.rb`, `audit/preview_overlay/docs/app/controllers/shadcn_audit_fixtures_controller.rb`

**Interfaces:**
- Consumes: `Target` SHAs (Task 4), `audit/fixtures/*/rubyui.rb` (Task 7).
- Produces: `ShadcnAudit::RubyuiPreview.new(shell:, dir:)#prepare(sha) -> {"path" => ".shadcn-audit/checkouts/<sha>", "url_template" => "http://localhost:3179/__audit/{folder}?theme={light|dark}", "boot" => [String]}`.
  - Extracts the tree with `git archive <sha> | tar -x -C <path>` (symlinks preserved; no git worktree).
  - Copies `preview_overlay/` and `audit/fixtures/*/rubyui.rb` (to `docs/app/views/shadcn_audit_fixtures/`) into the checkout. The initializer does `Rails.application.routes.prepend { get "__audit/:component", to: "shadcn_audit_fixtures#show" }` only when `Rails.env.development?`; the controller renders the fixture view inside the docs layout's stylesheet/JS (no docs chrome) and sets `.dark` from `?theme=`.
  - `boot` lists, in order: `mise exec -- bundle install`, `pnpm install`, `pnpm build`, `pnpm build:css`, `mise exec -- bin/rails db:prepare`, `mise exec -- bin/rails server -p 3179` (all with `chdir: <path>/docs`). The skill runs the last one in a separate Herdr pane.
  - Never touches the main working tree.

- [ ] **Step 1: Write failing tests:** `test_archives_exact_sha` (shell got `git archive a9a5d1fa…`), `test_overlay_and_fixtures_copied`, `test_existing_checkout_is_reused`, `test_boot_commands_in_order`.
- [ ] **Step 2: Run** — fail.
- [ ] **Step 3: Implement**; CLI `preview <sha>`.
- [ ] **Step 4: Verify** real run at PR #572's head: boot, open `http://localhost:3179/__audit/dialog?theme=light`, click `[data-audit-trigger]`: the `<dialog>` opens and `getComputedStyle(dialog, "::backdrop").backgroundColor` reflects `bg-black/10`. `git status` of the main tree is clean.
- [ ] **Step 5: Commit** `[Feature] Serve RubyUI fixtures from an archived checkout at the audited SHA`

### Task 9: Report rendering and PR comment

**Files:**
- Create: `audit/lib/shadcn_audit/report.rb`, `audit/lib/shadcn_audit/renderers/terminal.rb`, `audit/lib/shadcn_audit/renderers/html.rb`, `audit/lib/shadcn_audit/renderers/markdown.rb`, `audit/lib/shadcn_audit/renderers/report.html.erb`, `audit/lib/shadcn_audit/pr_comment.rb`
- Create: `audit/test/report_test.rb`, `audit/test/renderers_test.rb`, `audit/test/pr_comment_test.rb`, `audit/test/fixtures/report_572.json`

**Interfaces:**
- `report.json` schema (written by the skill, validated here):
  ```
  {"target": <Target hash>, "shadcn_sha": String, "sandbox_lock": Hash, "environment_diffs": [String],
   "theme": <Theme.compare hash>,
   "components": [{"folder": String, "shadcn_file": String|null,
     "lines": [{"dimension": "Look|HTML|Props|ARIA|Behavior|Animation|Native|Spec",
                "status": "pass|warn|fail|inconclusive", "basis": null|"intentional|native|spec",
                "rubyui": String, "shadcn": String, "source": String, "note": String}],
     "screenshots": [{"state": String, "rubyui": path, "shadcn": path}]}]}
  ```
- Produces: `ShadcnAudit::Report.load(path) -> Report` (raises `ShadcnAudit::ReportError` on schema violations: unknown status/dimension/basis, `basis` on a non-pass line, `pass` without `source`, `fail`/`warn` on a Spec line without an `http` source); `Report#components`, `#header`.
- Produces: `Renderers::Terminal.render(report) -> String` (format of design §A: header with the four SHAs, then `environment_diffs` (each as a ⚠️ "environment" line, before any component), theme line, one block per component, symbols ✅ ⚠️ ❌ ⏸, basis shown as `— intentional`/`— native`/`— follows spec`); `Renderers::Markdown.render(report) -> String` (same content as a fenced block + header table, first line `<!-- shadcn-audit -->`); `Renderers::Html.render(report, out_dir:) -> path` (only components that have screenshots and at least one non-pass Look/Behavior/Animation line; pairs side by side with that component's lines underneath; writes `report.html` in `out_dir`).
- Produces: `ShadcnAudit::PrComment.new(shell:)#upsert(pr:, body:, expected_head_sha:) -> {"action" => "created"|"updated"|"refused", "url" => String|nil, "reason" => String|nil}`. Reads current head via `Target.head_sha_for_pr`; if it differs → `refused`. Lists comments with `gh api repos/ruby-ui/ruby_ui/issues/<pr>/comments --paginate`, picks the first whose body contains `<!-- shadcn-audit -->`, PATCHes it, else POSTs. CLI `render <report.json> [--html]` and `comment <report.json> --post` (without `--post` it only prints the body; the skill shows that body to Cirdes and calls `--post` only after his ok).

- [ ] **Step 1: Write failing tests:**
  - `report_test`: valid `report_572.json` loads; `test_basis_on_fail_rejected`; `test_spec_finding_without_url_rejected`; `test_pass_without_source_rejected`.
  - `renderers_test`: terminal output for `report_572.json` contains `Dialog`, `❌ Look`, `vega: p-6 gap-6 ring-1`, `⏸`, the head SHA `a9a5d1fa`; markdown starts with `<!-- shadcn-audit -->`; HTML lists `dialog` but not a component whose lines are all pass.
  - `pr_comment_test`: `test_creates_when_no_marked_comment`, `test_updates_existing_marked_comment_even_if_edited` (body `"edited by hand\n<!-- shadcn-audit -->..."` → PATCH to its id), `test_refuses_when_head_moved` (no POST/PATCH issued, `reason` mentions both SHAs).
- [ ] **Step 2: Run** — fail.
- [ ] **Step 3: Implement** the four classes, ERB template (self-contained HTML, images referenced relatively from the run folder), CLI subcommands.
- [ ] **Step 4: Run** `bundle exec rake` — green. Render `report_572.json` in the terminal and eyeball against design §A.
- [ ] **Step 5: Commit** `[Feature] Render audit reports and upsert the PR checklist comment`

### Task 10: The skill

**Files:**
- Create: `.claude/skills/shadcn-audit/SKILL.md`
- Create: `.claude/skills/shadcn-audit/references/grading.md`, `references/interactions.md`, `references/spec-sources.md`, `references/native-html.md`

**Interfaces:**
- Consumes: every CLI subcommand above; chrome-devtools MCP; the Herdr skill for long-running servers.
- `SKILL.md` frontmatter: `name: shadcn-audit`; description says when to use it (auditing a RubyUI PR, branch or component against shadcn; "compara com o shadcn", "audita esse PR") and when not (general code review → `code-review`; writing Stimulus → `ruby-ui-stimulus`).
- Body = the run order, each step naming the CLI call and what to do with its JSON:
  1. `target <arg>`; if `needs_selection`, list `candidates` and ask which to audit.
  2. `workspace` (record SHA), `sandbox`, `preview <head_sha>`; boot both servers in a Herdr pane each.
  3. Per component: `map`, `reference`, `divergences`; unmapped → line `inconclusive` + `suggest_entry` shown to the user. Props inherited from the `@base-ui/react` primitive (not declared in the `.tsx`) are read from `.shadcn-audit/sandbox/node_modules/@base-ui/react/<primitive>/**/*.d.ts` at the version in `sandbox.lock`.
  4. Look: compare `effective` classes per part with the classes on the RubyUI fixture's DOM (`evaluate_script`), light and dark.
  5. HTML/ARIA/Behavior/Animation: run `references/interactions.md`'s set for the component's `kind` on both URLs at 1280×800; read the DOM, `document.activeElement`, `inert`/`aria-hidden`, computed styles; take screenshots per state into the run folder. Anything not reachable → `inconclusive` with the reason.
  6. Native: apply `references/native-html.md`.
  7. Spec: check the shadcn side's observed HTML/ARIA/behavior against `references/spec-sources.md`; grade per `references/grading.md` (spec beats shadcn; native replacements pass when behavior/ARIA kept; registered divergences pass as intentional).
  8. Write `report.json`, `render` (always), `render --html` (when it renders anything) and open it; show the `comment` body; post with `--post` only after an explicit ok, and report `refused` if the head moved.
- `grading.md`: the status/basis rules from Global Constraints + design "Grading rules", with the #572 lines as worked examples.
- `interactions.md`: the modal set from the design (open, initial focus, Tab/Shift+Tab, Esc, outside click, focus return, scroll lock, exit animation; light/dark) plus sets for `menu`, `popover`, `disclosure`, `form_control`, `static` (static = render + Look only).
- `spec-sources.md`: the three weights with base URLs (HTML Living Standard, WAI-ARIA 1.2, ARIA in HTML, APG, MDN pt-BR/en-US) and the "cite section + unmet condition" rule. React Aria (`.shadcn-audit/ui/apps/v4/registry/bases/aria/ui/`) is consulted only as a second opinion when the Base UI side looks wrong; disagreements are settled by the normative spec, never by picking a library.
- `native-html.md`: table of hand-rolled behavior → native feature with MDN link (`<dialog>`/`showModal()`, `popover` attribute, `<details>`/`<summary>`, `inert`, `:user-invalid`, `<input type=…>` pickers, `hidden="until-found"`), and how to tell when native would lose behavior shadcn provides.

- [ ] **Step 1: Write the four references and `SKILL.md`** as specified.
- [ ] **Step 2: Verify triggering**: in a fresh Claude Code session in the repo, "audita o PR 572 contra o shadcn" loads `shadcn-audit`; "revisa esse diff" does not.
- [ ] **Step 3: Commit** `[Feature] Add the shadcn-audit skill`

### Task 11: Prevention in AGENTS.md / CLAUDE.md

**Files:**
- Modify: `gem/AGENTS.md` (new `## shadcn reference` section after `## Project Overview`, line 14-21)
- Modify: `CLAUDE.md` (root: a line under `## Conventions` and one under `## Don'ts`)
- Modify: `audit/README.md` (how to bootstrap without Claude: `cd audit && mise exec -- bundle install && mise exec -- bundle exec exe/shadcn-audit workspace`)

**Interfaces:** none.

- [ ] **Step 1: Write the `gem/AGENTS.md` section**, for any agent (not only Claude): the reference (Base UI `bases/base/ui/<name>.tsx` + vega `cn-*` rules + neutral theme; not new-york-v4, not ui.shadcn.com); where to read it (local `.shadcn-audit/ui` after `exe/shadcn-audit workspace`, or raw URLs `https://raw.githubusercontent.com/shadcn-ui/ui/main/apps/v4/registry/bases/base/ui/<name>.tsx` and `.../styles/style-vega.css`); prefer native HTML over JS (link `references/native-html.md`); `audit/divergences.yml` for deliberate differences, registered in the same PR; port behavior from Base UI/React Aria, never copy their source; run `/shadcn-audit` (or the CLI) before opening a component PR.
- [ ] **Step 2: Root `CLAUDE.md`:** Conventions → "Components mirror shadcn Base UI + vega; see `gem/AGENTS.md#shadcn-reference`." Routing table → `audit/` row ("shadcn fidelity audit tooling; skill in `.claude/skills/shadcn-audit/`"). Don'ts → "Don't use ui.shadcn.com or new-york-v4 as the reference."
- [ ] **Step 3: Verify** `grep -n "shadcn" CLAUDE.md gem/AGENTS.md` shows the new lines; links resolve to existing paths.
- [ ] **Step 4: Commit** `[Documentation] Point agents at the shadcn Base UI + vega reference`

### Task 12: Acceptance run on PR #572

**Files:**
- Create: `audit/test/fixtures/acceptance_572.md` (the expected-findings list below, for future comparison)

- [ ] **Step 1: Run** `/shadcn-audit 572` with the pins (`workspace --sha 8f04138777c1b6996e709993362a7b0a12888ecf`; target head `a9a5d1faee2257e8e83c144a5be88c378347640d`). If the PR's head has moved, archive that SHA explicitly with `preview a9a5d1fa…`.
- [ ] **Step 2: Check the checklist** contains, unprompted:
  - Dialog: overlay ✅ (`bg-black/10` + blur matches vega); Look ❌ (border/shadow-lg/rounded-lg/gap-4/max-w-lg vs ring-1/rounded-xl/gap-6/sm:max-w-md); Animation ⚠️ (no exit fade); HTML ✅ intentional/native; ARIA ⚠️ (no `aria-labelledby`/`aria-describedby`).
  - AlertDialog, Sheet, CommandDialog: Native ❌ (`<div>` + JS, candidate for `<dialog>`), each citing MDN.
  - Theme line present; header carries the four SHAs.
- [ ] **Step 3: Check the HTML page** opens with side-by-side screenshots for the four modals (open, light and dark).
- [ ] **Step 4: Check the comment flow**: `comment` prints the body starting with `<!-- shadcn-audit -->`; do **not** post unless Cirdes says so.
- [ ] **Step 5:** Any expected line missing → fix the owning task, re-run. Commit `acceptance_572.md` with `[Feature] Record shadcn-audit acceptance expectations for #572`.
