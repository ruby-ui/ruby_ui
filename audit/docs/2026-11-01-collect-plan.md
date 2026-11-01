# shadcn-audit `collect` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A `collect` subcommand that drives both fixtures in Chromium through playwright-ruby-client, collects computed styles, accessibility facts, screenshots and pixel diffs per state, and grades the objective Look/ARIA lines deterministically.

**Architecture:** A browser-free core (`Collect::Normalize`, `Collect::Grader`, `Collect::PixelDiff`) fed by a thin Playwright layer (`Collect::Driver`) and glued by `Collect::Runner`. The core is unit-tested with plain hashes; the driver gets a smoke test against local HTML files that skips when Chromium isn't installed. `ComponentMap` gains `selectors`, `Divergences` gains `match`.

**Tech Stack:** Ruby 3.4 (mise), Minitest, StandardRB, playwright-ruby-client 1.64.0 + Node `playwright` 1.64.1 (pnpm, in `audit/`), chunky_png 1.4.0.

**Spec:** `audit/docs/2026-11-01-collect-design.md`

## Global Constraints

- Every subcommand prints exactly one JSON object; failures are `{"error": …}` + exit 1 via `CLI::ERRORS`.
- Run from `audit/`: `mise exec -- bundle exec …`. `bundle exec rake` (tests + standardrb) must pass after every task.
- Viewport fixed at **1280×800**, DPR 1, Chromium headless only.
- Pixel diff is evidence only: it never sets a line's `status`.
- ARIA differences grade `warn`; Look differences `fail`; registered (structured `match`) → `pass` basis `intentional`; theme/environment-explained or unreachable → `inconclusive`. Nothing unverified is `pass`.
- Lines use `report.json` line shape: `dimension, status, basis, rubyui, shadcn, source, note`. Every `pass`/`warn`/`fail` has a non-empty `source`.
- Line granularity: one line per part per outcome; all fully matching parts grouped into one `pass` line per dimension. State/theme go in `note`.
- Screenshot names: `screens/<folder>-<state>-<rubyui|shadcn>-<light|dark>.png`; diff images `screens/<folder>-<state>-diff-<light|dark>.png`. Paths in output are relative to the run folder.
- Local only: CI keeps running unit tests; nothing browser-bound runs there.
- Never run anything from `.shadcn-audit/ui`.

## Review Focus

1. **Repeated parts with mismatched counts** (accordion items: 3 on shadcn, 2 visible on RubyUI): the part is `inconclusive` "selector matched 2/3 visible elements in open/light", never compared index-by-index. → Task 3 test.
2. **Hidden-but-present elements** (RubyUI keeps closed content in the DOM, Base UI unmounts it): only visible elements (`checkVisibility()`) are counted and collected. → Task 6 smoke test.
3. **Missing trigger, page error, navigation timeout**: the state is `reached: false` with the reason and the run continues; lines become `inconclusive`. → Task 6 smoke test + Task 7 runner test.
4. **Playwright/Chromium not installed**: `collect` returns `{"error": "…run `pnpm install && pnpm exec playwright install chromium` in audit/"}`, not a backtrace. → Task 7 CLI test.
5. **Order stability**: the same observations in a different hash/array order produce byte-identical `lines`. → Task 3 test.

---

### Task 1: Dependencies and `selectors` in the component map

**Files:**
- Modify: `audit/Gemfile` (+ `Gemfile.lock`), `audit/.gitignore`, `audit/lib/shadcn_audit/component_map.rb`
- Create: `audit/package.json`, `audit/pnpm-lock.yaml`
- Test: `audit/test/component_map_test.rb`

**Interfaces:**
- Produces: `entry(folder)["selectors"]` → `Hash{String part => String css}` (may be absent). `ComponentMap#selectors(folder) -> Hash` (empty hash when absent).

- [ ] **Step 1: Write failing tests** in `component_map_test.rb`:
  - `test_selectors_are_returned`: entry with `parts: {DialogContent: dialog-content}`, `selectors: {DialogContent: "dialog > div"}` → `map.selectors("dialog") == {"DialogContent" => "dialog > div"}`.
  - `test_selectors_default_to_empty`: no `selectors` key → `{}`.
  - `test_selector_for_unknown_part_is_rejected`: `selectors: {Nope: "div"}` → `ConfigError` matching `/selectors.Nope is not a mapped part/`.
  - `test_blank_selector_is_rejected`: `selectors: {DialogContent: " "}` → `ConfigError` matching `/selectors.DialogContent must be a non-empty CSS selector/`.
- [ ] **Step 2: Run** `mise exec -- bundle exec rake test TEST=test/component_map_test.rb` → the four fail.
- [ ] **Step 3: Implement** validation in `ComponentMap#validate!` and `#selectors(folder)`. Update the header comment of `component_map.yml` with one line: `# selectors: RubyUI class => CSS selector of that part in the rendered fixture (fixed, so collect is deterministic).`
- [ ] **Step 4: Add dependencies**: Gemfile `gem "playwright-ruby-client", "1.64.0"` and `gem "chunky_png", "1.4.0"`; `bundle install`. `audit/package.json` `{"private": true, "devDependencies": {"playwright": "1.64.1"}}`; `pnpm install`. `.gitignore` += `/node_modules/`.
- [ ] **Step 5: Run** `mise exec -- bundle exec rake` → all pass, standardrb clean.
- [ ] **Step 6: Commit** `[Feature] shadcn-audit: selectors in component map + playwright deps`.

### Task 2: Structured `match` keys in divergences

**Files:**
- Modify: `audit/lib/shadcn_audit/divergences.rb`, `audit/divergences.yml` (header comment only)
- Test: `audit/test/divergences_test.rb`

**Interfaces:**
- Produces: `Divergences#match(component:, dimension:, part:, key:, rubyui:, shadcn:) -> Hash | nil` — returns the entry whose `match` equals `{part, property|attribute: key, rubyui, shadcn}` after `Collect::Normalize.value` on both values (Task 3 defines it; until then compare `strip` — Task 3 swaps it in). Never matches entries without `match`.

Entry shape:
```yaml
- component: dialog
  dimension: Look            # Look → property; ARIA → attribute
  rubyui: "border 1px"
  shadcn: "ring 1px"
  reason: "…"
  since: "2026-11-01"
  match: {part: DialogContent, property: border-top-width, rubyui: "1px", shadcn: "0px"}
```
`attribute` may be `snapshot` to match the whole accessibility snapshot of the part.

- [ ] **Step 1: Write failing tests**:
  - `test_match_finds_structured_entry`: entry above → `match(component: "dialog", dimension: "Look", part: "DialogContent", key: "border-top-width", rubyui: "1px", shadcn: "0px")` returns it.
  - `test_match_ignores_prose_only_entries`: same component/dimension without `match` → `nil`.
  - `test_match_requires_exact_values`: `rubyui: "2px"` → `nil`.
  - `test_match_validation`: `match` on dimension `HTML` → `ConfigError` `/match is only for Look or ARIA/`; Look with `attribute` → `/Look match needs property/`; missing `rubyui` → `/match needs part, property\|attribute, rubyui and shadcn/`.
  - `test_existing_registry_still_loads`: `Divergences.load(ShadcnAudit.root.join("audit/divergences.yml"))` doesn't raise.
- [ ] **Step 2: Run** `rake test TEST=test/divergences_test.rb` → new tests fail.
- [ ] **Step 3: Implement** validation + `#match`. Header comment in `divergences.yml`: one line explaining `match`. The four existing entries are HTML/Behavior differences, not computed Look/ARIA values, so none gets a `match` (say so in the commit message).
- [ ] **Step 4: Run** `rake` → pass.
- [ ] **Step 5: Commit** `[Feature] shadcn-audit: machine-matchable divergences`.

### Task 3: Normalize + Look grading

**Files:**
- Create: `audit/lib/shadcn_audit/collect/normalize.rb`, `audit/lib/shadcn_audit/collect/grader.rb`
- Modify: `audit/lib/shadcn_audit.rb` (requires), `divergences.rb` (use `Normalize.value`)
- Test: `audit/test/collect/normalize_test.rb`, `audit/test/collect/grader_test.rb`

**Interfaces:**
- Consumes: `Divergences#match` (Task 2).
- Produces:
  - `Collect::Normalize.value(String) -> String`: downcase, collapse whitespace, every decimal number rounded to 2 places with trailing zeros dropped (`"0.6459"→"0.65"`, `"1.50px"→"1.5px"`).
  - `Collect::Grader.new(folder:, parts:, divergences:, theme_diffs:, environment_diff_keys:)` where `parts` is the ordered RubyUI part list from the map (`Array<String>`), `theme_diffs` is `theme["diffs"]`, `environment_diff_keys` is e.g. `["font"]`.
  - `Grader#lines(observations) -> Array<Hash>` in report line shape. `observations`: `Array<{"state"=>, "theme"=>, "rubyui"=>SideFacts, "shadcn"=>SideFacts}>`.
  - `SideFacts = {"reached"=>Bool, "reason"=>String|nil, "screenshot"=>String, "parts"=>{part=>[{"styles"=>{prop=>val}, "aria"=>String, "attrs"=>{name=>val|nil}}]}}`.
  - Constants: `Grader::FONT_PROPS = %w[font-family font-size font-weight line-height letter-spacing width height]`; `Grader::LOOK_SOURCE = "computed styles (shadcn-audit collect)"`; `Grader::ARIA_SOURCE = "accessibility tree (shadcn-audit collect)"`.

Look rules, per part, over every observation where both sides were reached:
1. Element counts differ → one `inconclusive` Look line for the part: note `"selector matched <r>/<s> visible elements in <state>/<theme>"` (first mismatch, then `; …` for others). Skip property comparison for that observation.
2. Per element index and property, values equal after `Normalize.value` → no diff.
3. Diff explained by theme: some `theme_diffs` entry with same `mode` as the observation's theme and normalized `rubyui`/`shadcn` equal to the observed values → bucket `theme` (note names the tokens).
4. Diff explained by environment: `environment_diff_keys` includes `"font"` and property ∈ `FONT_PROPS` → bucket `environment`.
5. `divergences.match(dimension: "Look", part:, key: property, …)` → bucket `intentional`.
6. Otherwise → bucket `diff`.

Output per part (in `parts` order), at most one line per non-empty bucket, in this order: `diff` → `fail` (`rubyui`/`shadcn` = `"prop: value"` joined by `"; "`, unique, sorted by property; note = the `state/theme` pairs where seen, joined `", "`); `intentional` → `pass` basis `intentional`, source `audit/divergences.yml`, note = reason; `theme`/`environment` → `inconclusive`, note `"explained by theme token(s) <t>"` / `"explained by environment diff: font"`. Parts with no lines at all → collected into one `pass` Look line: `rubyui` = `"<PartA>, <PartB>: computed styles match"`, `shadcn` = `"same"`, source `LOOK_SOURCE`.

- [ ] **Step 1: Write failing tests** (`normalize_test.rb`): the two examples above, `"  RGB(0, 0,  0) "→"rgb(0, 0, 0)"`, `"10px"` unchanged.
- [ ] **Step 2: Write failing tests** (`grader_test.rb`), each building observations by hand:
  - `test_matching_parts_group_into_one_pass_line`: two parts identical → exactly one line `{dimension: "Look", status: "pass", rubyui: "DialogContent, DialogTitle: computed styles match"}`.
  - `test_style_difference_is_fail_with_both_values`: `padding-top` `24px` vs `16px` in `open/light` and `open/dark` → one `fail` line, `rubyui: "padding-top: 24px"`, `shadcn: "padding-top: 16px"`, `note: "open/light, open/dark"`, source `LOOK_SOURCE`.
  - `test_count_mismatch_is_inconclusive`: 2 vs 3 elements → `inconclusive`, note `"selector matched 2/3 visible elements in open/light"`, and no `fail` for that part.
  - `test_theme_token_explains_difference`: `color` `oklch(0.646 0.222 41.116)` vs `oklch(0.809 0.105 251.813)` with theme diff `chart-1` light → `inconclusive`, note includes `chart-1`.
  - `test_font_environment_explains_typography_only`: env keys `["font"]`; `font-size` differs → `inconclusive`; `padding-top` differs → `fail`.
  - `test_structured_divergence_passes_as_intentional`: matching `match` entry → `pass` basis `intentional`, source `audit/divergences.yml`.
  - `test_output_is_order_independent` (Review Focus 5): shuffle observations and the styles hash key order → `lines` equal.
  - `test_unreached_observations_are_skipped_for_comparison`: rubyui `reached: false` → no Look lines from that observation (Task 4 adds the inconclusive line).
- [ ] **Step 3: Run** `rake test TEST=test/collect/grader_test.rb` → fail.
- [ ] **Step 4: Implement** `Normalize.value` and `Grader#lines` (Look only); switch `Divergences#match` to `Normalize.value`.
- [ ] **Step 5: Run** `rake` → pass.
- [ ] **Step 6: Commit** `[Feature] shadcn-audit: deterministic Look grading for collect`.

### Task 4: ARIA grading and unreachable states

**Files:**
- Modify: `audit/lib/shadcn_audit/collect/grader.rb`
- Test: `audit/test/collect/grader_test.rb`

**Interfaces:**
- Produces: `Grader#lines` also emits ARIA lines and unreachable lines. `Grader::ARIA_ATTRS = %w[aria-expanded aria-controls aria-haspopup aria-describedby modal]` (`modal` added in review: computed `:modal` or `aria-modal="true"`; `aria-labelledby` is covered by the name in the snapshot; the driver fills `attrs` with exactly these keys; `aria-controls` is reported as `"resolves"`/`"dangling"`/nil, `aria-describedby` as the referenced text or nil).

ARIA rules, per part, same count/skip logic as Look:
- `aria` (Playwright aria snapshot of the element) differs, compared exactly (hierarchy, case and numbers kept; `Normalize.value` is for Look only) → diff with key `snapshot`.
- Each `ARIA_ATTRS` value differs (incl. present vs nil) → diff with key = attribute.
- `divergences.match(dimension: "ARIA", part:, key:, …)` → `intentional`; theme/environment never apply to ARIA.
- Output like Look but `diff` bucket → `warn`; `rubyui`/`shadcn` = `"<key>: <value or (none)>"`, snapshots trimmed to 200 chars; grouped `pass` line `"<parts>: accessibility tree matches"`, source `ARIA_SOURCE`.

Unreachable: for each observation where a side has `reached: false` → one `inconclusive` line per dimension (Look, ARIA), deduplicated by reason, note `"<state>/<theme> not reached on <side>: <reason>"`, all observations sharing the same `state`+`side`+`reason` merged into one note.

- [ ] **Step 1: Write failing tests**:
  - `test_aria_snapshot_difference_is_warn`: snapshots `- button "Open" [expanded]` vs `- button "Open"` → `warn`, `rubyui` starts with `"snapshot: - button"`, source `ARIA_SOURCE`.
  - `test_missing_attribute_is_warn`: `aria-controls` `"resolves"` vs nil → `warn` with `shadcn: "aria-controls: (none)"`.
  - `test_matching_aria_groups_into_pass`.
  - `test_aria_divergence_by_attribute_is_intentional`.
  - `test_unreached_state_yields_inconclusive_look_and_aria`: rubyui `open/light` and `open/dark` unreached with reason `"no [data-audit-trigger]"` → exactly two lines (Look, ARIA), note `"open/light, open/dark not reached on rubyui: no [data-audit-trigger]"`.
- [ ] **Step 2: Run** → fail. **Step 3: Implement.** **Step 4: Run** `rake` → pass.
- [ ] **Step 5: Commit** `[Feature] shadcn-audit: ARIA and unreachable-state grading for collect`.

### Task 5: Pixel diff

**Files:**
- Create: `audit/lib/shadcn_audit/collect/pixel_diff.rb`
- Test: `audit/test/collect/pixel_diff_test.rb`

**Interfaces:**
- Produces: `Collect::PixelDiff.compare(rubyui_png:, shadcn_png:, diff_png:) -> {"pixels"=>Integer, "ratio"=>Float (6 decimals), "diff"=>String path}` or `{"error"=>"size 1280x800 vs 1280x720"}` when dimensions differ (no diff image written). `PixelDiff::CHANNEL_TOLERANCE = 16`: a pixel differs when any RGBA channel differs by more than 16. Diff image: differing pixels red (`#ff0000`), others the shadcn pixel at 25% alpha.

- [ ] **Step 1: Write failing tests** generating PNGs with `ChunkyPNG::Image.new(4, 4, …)` in `Dir.mktmpdir`: identical → `pixels: 0, ratio: 0.0`; one pixel off by 10 → `0`; one pixel off by 40 → `pixels: 1, ratio: 0.0625`, diff file exists; 4×4 vs 4×3 → `{"error" => "size 4x4 vs 4x3"}`.
- [ ] **Step 2: Run** → fail. **Step 3: Implement.** **Step 4: Run** `rake` → pass.
- [ ] **Step 5: Commit** `[Feature] shadcn-audit: pixel diff evidence for collect`.

### Task 6: Playwright driver

**Files:**
- Create: `audit/lib/shadcn_audit/collect/driver.rb`, `audit/lib/shadcn_audit/collect/probes.js`
- Test: `audit/test/collect/driver_smoke_test.rb`, `audit/test/fixtures/collect/{a,b}.html`

**Interfaces:**
- Produces:
  - `Collect::BrowserError < StandardError` (message used verbatim by the CLI).
  - `Collect::Driver.open(audit_dir:) { |driver| … }`: launches headless Chromium via `Playwright.create(playwright_cli_executable_path: <audit_dir>/node_modules/.bin/playwright)`; raises `BrowserError` with the install hint (Review Focus 4) when the CLI or browser is missing.
  - `Driver#environment(url) -> Hash` keys `w h dpr font fonts body forms dark` (the probe in `interactions.md`, `fonts` sorted).
  - `Driver#observe(url:, state:, selectors:, screenshot_path:) -> SideFacts` (shape in Task 3). `selectors` is `{part => css}`; the runner passes `[data-slot="<slot>"]` for shadcn.
  - `Driver::STATES = %w[closed open focus after-esc]`.

Behavior (fresh `page` per call, viewport 1280×800, `reduced_motion: "reduce"`):
- Navigate, wait for `load` (timeout 15 s); page error / timeout → `reached: false`, reason = message's first line.
- `closed`: nothing more. `open`: real `click` on `[data-audit-trigger]` (missing → `reached: false`, reason `"no [data-audit-trigger]"`). `focus`: press `Tab` up to 20 times until `document.activeElement` is or contains the trigger (else unreached `"trigger never received keyboard focus"`). `after-esc`: `open` then press `Escape`.
- Settle: await all `document.getAnimations()` `finished` (cap 2 s), then two `requestAnimationFrame`s.
- Per part: elements matching the selector **and** `checkVisibility()` (Review Focus 2); for each: computed styles for the property list in `Driver::STYLE_PROPS` (color, background-color, border-{top,right,bottom,left}-{width,style,color}, border-{top-left,top-right,bottom-right,bottom-left}-radius, box-shadow, outline-width, outline-style, outline-color, outline-offset, padding-{top,right,bottom,left}, gap, row-gap, column-gap, width, height, font-family, font-size, font-weight, line-height, letter-spacing, text-align, text-decoration-line, opacity, display, transform), `locator.aria_snapshot`, `attrs` per `Grader::ARIA_ATTRS` rules.
- Screenshot `page.screenshot(path:, animations: "disabled", caret: "hide")`; `screenshot` in facts is the path relative to the run folder (runner passes both).

- [ ] **Step 1: Write the smoke test** (skips with `skip "chromium not installed"` when `node_modules/.bin/playwright` is absent or `Driver.open` raises `BrowserError`), loading `file://` URLs of two fixtures: `a.html` has `<button data-audit-trigger aria-expanded=false aria-controls=p>` + `<div id=p class=part hidden>` toggled by inline JS; `b.html` has no trigger. Assertions:
  - `closed` on a: `reached: true`, `parts["Panel"]` is `[]` (hidden element not collected).
  - `open` on a: `parts["Panel"].size == 1`, `styles` has `"padding-top"`, `attrs` for the trigger part `{"aria-expanded"=>"true", "aria-controls"=>"resolves", …}`, screenshot file exists.
  - `open` on b: `reached: false`, reason `"no [data-audit-trigger]"`.
  - `observe` on `file:///nope.html`: `reached: false`, reason non-empty (Review Focus 3).
- [ ] **Step 2: Run** `pnpm exec playwright install chromium`, then `rake test TEST=test/collect/driver_smoke_test.rb` → fail (no Driver).
- [ ] **Step 3: Implement** `Driver` and `probes.js`.
- [ ] **Step 4: Run** → pass; `rake` → pass (smoke test also passes or skips).
- [ ] **Step 5: Commit** `[Feature] shadcn-audit: Playwright driver for collect`.

### Task 7: Runner and `collect` subcommand

**Files:**
- Create: `audit/lib/shadcn_audit/collect/runner.rb`
- Modify: `audit/lib/shadcn_audit/cli.rb`, `audit/lib/shadcn_audit.rb`
- Test: `audit/test/collect/runner_test.rb`, `audit/test/cli_collect_test.rb`

**Interfaces:**
- Consumes: everything above; `Sandbox::URL_TEMPLATE`, `RubyuiPreview::URL_TEMPLATE`, `Theme.compare`, `ComponentMap`, `Divergences`, `Reference` not needed.
- Produces:
  - CLI: `collect <folder> --run <dir> [--preview <path>]`. Writes `<run>/collect.json` (same object it prints) and screenshots in `<run>/screens/`.
  - `Collect::Runner.new(folder:, run_dir:, preview: nil, driver_factory: Driver.method(:open))#call -> Hash` with keys: `folder, map_source ("preview"|"working tree"), viewport {"w"=>1280,"h"=>800}, environment {"rubyui"=>{"light"=>…,"dark"=>…}, "shadcn"=>…}, environment_diffs (Array<String> like "font: Inter vs Geist (light)"), states (observations array), pixel_diffs ({"<state>/<theme>"=>PixelDiff result}), lines, screenshots (report shape: {"state"=>"<state> (<theme>)", "rubyui"=>…, "shadcn"=>…})`.

Rules:
- Map and divergences load from `<preview>/audit/…` when `--preview` is given **and** that map's entry has `selectors`; else from the working tree; `map_source` says which (spec "Selectors come from the audited head").
- Folder not in map, or entry without `selectors` in both places → `ArgumentError` `"<folder> has no selectors in audit/component_map.yml"`.
- Parts compared = parts with a non-null slot **and** a selector; parts missing a selector → one `inconclusive` Look line `"<Part>: no selector in component_map.yml"`.
- States per `kind`: modal/menu/popover/disclosure → all `Driver::STATES`; form_control → `closed, focus`; static → `closed`.
- Theme diffs from `Theme.compare(themes_ts: workspace ui/apps/v4/registry/themes.ts, rubyui_css: <preview or root>/docs/app/assets/stylesheets/application.tailwind.css)`.
- `environment_diff_keys` = probe keys whose values differ between sides in either theme (`font`/`fonts` both map to `"font"`).
- Iteration order: themes `light, dark`; states in `STATES` order; sides `rubyui, shadcn`.

- [ ] **Step 1: Write failing runner tests** with a fake driver (a class returning canned `environment` and `observe` hashes and touching the screenshot path), a temp run dir and a temp map/divergences:
  - `test_writes_collect_json_and_returns_same_object`.
  - `test_states_follow_kind`: `kind: form_control` → `states` contains only `closed`/`focus`.
  - `test_missing_selector_part_is_inconclusive`.
  - `test_preview_map_wins_when_it_has_selectors` / `test_falls_back_to_working_tree_map`.
  - `test_driver_error_on_one_state_does_not_abort` (fake returns `reached: false` for `open`) → `collect.json` written, Look/ARIA inconclusive lines present (Review Focus 3).
- [ ] **Step 2: Write failing CLI tests**: `collect` without `--run` → `{"error"=>/usage: collect <folder> --run <dir>/}`; driver factory raising `BrowserError` → `{"error"=> …"pnpm exec playwright install chromium"…}` (add `Collect::BrowserError` to `CLI::ERRORS`; inject the factory via a `driver_factory:` keyword on `CLI.collect` the way `comment` takes `shell:`).
- [ ] **Step 3: Run** → fail. **Step 4: Implement.** **Step 5: Run** `rake` → pass.
- [ ] **Step 6: Commit** `[Feature] shadcn-audit: collect subcommand`.

### Task 8: Selectors for the mapped components + real-server verification

**Files:**
- Modify: `audit/component_map.yml`

- [ ] **Step 1:** Boot the sandbox (5179) and preview (3179) as in SKILL.md step 2.6.
- [ ] **Step 2:** For `dialog, alert_dialog, sheet, command, form`, write `selectors` for every part with a non-null slot, derived from the gem source in `gem/lib/ruby_ui/<folder>/` and checked against the preview DOM (each must match the same visible count as `[data-slot=<slot>]` on the sandbox in the `open` state).
- [ ] **Step 3:** Run `collect dialog --run <tmp>/a --preview <preview path>` and again into `<tmp>/b`. Verify: no part line says "selector matched 0/…"; `jq 'del(.environment)' ` of both `collect.json` with screenshot paths stripped are identical (`diff` empty); `lines` identical.
- [ ] **Step 4:** Compare the Dialog Look/ARIA lines with `test/fixtures/report_572.json`'s verdicts; write any change and its reason in the PR description.
- [ ] **Step 5:** `rake` → pass. **Commit** `[Feature] shadcn-audit: selectors for mapped components`.

### Task 9: Skill and README

**Files:**
- Modify: `.claude/skills/shadcn-audit/SKILL.md`, `.claude/skills/shadcn-audit/references/interactions.md`, `.claude/skills/shadcn-audit/references/grading.md`, `audit/README.md`, `CLAUDE.md` (audit row only if wording needs it)

- [ ] **Step 1:** SKILL.md: prerequisites add `cd audit && pnpm install && pnpm exec playwright install chromium`; new step between 3 and 4: run `collect <folder> --run <run> --preview <preview path>`, append its `lines` and `screenshots` to the component, copy `environment_diffs`; step 4 (Look) and step 5 become "review and override `collect` lines; an override keeps the line and writes the reason in `note`"; the agent still runs the kind-specific behavior sequences from `interactions.md` with chrome-devtools MCP. Unmapped selectors → tell the user to add `selectors` (the audit never edits the map).
- [ ] **Step 2:** interactions.md: mark Setup + states closed/open/focus/after-esc + class/computed-style/ARIA probes as done by `collect`; keep the per-kind sequences. grading.md: `intentional` via structured `match` is automatic; prose-only entries are still applied by hand.
- [ ] **Step 3:** README: `collect` usage, Playwright install, `selectors` and `match` in one line each.
- [ ] **Step 4: Commit** `[Documentation] shadcn-audit: drive collect from the skill`.
