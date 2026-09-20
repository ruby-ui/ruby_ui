# Phase 2.0b — ERB Fixtures Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give every one of the 188 golden scenarios an ERB fixture — the 173 that Button's 15 did not cover — each green against the frozen canonical and strict snapshots while every component is still Phlex, so that from Phase 2.1 on a migration changes only an implementation and never the ruler.

**Architecture:** A fixture is one line of ERB under `gem/test/golden/views/<component>/<name>.html.erb` that renders the same composition as the scenario's Phlex block, through `render RubyUI::X.new(...)`. The suite already compiles it through the inline `Rails::Application` (ReActionView → Herb), renders the still-Phlex component through `phlex-rails`, and compares canonical and strict forms against the snapshots recorded from Phlex in Phase 2.0a. Nothing renders differently; this plan only writes what the lane compares. A coverage test, red from the first task to the last batch, is the inventory of what remains.

**Tech Stack:** Ruby 3.3 and 3.4 in CI (4.0.2 locally), Minitest, ActionView / Railties 8.1, ReActionView 0.4.1, Herb 0.10.4, phlex-rails 2.4.0 (development only), Nokogiri.

**Spec:** `design/2026-09-19-rubyui-2-0-design.md` — §6 "Phase 2.0 Foundation", the ERB-lane bullet; §6.2's definition of done; §9.1 parts 2–3. Decisions 7 and 8 in `design/v2/decisions.md` are the two this plan executes; decision 10 is the one it records. The "Not in this plan" section of `design/plans/2026-09-20-phase-2-0a-foundation-implementation.md` is where this plan was scoped. Read the catalog (`gem/test/golden/scenarios.rb`) before writing a fixture: the fixture is a translation of the scenario block, nothing more.

## Global Constraints

- Branch `v2/fixtures`, created from `v2/foundation` (PR #548, unmerged, tip `f855423`); the PR for this plan targets `v2/foundation`. Never branch from, rebase onto, or push to `main`. Never push before Task 10 asks.
- Work in `gem/`. Run every command from `gem/` unless the step says otherwise (the `git status` guards run from the repo root). `ENV["RAILS_ENV"]` is `test` for every test run (the helper sets it).
- **No file under `gem/lib/` changes.** Not a component, not `component.rb`, not `attributes.rb`. This plan touches only `gem/test/golden/views/**`, `gem/test/golden_test.rb` (one test), the header comment of `gem/test/golden/scenarios.rb`, `design/v2/decisions.md` and the spec.
- **No snapshot changes.** Never run `bundle exec rake golden:update` in this plan. `git status --porcelain gem/test/golden/snapshots gem/test/golden/strict` (from the repo root) is empty at the end of every task. Never hand-edit a file under either directory.
- **The harness does not change.** `gem/test/golden/harness.rb`, `catalog.rb`, `canonical_html.rb` and `test_helper.rb` are not touched. If a fixture cannot be made green without touching one of them, that is a STOP (see "When an ERB test fails" below), not a change. *Amended during execution:* Task 7b changes one line of `harness.rb` (and adds one test) to fix a pin defect the ERB lane exposed — the ruling and the evidence are in that task.
- **A fixture is one line plus a trailing newline** and emits no whitespace of its own — no leading whitespace, no newline between siblings, no indentation. The strict lane sees every character a fixture adds (decision 8), and under Herb 0.10.4 trim mode keeps the newline after an `end` that follows content on its line and emits the indentation before an output tag (decision 10, measured below). Button's 15 fixtures are the model.
- **Exactly one test may fail between Task 1 and Task 8**: `GoldenCoverageTest#test_every_scenario_has_a_fixture`, and each task states the count it must report. Any other failure — an `__erb` scenario test, a `__phlex` one, a coverage test, a canonicalizer test — blocks the commit. From Task 8 on, nothing fails.
- StandardRB stays at `423 files inspected, no offenses detected`: this plan adds no Ruby file. Fixtures are `.html.erb` and are not inspected.
- `mcp/data/registry.json` embeds the source of every file under `gem/lib/ruby_ui/<component>/`; nothing there changes, so `cd mcp && bundle exec exe/ruby-ui-mcp-build && git diff --exit-code data/registry.json` passes at the end (checked once, in Task 10). Do not touch `docs/`.
- Every commit message ends with `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>`.

---

## What the harness was measured to do — 2026-09-20

Every shape below was rendered through the real path — a fixture under `Rails.root`, compiled by ReActionView's handler, so by Herb (a `<div><span></div>` probe raised `ActionView::SyntaxErrorInTemplate`, which Erubi would not) — with the harness pins active, and its strict form compared byte-for-byte to the strict snapshot Phase 2.0a recorded from Phlex. On `v2/foundation` at `f855423`.

| Shape in the scenario block | Probe | Result |
| --- | --- | --- |
| A block parameter used to write raw elements (`aspect.img(...)`, `trigger.p { }`, `content.p { }`) → literal HTML in the ERB block, parameter not named | `accordion/custom_trigger_with_icon`, `aspect_ratio/default` | strict-identical |
| `key.plain "K"` — text beside an element | `shortcut_key/default` | strict-identical |
| `yield(self)` with a component-scoped method on the parameter (`group.ToggleGroupItem(...) { "L" }`) → the ERB block names the parameter, `<%= group.ToggleGroupItem(...) { "L" } %>` (the `<% … %>` statement form also passes) | `toggle_group/single`, `toggle_group/multiple_outline_spaced_vertical` | strict-identical |
| A block yielding nothing (`{ nil }`) → `do %><% end %>` (and `{ nil }` inside the tag also passes) | `select/value_falls_back_to_placeholder` | strict-identical |
| A Ruby loop around renders (`RubyUI::Badge::COLORS.each_key`) → `<% … do |v| %>…<% end %>` with `<%= v %>` for `v.to_s` | `badge/all_variants` | strict-identical |
| A heredoc argument → a double-quoted string with `\n` | `codeblock/ruby_with_clipboard` | strict-identical |
| `%w[]`, a nested `.new`, nested hashes, `[` inside a string, `=>` | `toast/region_top_center_with_close_button`, `data_table/pagination_manual_adapter`, `chart/bar`, `date_picker/default` | strict-identical |
| `DataTableForm#csrf_token` through phlex-rails' `helpers` with a view context and no controller | `DataTableForm` alone | `csrf-token-placeholder`, as recorded; the phlex-rails `helpers` deprecation warning prints, as it already does in the Phlex lane |
| The pins — `SecureRandom.hex` (`TooltipContent`, `SelectContent`, `DatePicker` without an `id:`) and `rand(Range)` (`SidebarMenuSkeleton`) — while `render_erb` is active | `date_picker/generated_id`, `select/default`, `tooltip/default`; two `SidebarMenuSkeleton` | strict-identical; identical across two renders; the minted ids are `date-picker-00000001`, `content00000001`, `tooltip00000001`, as recorded |
| **Trim mode.** `-%>` on an opening tag (`<%= render X.new do -%>`, `<%- if true -%>`) | Appendix A: p1, p4, p5 | the newline after the tag is removed; `<%-` also removes the indentation before the tag on the same line |
| **Trim mode.** `-%>` or `<%- … -%>` on the `end` that closes a `<%= … do %>` block, written after content on the same line (`Body<% end -%>`) | Appendix A: p1, p7 | **the newline after it is kept** — `visit_erb_block_end_node` in Herb's compiler never reads the end tag's own trim markers |
| **Trim mode.** That same `end` alone on its own line | Appendix A: p2, p8 | the indentation before it and the newline after it are removed, Erubi-style; the newline *before* it, ending the content line, stays |
| **Trim mode.** Indentation before an output tag (`  <%= render … -%>`) | Appendix A: p3, p8 | emitted as text |
| A layout that is whitespace-tight under those rules: a break only after each opening tag, every `end` adjacent to its content, siblings on one line | Appendix A: p5 versus p9 | p5 emits nothing extra; p9, with a sibling render on its own line after `<% end %>`, emits the newline |
| A line break *inside* a tag (`<%=\n  render … %>` … `<%\n  end %>`) | Appendix A: p6 | no output whitespace, at any indentation |

Consequences: the one-line translation rule holds for every shape the catalog uses. Under the pinned ReActionView 0.4.1 + Herb 0.10.4, trim mode does not reliably make an indented, one-render-per-line layout whitespace-tight: the newline after a content-terminated `end` and the indentation before an output tag both reach the output, and the strict lane sees both. Two layouts do emit nothing — breaks only after opening tags with every `end` kept adjacent (p5), and breaks inside tags (p6) — and neither reads better than one line for a fixture. Task 9 records this as decision 10; Appendix A has every probe's source and output so plan 2.1 can reproduce the conclusion under whatever Herb it pins.

## Translation rules

Applied to every scenario block in `gem/test/golden/scenarios.rb`. The fixture for `component "c" … scenario "n"` is `gem/test/golden/views/c/n.html.erb`.

1. `RubyUI.X(args) { "text" }` → `<%= render RubyUI::X.new(args) do %>text<% end %>`. Arguments verbatim Ruby; block text verbatim, no added spaces.
2. `RubyUI.X(args)` with no block → `<%= render RubyUI::X.new(args) %>`. `RubyUI.X` alone → `<%= render RubyUI::X.new %>`.
3. Nested components are nested `<%= render … %>` tags inside the parent's block, siblings adjacent with nothing between them.
4. A block parameter the scenario uses only to write elements or text (`aspect.img`, `trigger.p`, `content.p`, `key.span`, `key.plain`) becomes literal HTML or text in the ERB block; the ERB block does not name the parameter. `key.plain "K"` is `K`. An `img` call becomes `<img …>` with the same attributes.
5. A block parameter the scenario uses to call a component method (`group.ToggleGroupItem`) is named in the ERB block — `do |group| %>` — and the call is `<%= group.ToggleGroupItem(args) { "text" } %>`.
6. A Ruby loop becomes `<% collection.each do |v| %>…<% end %>`; `v.to_s` as content becomes `<%= v %>`.
7. A heredoc becomes a double-quoted Ruby string with `\n` for each newline and `\"` for each quote.
8. A local variable defined at the `component` level (`columns` in `data_table`) is inlined where it is used.
9. Symbols stay Symbols (`variant: :outline`), Strings stay Strings, Integers and Floats stay as written (`value: 33.5`); a generated scenario's interpolated value is written out (`level: level.to_s` for level 1 → `level: "1"`; `variant: variant` → `variant: :primary`; `inset: style == :inset` → `inset: true` / `inset: false`).
10. One line, then one `\n`. Nothing else.

A quoted heredoc writes a fixture exactly, with no shell expansion and exactly one trailing newline; every fixture step below is written that way and can be run verbatim from the repo root. (The example is `alert/warning`, which Task 6 writes — do not run it ahead of Task 6, or Task 2's file count is off by one.)

```bash
mkdir -p gem/test/golden/views/alert
cat > gem/test/golden/views/alert/warning.html.erb <<'ERB'
<%= render RubyUI::Alert.new(variant: :warning) do %><%= render RubyUI::AlertTitle.new do %>Careful<% end %><% end %>
ERB
```

## When an ERB test fails

The suite is the arbiter; the plan does not diagnose for it. An `__erb` test that fails is handled in this order:

1. **Compare the fixture with its scenario block** under the translation rules, character by character. If they differ, fix the fixture and re-run. The comparison is also what a *green* test does not replace: an argument the component ignores renders identical HTML, so a passing fixture is not proof of a faithful one.
2. **If the fixture is a faithful translation and the test still fails — STOP.** Report, without asserting a cause: the scenario slug and the fixture's content; the exception class and full message if it raised (`ActionView::SyntaxErrorInTemplate` carries Herb's annotated message); otherwise the raw ERB-lane output and the raw Phlex-lane output, and the canonical and strict diffs (the failure message prints both forms); the gem versions (`grep -E "^    (phlex|phlex-rails|reactionview|herb|actionview|railties) \(" Gemfile.lock`); and the command that reproduces it (`bundle exec rake test N=/test_<component>__<name>__erb/`). A compile error may or may not be malformed literal HTML; a faithful-fixture mismatch may or may not be phlex-rails rendering differently from a direct Phlex call — the evidence says, not the plan.
3. **The boundary holds either way.** Do not edit the component, either snapshot, `harness.rb`, `catalog.rb`, `canonical_html.rb`, `test_helper.rb`, or the scenario block. If the maintainer's decision is to mark the scenario `pending:`, note that `pending:` is scenario-level: `assert_golden` skips the snapshot comparison for **both** lanes of that scenario (each render must still not raise and must be deterministic), so it is not an ERB-only exception and it costs the ruler a scenario — a decision recorded in `design/v2/decisions.md`, not a step here.

A determinism failure ("does not render deterministically") is reported the same way; if a pin is missing it belongs in `harness.rb`, which this plan does not touch.

## File Structure

| File | Responsibility |
| --- | --- |
| `gem/test/golden_test.rb` | Gains `test_every_scenario_has_a_fixture` in `GoldenCoverageTest`. Nothing else changes. |
| `gem/test/golden/views/<component>/<name>.html.erb` | 173 new fixtures, one per scenario without one. One line each. |
| `gem/test/golden/scenarios.rb` | Header comment gains the paragraph that tells the next person where the fixtures are and why they are one line. No scenario changes. |
| `design/v2/decisions.md` | Entry 10: Herb's trim mode measured; fixtures are one line. |
| `design/2026-09-19-rubyui-2-0-design.md` | §6 Phase 2.0 ERB-lane bullet, §6.2 definition of done and §9.1 part 2 amended to what was measured. |

## Progress table

`bundle exec rake golden` today: `235 runs` (188 Phlex-lane, 15 ERB-lane, 7 coverage, 25 of the ruler's own). `bundle exec rake`: `601 runs`, `423 files inspected`. Each task adds one ERB-lane test per fixture; Task 1 adds one coverage test.

| After | Fixtures on disk | `rake golden` runs | Failures | Remaining (the failure's count) | `rake` runs |
| --- | --- | --- | --- | --- | --- |
| Task 1 | 15 | 236 | 1 | 173 | 602 |
| Task 2 | 40 | 261 | 1 | 148 | 627 |
| Task 3 | 63 | 284 | 1 | 125 | 650 |
| Task 4 | 85 | 306 | 1 | 103 | 672 |
| Task 5 | 106 | 327 | 1 | 82 | 693 |
| Task 6 | 129 | 350 | 1 | 59 | 716 |
| Task 7 | 152 | 373 | 1 | 36 | 739 |
| Task 7b | 152 | 374 | 1 | 36 | 740 |
| Task 8 | 188 | 410 | 0 | 0 | 776 |

The `rake` column is what `bundle exec rake test` reports. Until Task 8 the default `bundle exec rake` task stops at the one expected failure before it reaches StandardRB, so the tasks that change a Ruby file (1 and 9) run `bundle exec standardrb` on its own.

The check that every batch task runs, from `gem/`:

```bash
bundle exec rake golden 2>&1 | grep -oE "[0-9]+ runs, [0-9]+ assertions, [0-9]+ failures, [0-9]+ errors, [0-9]+ skips|[0-9]+ scenarios without an ERB fixture|(Failure|Error):.*|Golden[A-Za-z]+Test#test_[a-z_0-9]+"
```

Expected for a batch task: one `runs,` line with the task's numbers and `1 failures, 0 errors, 0 skips`; exactly one `Failure:` line; exactly one test name, `GoldenCoverageTest#test_every_scenario_has_a_fixture`; and one `N scenarios without an ERB fixture` line with the task's remaining count. Any `__erb` or `__phlex` name in the output is a failing scenario — see "When an ERB test fails".

Batch order is by risk, as spec §6.2 orders the migration: the shapes the probes had to prove first (block parameters, `yield(self)`, the view context, `{ nil }`, loops, heredocs), then the components with pinned randomness and generated ids, then menus and overlays, form controls, content and layout, and the two enumerative families last.

---

## Task 1: The branch, the plan, and the red coverage test

The coverage test is the inventory of this plan: red with 173 slugs at the start, green at the end. It is written first so that every batch commit reports, by name, what is still missing — and so that the suite cannot quietly call the lane complete while a scenario has no fixture.

**Files:**
- Create: `design/plans/2026-09-20-phase-2-0b-fixtures-implementation.md` (this file — committed first, alone)
- Modify: `gem/test/golden_test.rb` (`GoldenCoverageTest`)

**Interfaces:**
- Consumes: `Golden::Catalog.scenarios`, `Scenario#fixture?`, `Scenario#slug` (Phase 2.0a).
- Produces: `GoldenCoverageTest#test_every_scenario_has_a_fixture`, whose failure message begins `N scenarios without an ERB fixture under test/golden/views:` followed by the slugs.

- [ ] **Step 1: Confirm the branch**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git branch --show-current
git log --oneline -1 v2/foundation
git status --porcelain
```

Expected: `v2/fixtures`; `f855423 [Bug Fix] Golden suite: strict snapshot follows the custom-keybindings scenario fix`; and only this plan file untracked (`?? design/plans/2026-09-20-phase-2-0b-fixtures-implementation.md`). If the branch is not `v2/fixtures`, create it: `git checkout -b v2/fixtures v2/foundation`.

- [ ] **Step 2: Commit the plan**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add design/plans/2026-09-20-phase-2-0b-fixtures-implementation.md
git commit -m "$(cat <<'MSG'
[Documentation] Plan for Phase 2.0b: the other 173 ERB fixtures

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
MSG
)"
```

- [ ] **Step 3: Write the failing coverage test**

In `gem/test/golden_test.rb`, inside `class GoldenCoverageTest`, after `test_every_scenario_has_at_least_one_lane` and before `test_no_orphan_fixture_files`, add:

```ruby
  # Decision 7: every scenario has an ERB fixture before any component
  # migrates, so a migration can only ever change an implementation, never the
  # ruler. Red until the last batch of plan 2.0b lands; its message is the
  # remaining work, by slug.
  def test_every_scenario_has_a_fixture
    missing = Golden::Catalog.scenarios.reject(&:fixture?).map(&:slug)

    assert_empty missing,
      "#{missing.size} scenarios without an ERB fixture under test/golden/views: #{missing.join(", ")}"
  end
```

- [ ] **Step 4: Run the suite and confirm it fails on exactly that test**

```bash
cd /Users/cirdes/Workspaces/ruby_ui/gem
bundle exec rake golden 2>&1 | grep -oE "[0-9]+ runs, [0-9]+ assertions, [0-9]+ failures, [0-9]+ errors, [0-9]+ skips|[0-9]+ scenarios without an ERB fixture|(Failure|Error):.*|Golden[A-Za-z]+Test#test_[a-z_0-9]+"
```

Expected:

```
Failure:
GoldenCoverageTest#test_every_scenario_has_a_fixture
173 scenarios without an ERB fixture
236 runs, 1693 assertions, 1 failures, 0 errors, 0 skips
```

(Order of the lines may differ; the assertion count is what a measured run reported and may drift — the four facts that matter are `236 runs`, `1 failures`, the one test name, and `173`.) Then confirm the message lists no Button scenario — the pattern needs a component boundary, because `radio_button/default` and `radio_button/checked` are rightly in the list and a bare `button/` would count them:

```bash
bundle exec rake golden 2>&1 | grep -cE '(^|[^[:alnum:]_])button/'
```

Expected: `0` (and `grep -c` exits 1 when it prints `0`; that is the wanted outcome, not an error).

- [ ] **Step 5: Lint and commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui/gem
bundle exec standardrb
```

Expected: `423 files inspected, no offenses detected`.

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/test/golden_test.rb
git commit -m "$(cat <<'MSG'
[Feature] Golden suite: every scenario must have an ERB fixture

Red by design: 173 scenarios have no fixture yet. Plan 2.0b writes them
in seven batches; this test's message is the list of what remains, and
the suite cannot call the ERB lane complete while it is non-empty.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
MSG
)"
```

---

## Task 2: Batch 1 — the shapes the probes proved (25 fixtures)

accordion (2), aspect_ratio (2), shortcut_key (1), toggle (3), toggle_group (3), toast (3), data_table (7), select (2), codeblock (2). Every shape here — a block parameter writing raw HTML, text beside an element, `yield(self)` with `group.ToggleGroupItem`, `ToastRegion`'s `yield(self) if block`, `DataTableForm`'s view-context reach, `{ nil }`, a heredoc, a nested `.new` — was measured strict-identical on 2026-09-20 (table above). If one of these fails now, follow "When an ERB test fails": compare the fixture with its scenario block first; if it is faithful, STOP and report with the evidence listed there, gem versions included — the plan does not know why.

**Files:**
- Create: 25 files under `gem/test/golden/views/{accordion,aspect_ratio,shortcut_key,toggle,toggle_group,toast,data_table,select,codeblock}/`

**Interfaces:**
- Consumes: `Golden::Harness.render_erb(scenario)`, `RubyUI::TestApp.view(Golden::Catalog::VIEWS_ROOT)` (Phase 2.0a).
- Produces: 25 fixtures, each defining a `test_<component>__<name>__erb` test.

- [ ] **Step 1: Write the fixtures**

From the repo root. The `data_table/full_frame` fixture renders `DataTableForm`, whose `csrf_token` calls phlex-rails' deprecated `helpers` and prints a deprecation notice on every render; the Phlex lane already prints it. It is not a failure.

```bash
mkdir -p gem/test/golden/views/accordion
cat > gem/test/golden/views/accordion/default_trigger_and_content.html.erb <<'ERB'
<%= render RubyUI::Accordion.new do %><%= render RubyUI::AccordionItem.new do %><%= render RubyUI::AccordionDefaultTrigger.new do %>Title<% end %><%= render RubyUI::AccordionDefaultContent.new do %>Content<% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/accordion/custom_trigger_with_icon.html.erb <<'ERB'
<%= render RubyUI::Accordion.new do %><%= render RubyUI::AccordionItem.new(open: true, rotate_icon: 90) do %><%= render RubyUI::AccordionTrigger.new do %><p>What is RubyUI?</p><%= render RubyUI::AccordionIcon.new %><% end %><%= render RubyUI::AccordionContent.new do %><p>A UI component library for Ruby.</p><% end %><% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/aspect_ratio
cat > gem/test/golden/views/aspect_ratio/default.html.erb <<'ERB'
<%= render RubyUI::AspectRatio.new do %><img alt="Placeholder" loading="lazy" src="/placeholder.png"><% end %>
ERB
cat > gem/test/golden/views/aspect_ratio/square.html.erb <<'ERB'
<%= render RubyUI::AspectRatio.new(aspect_ratio: "1/1", class: "rounded-md border") do %><img alt="Placeholder" src="/placeholder.png"><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/shortcut_key
cat > gem/test/golden/views/shortcut_key/default.html.erb <<'ERB'
<%= render RubyUI::ShortcutKey.new do %><span class="text-xs">Cmd</span>K<% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/toggle
cat > gem/test/golden/views/toggle/default.html.erb <<'ERB'
<%= render RubyUI::Toggle.new do %>B<% end %>
ERB
cat > gem/test/golden/views/toggle/pressed_outline_with_name.html.erb <<'ERB'
<%= render RubyUI::Toggle.new(pressed: true, name: "bold", value: "1", unpressed_value: "0", variant: :outline, size: :lg) do %>B<% end %>
ERB
cat > gem/test/golden/views/toggle/disabled_small.html.erb <<'ERB'
<%= render RubyUI::Toggle.new(disabled: true, size: :sm, wrapper: {class: "inline-flex"}) do %>B<% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/toggle_group
cat > gem/test/golden/views/toggle_group/single.html.erb <<'ERB'
<%= render RubyUI::ToggleGroup.new(type: :single, name: "align", value: "right") do |group| %><%= group.ToggleGroupItem(value: "left") { "L" } %><%= group.ToggleGroupItem(value: "right") { "R" } %><% end %>
ERB
cat > gem/test/golden/views/toggle_group/multiple_outline_spaced_vertical.html.erb <<'ERB'
<%= render RubyUI::ToggleGroup.new(type: :multiple, name: "fmt", value: %w[bold italic], variant: :outline, size: :sm, spacing: 2, orientation: :vertical) do |group| %><%= group.ToggleGroupItem(value: "bold") { "B" } %><%= group.ToggleGroupItem(value: "italic") { "I" } %><%= group.ToggleGroupItem(value: "underline") { "U" } %><% end %>
ERB
cat > gem/test/golden/views/toggle_group/disabled.html.erb <<'ERB'
<%= render RubyUI::ToggleGroup.new(type: :multiple, name: "fmt", disabled: true) do |group| %><%= group.ToggleGroupItem(value: "bold") { "B" } %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/toast
cat > gem/test/golden/views/toast/region_with_flash.html.erb <<'ERB'
<%= render RubyUI::ToastRegion.new(flash: {"notice" => "Saved", "alert" => "Careful"}) %>
ERB
cat > gem/test/golden/views/toast/region_top_center_with_close_button.html.erb <<'ERB'
<%= render RubyUI::ToastRegion.new(position: :top_center, expand: true, max: 5, duration: 8000, theme: :dark, rich_colors: true, close_button: true, hotkey: %w[ctrl shift t], dir: :rtl) %>
ERB
cat > gem/test/golden/views/toast/item_with_all_slots.html.erb <<'ERB'
<%= render RubyUI::ToastRegion.new do %><%= render RubyUI::ToastItem.new(variant: :error, id: "t1", duration: 6000, dismissible: false, invert: true, on_dismiss: "log", on_auto_close: "log") do %><%= render RubyUI::ToastIcon.new(variant: :error) %><%= render RubyUI::ToastTitle.new do %>Upload failed<% end %><%= render RubyUI::ToastDescription.new do %>The file is too large.<% end %><%= render RubyUI::ToastAction.new(label: "Retry", on: "retry") %><%= render RubyUI::ToastCancel.new(label: "Dismiss") %><%= render RubyUI::ToastClose.new %><% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/data_table
cat > gem/test/golden/views/data_table/full_frame.html.erb <<'ERB'
<%= render RubyUI::DataTable.new(id: "employees") do %><%= render RubyUI::DataTableForm.new(action: "/employees/bulk", id: "employees_form") do %><%= render RubyUI::DataTableToolbar.new do %><%= render RubyUI::DataTableSearch.new(path: "/employees", value: "alice", frame_id: "employees") %><%= render RubyUI::DataTableColumnToggle.new(columns: [{key: :email, label: "Email"}, {key: :salary, label: "Salary", visible: false}]) %><%= render RubyUI::DataTableBulkActions.new do %><%= render RubyUI::Button.new(variant: :destructive) do %>Delete<% end %><% end %><% end %><%= render RubyUI::Table.new do %><%= render RubyUI::TableHeader.new do %><%= render RubyUI::TableRow.new do %><%= render RubyUI::TableHead.new do %><%= render RubyUI::DataTableSelectAllCheckbox.new %><% end %><%= render RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", sort: "name", direction: "asc", path: "/employees", query: {"search" => "alice"}) %><% end %><% end %><%= render RubyUI::TableBody.new do %><%= render RubyUI::TableRow.new do %><%= render RubyUI::TableCell.new do %><%= render RubyUI::DataTableRowCheckbox.new(value: 42, label: "Select Alice") %><% end %><%= render RubyUI::TableCell.new do %>Alice<% end %><%= render RubyUI::TableCell.new do %><%= render RubyUI::DataTableExpandToggle.new(controls: "employee-42-detail") %><% end %><% end %><% end %><% end %><%= render RubyUI::DataTablePaginationBar.new do %><%= render RubyUI::DataTableSelectionSummary.new(total_on_page: 10) %><%= render RubyUI::DataTablePerPageSelect.new(path: "/employees", value: 25) %><%= render RubyUI::DataTablePagination.new(page: 3, per_page: 10, total_count: 61, path: "/employees", query: {"search" => "alice"}) %><% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/data_table/pagination_first_page.html.erb <<'ERB'
<%= render RubyUI::DataTablePagination.new(page: 1, per_page: 10, total_count: 30, path: "/x", query: {}) %>
ERB
cat > gem/test/golden/views/data_table/pagination_wide_window.html.erb <<'ERB'
<%= render RubyUI::DataTablePagination.new(page: 10, per_page: 1, total_count: 20, path: "/x", query: {}, window: 2) %>
ERB
cat > gem/test/golden/views/data_table/pagination_manual_adapter.html.erb <<'ERB'
<%= render RubyUI::DataTablePagination.new(with: RubyUI::DataTableManualAdapter.new(page: 2, per_page: 5, total_count: 21), path: "/x", query: {}) %>
ERB
cat > gem/test/golden/views/data_table/sort_head_unsorted.html.erb <<'ERB'
<%= render RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", path: "/x", query: {}) %>
ERB
cat > gem/test/golden/views/data_table/expand_toggle_expanded.html.erb <<'ERB'
<%= render RubyUI::DataTableExpandToggle.new(controls: "row-1", expanded: true, label: "Toggle") %>
ERB
cat > gem/test/golden/views/data_table/search_without_debounce.html.erb <<'ERB'
<%= render RubyUI::DataTableSearch.new(path: "/x", debounce: false, preserved_params: {"sort" => "name"}) %>
ERB
```

```bash
mkdir -p gem/test/golden/views/select
cat > gem/test/golden/views/select/default.html.erb <<'ERB'
<%= render RubyUI::Select.new do %><%= render RubyUI::SelectInput.new(name: "person") %><%= render RubyUI::SelectTrigger.new do %><%= render RubyUI::SelectValue.new(placeholder: "Select a person") %><% end %><%= render RubyUI::SelectContent.new do %><%= render RubyUI::SelectGroup.new do %><%= render RubyUI::SelectLabel.new do %>People<% end %><%= render RubyUI::SelectItem.new(value: 1) do %>John Doe<% end %><%= render RubyUI::SelectItem.new(value: 2) do %>Jane Doe<% end %><% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/select/value_falls_back_to_placeholder.html.erb <<'ERB'
<%= render RubyUI::SelectValue.new(placeholder: "Placeholder") do %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/codeblock
cat > gem/test/golden/views/codeblock/ruby_with_clipboard.html.erb <<'ERB'
<%= render RubyUI::Codeblock.new("def hello_world\n  puts \"Hello, world!\"\nend\n", syntax: :ruby) %>
ERB
cat > gem/test/golden/views/codeblock/ruby_without_clipboard.html.erb <<'ERB'
<%= render RubyUI::Codeblock.new("puts :ok\n", syntax: :ruby, clipboard: false) %>
ERB
```

- [ ] **Step 2: Run the suite**

```bash
cd /Users/cirdes/Workspaces/ruby_ui/gem
bundle exec rake golden 2>&1 | grep -oE "[0-9]+ runs, [0-9]+ assertions, [0-9]+ failures, [0-9]+ errors, [0-9]+ skips|[0-9]+ scenarios without an ERB fixture|(Failure|Error):.*|Golden[A-Za-z]+Test#test_[a-z_0-9]+"
```

Expected: `261 runs, … 1 failures, 0 errors, 0 skips`; one `Failure:`; only `GoldenCoverageTest#test_every_scenario_has_a_fixture`; `148 scenarios without an ERB fixture`. Any other test name → "When an ERB test fails".

- [ ] **Step 3: Confirm the ruler did not move**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain gem/test/golden/snapshots gem/test/golden/strict
find gem/test/golden/views -name '*.html.erb' | wc -l
```

Expected: no output; `40`.

- [ ] **Step 4: Commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/test/golden/views
git commit -m "$(cat <<'MSG'
[Feature] Golden suite: ERB fixtures for the block-parameter and view-context shapes

accordion, aspect_ratio, shortcut_key, toggle, toggle_group, toast,
data_table, select, codeblock — 25 fixtures, each green against the
frozen canonical and strict snapshots with the components still Phlex.
These are the shapes that had to be proved first: a block parameter
writing raw HTML, text beside an element, yield(self) with
group.ToggleGroupItem, DataTableForm reaching for the view context, a
block yielding nothing, a heredoc, a nested .new. 148 scenarios remain.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
MSG
)"
```

---

## Task 3: Batch 2 — generated ids, pinned randomness, and the overlays (23 fixtures)

tooltip (2), date_picker (3), sidebar (4), dialog (6), alert_dialog (2), sheet (6). `TooltipContent`, `DatePicker` and `SelectContent` mint ids with `SecureRandom.hex`, `SidebarMenuSkeleton` picks a width with `rand(50..89)`; the harness pins both while `render_erb` is active, with counters that restart per render, so the ERB lane sees the same values the Phlex lane recorded.

**Files:**
- Create: 23 files under `gem/test/golden/views/{tooltip,date_picker,sidebar,dialog,alert_dialog,sheet}/`

**Interfaces:**
- Consumes: `Golden::Harness.render_erb(scenario)`, `RubyUI::TestApp.view(Golden::Catalog::VIEWS_ROOT)` (Phase 2.0a).
- Produces: 23 fixtures.

- [ ] **Step 1: Write the fixtures**

```bash
mkdir -p gem/test/golden/views/tooltip
cat > gem/test/golden/views/tooltip/default.html.erb <<'ERB'
<%= render RubyUI::Tooltip.new do %><%= render RubyUI::TooltipTrigger.new do %><%= render RubyUI::Button.new(variant: :outline, icon: true) do %>?<% end %><% end %><%= render RubyUI::TooltipContent.new do %>Add to library<% end %><% end %>
ERB
cat > gem/test/golden/views/tooltip/placement_right.html.erb <<'ERB'
<%= render RubyUI::Tooltip.new(placement: "right") do %><%= render RubyUI::TooltipContent.new do %>Tip<% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/date_picker
cat > gem/test/golden/views/date_picker/default.html.erb <<'ERB'
<%= render RubyUI::DatePicker.new(id: "event-date", name: "event[date]", value: "2026-05-15") %>
ERB
cat > gem/test/golden/views/date_picker/without_label.html.erb <<'ERB'
<%= render RubyUI::DatePicker.new(id: "event-date", label: nil) %>
ERB
cat > gem/test/golden/views/date_picker/generated_id.html.erb <<'ERB'
<%= render RubyUI::DatePicker.new %>
ERB
```

```bash
mkdir -p gem/test/golden/views/sidebar
cat > gem/test/golden/views/sidebar/collapsible_offcanvas.html.erb <<'ERB'
<%= render RubyUI::SidebarWrapper.new do %><%= render RubyUI::Sidebar.new do %><%= render RubyUI::SidebarHeader.new do %><%= render RubyUI::SidebarGroup.new do %><%= render RubyUI::SidebarGroupContent.new do %><%= render RubyUI::SidebarInput.new(id: "search", placeholder: "Search the docs") %><% end %><% end %><% end %><%= render RubyUI::SidebarContent.new do %><%= render RubyUI::SidebarGroup.new do %><%= render RubyUI::SidebarGroupLabel.new do %>Application<% end %><%= render RubyUI::SidebarGroupAction.new do %>Add<% end %><%= render RubyUI::SidebarGroupContent.new do %><%= render RubyUI::SidebarMenu.new do %><%= render RubyUI::SidebarMenuItem.new do %><%= render RubyUI::SidebarMenuButton.new(as: :a, href: "/settings", active: true) do %>Settings<% end %><%= render RubyUI::SidebarMenuAction.new(show_on_hover: true) do %>More<% end %><%= render RubyUI::SidebarMenuBadge.new do %>3<% end %><%= render RubyUI::SidebarMenuSub.new do %><%= render RubyUI::SidebarMenuSubItem.new do %><%= render RubyUI::SidebarMenuSubButton.new(as: :a, href: "/settings/team") do %>Team<% end %><% end %><% end %><% end %><%= render RubyUI::SidebarMenuItem.new do %><%= render RubyUI::SidebarMenuSkeleton.new(show_icon: true) %><% end %><%= render RubyUI::SidebarMenuItem.new do %><%= render RubyUI::SidebarMenuSkeleton.new %><% end %><% end %><% end %><% end %><%= render RubyUI::SidebarSeparator.new %><% end %><%= render RubyUI::SidebarFooter.new do %>Footer<% end %><%= render RubyUI::SidebarRail.new %><% end %><%= render RubyUI::SidebarInset.new do %><%= render RubyUI::SidebarTrigger.new %><% end %><% end %>
ERB
cat > gem/test/golden/views/sidebar/non_collapsible.html.erb <<'ERB'
<%= render RubyUI::SidebarWrapper.new do %><%= render RubyUI::Sidebar.new(collapsible: :none) do %><%= render RubyUI::SidebarContent.new do %>Body<% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/sidebar/collapsible_icon_right_floating.html.erb <<'ERB'
<%= render RubyUI::Sidebar.new(side: :right, variant: :floating, collapsible: :icon, open: false) do %><%= render RubyUI::SidebarContent.new do %>Body<% end %><% end %>
ERB
cat > gem/test/golden/views/sidebar/mobile.html.erb <<'ERB'
<%= render RubyUI::MobileSidebar.new(side: :right) do %>Body<% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/dialog
cat > gem/test/golden/views/dialog/default.html.erb <<'ERB'
<%= render RubyUI::Dialog.new do %><%= render RubyUI::DialogTrigger.new do %><%= render RubyUI::Button.new do %>Open Dialog<% end %><% end %><%= render RubyUI::DialogContent.new do %><%= render RubyUI::DialogHeader.new do %><%= render RubyUI::DialogTitle.new do %>RubyUI to the rescue<% end %><%= render RubyUI::DialogDescription.new do %>Build accessible apps with ease.<% end %><% end %><%= render RubyUI::DialogMiddle.new do %>Body<% end %><%= render RubyUI::DialogFooter.new do %><%= render RubyUI::Button.new(variant: :outline) do %>Cancel<% end %><%= render RubyUI::Button.new do %>Save<% end %><% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/dialog/content_sm.html.erb <<'ERB'
<%= render RubyUI::DialogContent.new(size: :sm) do %>body<% end %>
ERB
cat > gem/test/golden/views/dialog/content_md.html.erb <<'ERB'
<%= render RubyUI::DialogContent.new(size: :md) do %>body<% end %>
ERB
cat > gem/test/golden/views/dialog/content_lg.html.erb <<'ERB'
<%= render RubyUI::DialogContent.new(size: :lg) do %>body<% end %>
ERB
cat > gem/test/golden/views/dialog/content_xl.html.erb <<'ERB'
<%= render RubyUI::DialogContent.new(size: :xl) do %>body<% end %>
ERB
cat > gem/test/golden/views/dialog/open.html.erb <<'ERB'
<%= render RubyUI::Dialog.new(open: true) do %><%= render RubyUI::DialogContent.new do %>body<% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/alert_dialog
cat > gem/test/golden/views/alert_dialog/default.html.erb <<'ERB'
<%= render RubyUI::AlertDialog.new do %><%= render RubyUI::AlertDialogTrigger.new do %><%= render RubyUI::Button.new do %>Show dialog<% end %><% end %><%= render RubyUI::AlertDialogContent.new do %><%= render RubyUI::AlertDialogHeader.new do %><%= render RubyUI::AlertDialogTitle.new do %>Are you absolutely sure?<% end %><%= render RubyUI::AlertDialogDescription.new do %>This action cannot be undone.<% end %><% end %><%= render RubyUI::AlertDialogFooter.new do %><%= render RubyUI::AlertDialogCancel.new do %>Cancel<% end %><%= render RubyUI::AlertDialogAction.new do %>Continue<% end %><% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/alert_dialog/open.html.erb <<'ERB'
<%= render RubyUI::AlertDialog.new(open: true) do %><%= render RubyUI::AlertDialogContent.new do %><%= render RubyUI::AlertDialogTitle.new do %>Open<% end %><% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/sheet
cat > gem/test/golden/views/sheet/default.html.erb <<'ERB'
<%= render RubyUI::Sheet.new do %><%= render RubyUI::SheetTrigger.new do %><%= render RubyUI::Button.new(variant: :outline) do %>Open Sheet<% end %><% end %><%= render RubyUI::SheetContent.new(class: "sm:max-w-sm") do %><%= render RubyUI::SheetHeader.new do %><%= render RubyUI::SheetTitle.new do %>Edit profile<% end %><%= render RubyUI::SheetDescription.new do %>Make changes to your profile here.<% end %><% end %><%= render RubyUI::SheetMiddle.new do %><%= render RubyUI::Input.new(name: "name") %><% end %><%= render RubyUI::SheetFooter.new do %><%= render RubyUI::Button.new(type: "submit") do %>Save<% end %><% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/sheet/content_top.html.erb <<'ERB'
<%= render RubyUI::SheetContent.new(side: :top) do %>body<% end %>
ERB
cat > gem/test/golden/views/sheet/content_right.html.erb <<'ERB'
<%= render RubyUI::SheetContent.new(side: :right) do %>body<% end %>
ERB
cat > gem/test/golden/views/sheet/content_bottom.html.erb <<'ERB'
<%= render RubyUI::SheetContent.new(side: :bottom) do %>body<% end %>
ERB
cat > gem/test/golden/views/sheet/content_left.html.erb <<'ERB'
<%= render RubyUI::SheetContent.new(side: :left) do %>body<% end %>
ERB
cat > gem/test/golden/views/sheet/open.html.erb <<'ERB'
<%= render RubyUI::Sheet.new(open: true) do %>content<% end %>
ERB
```

- [ ] **Step 2: Run the suite**

```bash
cd /Users/cirdes/Workspaces/ruby_ui/gem
bundle exec rake golden 2>&1 | grep -oE "[0-9]+ runs, [0-9]+ assertions, [0-9]+ failures, [0-9]+ errors, [0-9]+ skips|[0-9]+ scenarios without an ERB fixture|(Failure|Error):.*|Golden[A-Za-z]+Test#test_[a-z_0-9]+"
```

Expected: `284 runs, … 1 failures, 0 errors, 0 skips`; only `GoldenCoverageTest#test_every_scenario_has_a_fixture`; `125 scenarios without an ERB fixture`.

- [ ] **Step 3: Confirm the ruler did not move**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain gem/test/golden/snapshots gem/test/golden/strict
find gem/test/golden/views -name '*.html.erb' | wc -l
```

Expected: no output; `63`.

- [ ] **Step 4: Commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/test/golden/views
git commit -m "$(cat <<'MSG'
[Feature] Golden suite: ERB fixtures for the overlays and the pinned-randomness components

tooltip, date_picker, sidebar, dialog, alert_dialog, sheet — 23
fixtures. The harness pins SecureRandom.hex and rand(Range) in the ERB
lane exactly as in the Phlex lane, so the generated ids and the
skeleton widths match the recorded snapshots. 125 scenarios remain.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
MSG
)"
```

---

## Task 4: Batch 3 — menus and overlays (22 fixtures)

dropdown_menu (2), context_menu (4), popover (2), hover_card (2), command (5), combobox (5), collapsible (2).

**Files:**
- Create: 22 files under `gem/test/golden/views/{dropdown_menu,context_menu,popover,hover_card,command,combobox,collapsible}/`

**Interfaces:**
- Consumes: `Golden::Harness.render_erb(scenario)`, `RubyUI::TestApp.view(Golden::Catalog::VIEWS_ROOT)` (Phase 2.0a).
- Produces: 22 fixtures.

- [ ] **Step 1: Write the fixtures**

Note `hover_card/with_options` passes `option:` (singular), exactly as the scenario does — the 1.6 constructor's keyword.

```bash
mkdir -p gem/test/golden/views/dropdown_menu
cat > gem/test/golden/views/dropdown_menu/default.html.erb <<'ERB'
<%= render RubyUI::DropdownMenu.new do %><%= render RubyUI::DropdownMenuTrigger.new(class: "w-full") do %><%= render RubyUI::Button.new(variant: :outline) do %>Open<% end %><% end %><%= render RubyUI::DropdownMenuContent.new do %><%= render RubyUI::DropdownMenuLabel.new do %>My Account<% end %><%= render RubyUI::DropdownMenuSeparator.new %><%= render RubyUI::DropdownMenuItem.new(href: "/profile") do %>Profile<% end %><%= render RubyUI::DropdownMenuItem.new(as: :div) do %>Billing<% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/dropdown_menu/fixed_strategy.html.erb <<'ERB'
<%= render RubyUI::DropdownMenu.new(options: {strategy: "fixed"}) do %><%= render RubyUI::DropdownMenuContent.new do %><%= render RubyUI::DropdownMenuItem.new(href: "#") do %>Item<% end %><% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/context_menu
cat > gem/test/golden/views/context_menu/default.html.erb <<'ERB'
<%= render RubyUI::ContextMenu.new do %><%= render RubyUI::ContextMenuTrigger.new do %>Right click here<% end %><%= render RubyUI::ContextMenuContent.new(class: "w-64") do %><%= render RubyUI::ContextMenuItem.new(href: "#", shortcut: "[") do %>Back<% end %><%= render RubyUI::ContextMenuItem.new(href: "#", shortcut: "]", disabled: true) do %>Forward<% end %><%= render RubyUI::ContextMenuSeparator.new %><%= render RubyUI::ContextMenuItem.new(href: "#", checked: true) do %>Show Bookmarks Bar<% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/context_menu/with_options.html.erb <<'ERB'
<%= render RubyUI::ContextMenu.new(options: {placement: "right-start"}) do %><%= render RubyUI::ContextMenuTrigger.new do %>Target<% end %><% end %>
ERB
cat > gem/test/golden/views/context_menu/label_inset.html.erb <<'ERB'
<%= render RubyUI::ContextMenuLabel.new(inset: true) do %>More Tools<% end %>
ERB
cat > gem/test/golden/views/context_menu/label_flush.html.erb <<'ERB'
<%= render RubyUI::ContextMenuLabel.new(inset: false) do %>More Tools<% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/popover
cat > gem/test/golden/views/popover/default.html.erb <<'ERB'
<%= render RubyUI::Popover.new do %><%= render RubyUI::PopoverTrigger.new(class: "w-full") do %><%= render RubyUI::Button.new(variant: :outline) do %>Open Popover<% end %><% end %><%= render RubyUI::PopoverContent.new(class: "w-40") do %><%= render RubyUI::Link.new(href: "/profile", variant: :ghost) do %>Profile<% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/popover/with_options.html.erb <<'ERB'
<%= render RubyUI::Popover.new(options: {trigger: "click", placement: "bottom-end"}) do %><%= render RubyUI::PopoverTrigger.new do %>T<% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/hover_card
cat > gem/test/golden/views/hover_card/default.html.erb <<'ERB'
<%= render RubyUI::HoverCard.new do %><%= render RubyUI::HoverCardTrigger.new do %><%= render RubyUI::Button.new(variant: :link) do %>@joeldrapper<% end %><% end %><%= render RubyUI::HoverCardContent.new do %><%= render RubyUI::Avatar.new do %><%= render RubyUI::AvatarFallback.new do %>JD<% end %><% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/hover_card/with_options.html.erb <<'ERB'
<%= render RubyUI::HoverCard.new(option: {placement: "bottom"}) do %><%= render RubyUI::HoverCardTrigger.new do %>T<% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/command
cat > gem/test/golden/views/command/dialog.html.erb <<'ERB'
<%= render RubyUI::CommandDialog.new do %><%= render RubyUI::CommandDialogTrigger.new do %><%= render RubyUI::Button.new(variant: :outline) do %><%= render RubyUI::ShortcutKey.new do %>K<% end %><% end %><% end %><%= render RubyUI::CommandDialogContent.new do %><%= render RubyUI::Command.new do %><%= render RubyUI::CommandInput.new %><%= render RubyUI::CommandEmpty.new do %>No results found.<% end %><%= render RubyUI::CommandList.new do %><%= render RubyUI::CommandGroup.new(title: "Components") do %><%= render RubyUI::CommandItem.new(value: "Accordion", href: "/docs/accordion") do %>Accordion<% end %><%= render RubyUI::CommandItem.new(value: "Alert", href: "/docs/alert") do %>Alert<% end %><% end %><% end %><% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/command/dialog_content_sm.html.erb <<'ERB'
<%= render RubyUI::CommandDialogContent.new(size: :sm) do %>body<% end %>
ERB
cat > gem/test/golden/views/command/dialog_content_md.html.erb <<'ERB'
<%= render RubyUI::CommandDialogContent.new(size: :md) do %>body<% end %>
ERB
cat > gem/test/golden/views/command/dialog_content_lg.html.erb <<'ERB'
<%= render RubyUI::CommandDialogContent.new(size: :lg) do %>body<% end %>
ERB
cat > gem/test/golden/views/command/trigger_with_custom_keybindings.html.erb <<'ERB'
<%= render RubyUI::CommandDialogTrigger.new(keybindings: ["keydown.ctrl+p@window"]) do %>Open<% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/combobox
cat > gem/test/golden/views/combobox/radio_items.html.erb <<'ERB'
<%= render RubyUI::Combobox.new(term: "frameworks") do %><%= render RubyUI::ComboboxTrigger.new(placeholder: "Select your framework") %><%= render RubyUI::ComboboxPopover.new do %><%= render RubyUI::ComboboxSearchInput.new(placeholder: "Type the framework name") %><%= render RubyUI::ComboboxList.new do %><%= render RubyUI::ComboboxEmptyState.new do %>No results<% end %><%= render RubyUI::ComboboxListGroup.new(label: "Ruby") do %><%= render RubyUI::ComboboxItem.new do %><%= render RubyUI::ComboboxRadio.new(name: "Rails", value: "rails") %><% end %><%= render RubyUI::ComboboxItem.new do %><%= render RubyUI::ComboboxRadio.new(name: "Hanami", value: "hanami") %><% end %><% end %><% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/combobox/multiple_with_badges.html.erb <<'ERB'
<%= render RubyUI::Combobox.new(multiple: true, term: "frameworks", placement: "top-start") do %><%= render RubyUI::ComboboxBadgeTrigger.new(placeholder: "Select", clear_button: true) %><%= render RubyUI::ComboboxPopover.new do %><%= render RubyUI::ComboboxList.new do %><%= render RubyUI::ComboboxToggleAllCheckbox.new %><%= render RubyUI::ComboboxItem.new do %><%= render RubyUI::ComboboxCheckbox.new(name: "Rails", value: "rails") %><%= render RubyUI::ComboboxItemIndicator.new %><% end %><% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/combobox/input_trigger.html.erb <<'ERB'
<%= render RubyUI::ComboboxInputTrigger.new(placeholder: "Pick one") %>
ERB
cat > gem/test/golden/views/combobox/clear_button.html.erb <<'ERB'
<%= render RubyUI::ComboboxClearButton.new %>
ERB
cat > gem/test/golden/views/combobox/badge.html.erb <<'ERB'
<%= render RubyUI::ComboboxBadge.new do %>Rails<% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/collapsible
cat > gem/test/golden/views/collapsible/closed.html.erb <<'ERB'
<%= render RubyUI::Collapsible.new do %><%= render RubyUI::CollapsibleTrigger.new do %><%= render RubyUI::Button.new(variant: :ghost) do %>Toggle<% end %><% end %><%= render RubyUI::CollapsibleContent.new do %>Hidden body<% end %><% end %>
ERB
cat > gem/test/golden/views/collapsible/open.html.erb <<'ERB'
<%= render RubyUI::Collapsible.new(open: true) do %><%= render RubyUI::CollapsibleTrigger.new do %><%= render RubyUI::Button.new(variant: :ghost) do %>Toggle<% end %><% end %><%= render RubyUI::CollapsibleContent.new do %>Visible body<% end %><% end %>
ERB
```

- [ ] **Step 2: Run the suite**

```bash
cd /Users/cirdes/Workspaces/ruby_ui/gem
bundle exec rake golden 2>&1 | grep -oE "[0-9]+ runs, [0-9]+ assertions, [0-9]+ failures, [0-9]+ errors, [0-9]+ skips|[0-9]+ scenarios without an ERB fixture|(Failure|Error):.*|Golden[A-Za-z]+Test#test_[a-z_0-9]+"
```

Expected: `306 runs, … 1 failures, 0 errors, 0 skips`; only `GoldenCoverageTest#test_every_scenario_has_a_fixture`; `103 scenarios without an ERB fixture`.

- [ ] **Step 3: Confirm the ruler did not move**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain gem/test/golden/snapshots gem/test/golden/strict
find gem/test/golden/views -name '*.html.erb' | wc -l
```

Expected: no output; `85`.

- [ ] **Step 4: Commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/test/golden/views
git commit -m "$(cat <<'MSG'
[Feature] Golden suite: ERB fixtures for the menus and overlays

dropdown_menu, context_menu, popover, hover_card, command, combobox,
collapsible — 22 fixtures, green against the frozen snapshots. 103
scenarios remain.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
MSG
)"
```

---

## Task 5: Batch 4 — form controls (21 fixtures)

checkbox (3), radio_button (2), switch (2), input (2), textarea (2), masked_input (1), native_select (3), input_otp (2), form (1), calendar (3).

**Files:**
- Create: 21 files under `gem/test/golden/views/{checkbox,radio_button,switch,input,textarea,masked_input,native_select,input_otp,form,calendar}/`

**Interfaces:**
- Consumes: `Golden::Harness.render_erb(scenario)`, `RubyUI::TestApp.view(Golden::Catalog::VIEWS_ROOT)` (Phase 2.0a).
- Produces: 21 fixtures.

- [ ] **Step 1: Write the fixtures**

```bash
mkdir -p gem/test/golden/views/checkbox
cat > gem/test/golden/views/checkbox/default.html.erb <<'ERB'
<%= render RubyUI::Checkbox.new(name: "terms", value: "1") %>
ERB
cat > gem/test/golden/views/checkbox/checked_disabled.html.erb <<'ERB'
<%= render RubyUI::Checkbox.new(name: "terms", checked: true, disabled: true) %>
ERB
cat > gem/test/golden/views/checkbox/group.html.erb <<'ERB'
<%= render RubyUI::CheckboxGroup.new do %><%= render RubyUI::Checkbox.new(name: "colors[]", value: "red") %><%= render RubyUI::Checkbox.new(name: "colors[]", value: "blue") %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/radio_button
cat > gem/test/golden/views/radio_button/default.html.erb <<'ERB'
<%= render RubyUI::RadioButton.new(name: "plan", value: "pro") %>
ERB
cat > gem/test/golden/views/radio_button/checked.html.erb <<'ERB'
<%= render RubyUI::RadioButton.new(name: "plan", value: "pro", checked: true) %>
ERB
```

```bash
mkdir -p gem/test/golden/views/switch
cat > gem/test/golden/views/switch/default.html.erb <<'ERB'
<%= render RubyUI::Switch.new(name: "notifications") %>
ERB
cat > gem/test/golden/views/switch/checked_without_hidden_input.html.erb <<'ERB'
<%= render RubyUI::Switch.new(name: "notifications", include_hidden: false, checked: true, checked_value: "yes", unchecked_value: "no") %>
ERB
```

```bash
mkdir -p gem/test/golden/views/input
cat > gem/test/golden/views/input/default.html.erb <<'ERB'
<%= render RubyUI::Input.new(name: "email", placeholder: "jane@example.com") %>
ERB
cat > gem/test/golden/views/input/typed_and_disabled.html.erb <<'ERB'
<%= render RubyUI::Input.new(type: :email, name: "email", value: "jane@example.com", disabled: true) %>
ERB
```

```bash
mkdir -p gem/test/golden/views/textarea
cat > gem/test/golden/views/textarea/default.html.erb <<'ERB'
<%= render RubyUI::Textarea.new(name: "bio", placeholder: "Tell us about yourself") %>
ERB
cat > gem/test/golden/views/textarea/rows_and_content.html.erb <<'ERB'
<%= render RubyUI::Textarea.new(name: "bio", rows: 8) do %>existing content<% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/masked_input
cat > gem/test/golden/views/masked_input/default.html.erb <<'ERB'
<%= render RubyUI::MaskedInput.new(name: "phone", data: {ruby_ui__masked_input_mask_value: "(00) 00000-0000"}) %>
ERB
```

```bash
mkdir -p gem/test/golden/views/native_select
cat > gem/test/golden/views/native_select/default.html.erb <<'ERB'
<%= render RubyUI::NativeSelect.new(name: "country") do %><%= render RubyUI::NativeSelectOption.new(value: "") do %>Select a country<% end %><%= render RubyUI::NativeSelectGroup.new(label: "Americas") do %><%= render RubyUI::NativeSelectOption.new(value: "br", selected: true) do %>Brazil<% end %><%= render RubyUI::NativeSelectOption.new(value: "us") do %>United States<% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/native_select/small.html.erb <<'ERB'
<%= render RubyUI::NativeSelect.new(size: :sm, name: "country") do %><%= render RubyUI::NativeSelectOption.new(value: "br") do %>Brazil<% end %><% end %>
ERB
cat > gem/test/golden/views/native_select/icon.html.erb <<'ERB'
<%= render RubyUI::NativeSelectIcon.new %>
ERB
```

```bash
mkdir -p gem/test/golden/views/input_otp
cat > gem/test/golden/views/input_otp/default.html.erb <<'ERB'
<%= render RubyUI::InputOtp.new(length: 6, name: "code") do %><%= render RubyUI::InputOtpGroup.new do %><%= render RubyUI::InputOtpSlot.new(index: 0) %><%= render RubyUI::InputOtpSlot.new(index: 1) %><%= render RubyUI::InputOtpSlot.new(index: 2) %><% end %><%= render RubyUI::InputOtpSeparator.new %><%= render RubyUI::InputOtpGroup.new do %><%= render RubyUI::InputOtpSlot.new(index: 3) %><%= render RubyUI::InputOtpSlot.new(index: 4) %><%= render RubyUI::InputOtpSlot.new(index: 5) %><% end %><% end %>
ERB
cat > gem/test/golden/views/input_otp/alphanumeric_pattern.html.erb <<'ERB'
<%= render RubyUI::InputOtp.new(length: 4, pattern: "[a-zA-Z0-9]", name: "code") do %><%= render RubyUI::InputOtpGroup.new do %><%= render RubyUI::InputOtpSlot.new(index: 0) %><% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/form
cat > gem/test/golden/views/form/default.html.erb <<'ERB'
<%= render RubyUI::Form.new(action: "/users", method: "post") do %><%= render RubyUI::FormField.new do %><%= render RubyUI::FormFieldLabel.new(for: "name") do %>Name<% end %><%= render RubyUI::Input.new(id: "name", name: "name", placeholder: "Jane Doe", required: true, minlength: "3") %><%= render RubyUI::FormFieldHint.new do %>At least 3 characters.<% end %><%= render RubyUI::FormFieldError.new do %>Name is required.<% end %><% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/calendar
cat > gem/test/golden/views/calendar/default.html.erb <<'ERB'
<%= render RubyUI::Calendar.new %>
ERB
cat > gem/test/golden/views/calendar/bound_to_input.html.erb <<'ERB'
<%= render RubyUI::Calendar.new(input_id: "#event-date", selected_date: "2026-05-15", min_date: "2026-05-07", date_format: "dd/MM/yyyy", class: "rounded-md border shadow") %>
ERB
cat > gem/test/golden/views/calendar/header_parts.html.erb <<'ERB'
<%= render RubyUI::CalendarHeader.new do %><%= render RubyUI::CalendarTitle.new(default: "May 2026") %><%= render RubyUI::CalendarPrev.new %><%= render RubyUI::CalendarNext.new %><% end %>
ERB
```

- [ ] **Step 2: Run the suite**

```bash
cd /Users/cirdes/Workspaces/ruby_ui/gem
bundle exec rake golden 2>&1 | grep -oE "[0-9]+ runs, [0-9]+ assertions, [0-9]+ failures, [0-9]+ errors, [0-9]+ skips|[0-9]+ scenarios without an ERB fixture|(Failure|Error):.*|Golden[A-Za-z]+Test#test_[a-z_0-9]+"
```

Expected: `327 runs, … 1 failures, 0 errors, 0 skips`; only `GoldenCoverageTest#test_every_scenario_has_a_fixture`; `82 scenarios without an ERB fixture`.

- [ ] **Step 3: Confirm the ruler did not move**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain gem/test/golden/snapshots gem/test/golden/strict
find gem/test/golden/views -name '*.html.erb' | wc -l
```

Expected: no output; `106`.

- [ ] **Step 4: Commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/test/golden/views
git commit -m "$(cat <<'MSG'
[Feature] Golden suite: ERB fixtures for the form controls

checkbox, radio_button, switch, input, textarea, masked_input,
native_select, input_otp, form, calendar — 21 fixtures, green against
the frozen snapshots. 82 scenarios remain.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
MSG
)"
```

---

## Task 6: Batch 5 — layout and status (23 fixtures)

alert (4), badge (4), avatar (5), breadcrumb (1), card (1), separator (4), skeleton (1), progress (3). `badge/all_variants` is the one loop in the catalog: 28 badges side by side with nothing between them, which is exactly what the strict lane checks.

**Files:**
- Create: 23 files under `gem/test/golden/views/{alert,badge,avatar,breadcrumb,card,separator,skeleton,progress}/`

**Interfaces:**
- Consumes: `Golden::Harness.render_erb(scenario)`, `RubyUI::TestApp.view(Golden::Catalog::VIEWS_ROOT)` (Phase 2.0a).
- Produces: 23 fixtures.

- [ ] **Step 1: Write the fixtures**

```bash
mkdir -p gem/test/golden/views/alert
cat > gem/test/golden/views/alert/default.html.erb <<'ERB'
<%= render RubyUI::Alert.new do %><%= render RubyUI::AlertTitle.new do %>Heads up!<% end %><%= render RubyUI::AlertDescription.new do %>You can add components to your app.<% end %><% end %>
ERB
cat > gem/test/golden/views/alert/destructive.html.erb <<'ERB'
<%= render RubyUI::Alert.new(variant: :destructive) do %><%= render RubyUI::AlertTitle.new do %>Error<% end %><%= render RubyUI::AlertDescription.new do %>Your session expired.<% end %><% end %>
ERB
cat > gem/test/golden/views/alert/warning.html.erb <<'ERB'
<%= render RubyUI::Alert.new(variant: :warning) do %><%= render RubyUI::AlertTitle.new do %>Careful<% end %><% end %>
ERB
cat > gem/test/golden/views/alert/success.html.erb <<'ERB'
<%= render RubyUI::Alert.new(variant: :success) do %><%= render RubyUI::AlertTitle.new do %>Done<% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/badge
cat > gem/test/golden/views/badge/size_sm.html.erb <<'ERB'
<%= render RubyUI::Badge.new(size: :sm) do %>Badge<% end %>
ERB
cat > gem/test/golden/views/badge/size_md.html.erb <<'ERB'
<%= render RubyUI::Badge.new(size: :md) do %>Badge<% end %>
ERB
cat > gem/test/golden/views/badge/size_lg.html.erb <<'ERB'
<%= render RubyUI::Badge.new(size: :lg) do %>Badge<% end %>
ERB
cat > gem/test/golden/views/badge/all_variants.html.erb <<'ERB'
<% RubyUI::Badge::COLORS.each_key do |variant| %><%= render RubyUI::Badge.new(variant: variant) do %><%= variant %><% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/avatar
cat > gem/test/golden/views/avatar/image_with_fallback.html.erb <<'ERB'
<%= render RubyUI::Avatar.new do %><%= render RubyUI::AvatarImage.new(src: "/avatar.png", alt: "Jane Doe") %><%= render RubyUI::AvatarFallback.new do %>JD<% end %><% end %>
ERB
cat > gem/test/golden/views/avatar/size_sm.html.erb <<'ERB'
<%= render RubyUI::Avatar.new(size: :sm) do %><%= render RubyUI::AvatarFallback.new do %>JD<% end %><% end %>
ERB
cat > gem/test/golden/views/avatar/size_md.html.erb <<'ERB'
<%= render RubyUI::Avatar.new(size: :md) do %><%= render RubyUI::AvatarFallback.new do %>JD<% end %><% end %>
ERB
cat > gem/test/golden/views/avatar/size_lg.html.erb <<'ERB'
<%= render RubyUI::Avatar.new(size: :lg) do %><%= render RubyUI::AvatarFallback.new do %>JD<% end %><% end %>
ERB
cat > gem/test/golden/views/avatar/size_xl.html.erb <<'ERB'
<%= render RubyUI::Avatar.new(size: :xl) do %><%= render RubyUI::AvatarFallback.new do %>JD<% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/breadcrumb
cat > gem/test/golden/views/breadcrumb/default.html.erb <<'ERB'
<%= render RubyUI::Breadcrumb.new do %><%= render RubyUI::BreadcrumbList.new do %><%= render RubyUI::BreadcrumbItem.new do %><%= render RubyUI::BreadcrumbLink.new(href: "/") do %>Home<% end %><% end %><%= render RubyUI::BreadcrumbSeparator.new %><%= render RubyUI::BreadcrumbItem.new do %><%= render RubyUI::BreadcrumbEllipsis.new %><% end %><%= render RubyUI::BreadcrumbSeparator.new %><%= render RubyUI::BreadcrumbItem.new do %><%= render RubyUI::BreadcrumbPage.new do %>Current<% end %><% end %><% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/card
cat > gem/test/golden/views/card/default.html.erb <<'ERB'
<%= render RubyUI::Card.new do %><%= render RubyUI::CardHeader.new do %><%= render RubyUI::CardTitle.new do %>Create project<% end %><%= render RubyUI::CardDescription.new do %>Deploy your new project in one click.<% end %><% end %><%= render RubyUI::CardContent.new do %>Body<% end %><%= render RubyUI::CardFooter.new do %><%= render RubyUI::Button.new do %>Deploy<% end %><% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/separator
cat > gem/test/golden/views/separator/default.html.erb <<'ERB'
<%= render RubyUI::Separator.new %>
ERB
cat > gem/test/golden/views/separator/vertical.html.erb <<'ERB'
<%= render RubyUI::Separator.new(orientation: :vertical) %>
ERB
cat > gem/test/golden/views/separator/not_decorative.html.erb <<'ERB'
<%= render RubyUI::Separator.new(decorative: false) %>
ERB
cat > gem/test/golden/views/separator/as_hr.html.erb <<'ERB'
<%= render RubyUI::Separator.new(as: :hr) %>
ERB
```

```bash
mkdir -p gem/test/golden/views/skeleton
cat > gem/test/golden/views/skeleton/default.html.erb <<'ERB'
<%= render RubyUI::Skeleton.new(class: "w-14 h-14") %>
ERB
```

```bash
mkdir -p gem/test/golden/views/progress
cat > gem/test/golden/views/progress/value_0.html.erb <<'ERB'
<%= render RubyUI::Progress.new(value: 0) %>
ERB
cat > gem/test/golden/views/progress/value_33_5.html.erb <<'ERB'
<%= render RubyUI::Progress.new(value: 33.5) %>
ERB
cat > gem/test/golden/views/progress/value_100.html.erb <<'ERB'
<%= render RubyUI::Progress.new(value: 100) %>
ERB
```

- [ ] **Step 2: Run the suite**

```bash
cd /Users/cirdes/Workspaces/ruby_ui/gem
bundle exec rake golden 2>&1 | grep -oE "[0-9]+ runs, [0-9]+ assertions, [0-9]+ failures, [0-9]+ errors, [0-9]+ skips|[0-9]+ scenarios without an ERB fixture|(Failure|Error):.*|Golden[A-Za-z]+Test#test_[a-z_0-9]+"
```

Expected: `350 runs, … 1 failures, 0 errors, 0 skips`; only `GoldenCoverageTest#test_every_scenario_has_a_fixture`; `59 scenarios without an ERB fixture`.

- [ ] **Step 3: Confirm the ruler did not move**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain gem/test/golden/snapshots gem/test/golden/strict
find gem/test/golden/views -name '*.html.erb' | wc -l
```

Expected: no output; `129`.

- [ ] **Step 4: Commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/test/golden/views
git commit -m "$(cat <<'MSG'
[Feature] Golden suite: ERB fixtures for layout and status

alert, badge, avatar, breadcrumb, card, separator, skeleton, progress —
23 fixtures, green against the frozen snapshots; badge/all_variants is
the catalog's one loop, 28 badges with nothing between them. 59
scenarios remain.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
MSG
)"
```

---

## Task 7: Batch 6 — content and composition (23 fixtures)

empty (2), table (2), tabs (1), pagination (1), carousel (3), chart (1), clipboard (4), theme_toggle (1), bubble (4), message (1), message_scroller (3). `table/detached_row` renders a bare `<tr>`; the canonical form parses inside a `<template>` precisely so that survives, and Herb validates the template source (ERB tags only), not the rendered output — so the fixture compiles.

**Files:**
- Create: 23 files under `gem/test/golden/views/{empty,table,tabs,pagination,carousel,chart,clipboard,theme_toggle,bubble,message,message_scroller}/`

**Interfaces:**
- Consumes: `Golden::Harness.render_erb(scenario)`, `RubyUI::TestApp.view(Golden::Catalog::VIEWS_ROOT)` (Phase 2.0a).
- Produces: 23 fixtures.

- [ ] **Step 1: Write the fixtures**

```bash
mkdir -p gem/test/golden/views/empty
cat > gem/test/golden/views/empty/default.html.erb <<'ERB'
<%= render RubyUI::Empty.new do %><%= render RubyUI::EmptyHeader.new do %><%= render RubyUI::EmptyMedia.new(variant: :icon) do %>I<% end %><%= render RubyUI::EmptyTitle.new do %>Nothing here<% end %><%= render RubyUI::EmptyDescription.new do %>No content yet.<% end %><% end %><%= render RubyUI::EmptyContent.new do %><%= render RubyUI::Button.new do %>Create<% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/empty/media_default.html.erb <<'ERB'
<%= render RubyUI::EmptyMedia.new do %>M<% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/table
cat > gem/test/golden/views/table/default.html.erb <<'ERB'
<%= render RubyUI::Table.new do %><%= render RubyUI::TableCaption.new do %>Employees at Acme inc.<% end %><%= render RubyUI::TableHeader.new do %><%= render RubyUI::TableRow.new do %><%= render RubyUI::TableHead.new do %>Name<% end %><%= render RubyUI::TableHead.new(class: "text-right") do %>Amount<% end %><% end %><% end %><%= render RubyUI::TableBody.new do %><%= render RubyUI::TableRow.new do %><%= render RubyUI::TableCell.new(class: "font-medium") do %>INV-0001<% end %><%= render RubyUI::TableCell.new(class: "text-right") do %>100<% end %><% end %><% end %><%= render RubyUI::TableFooter.new do %><%= render RubyUI::TableRow.new do %><%= render RubyUI::TableHead.new(colspan: 1) do %>Total<% end %><%= render RubyUI::TableHead.new(class: "text-right") do %>100<% end %><% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/table/detached_row.html.erb <<'ERB'
<%= render RubyUI::TableRow.new do %><%= render RubyUI::TableCell.new do %>detached<% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/tabs
cat > gem/test/golden/views/tabs/default.html.erb <<'ERB'
<%= render RubyUI::Tabs.new(default: "account", class: "w-96") do %><%= render RubyUI::TabsList.new do %><%= render RubyUI::TabsTrigger.new(value: "account") do %>Account<% end %><%= render RubyUI::TabsTrigger.new(value: "password", as: :a, href: "#password") do %>Password<% end %><% end %><%= render RubyUI::TabsContent.new(value: "account") do %>Account panel<% end %><%= render RubyUI::TabsContent.new(value: "password") do %>Password panel<% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/pagination
cat > gem/test/golden/views/pagination/default.html.erb <<'ERB'
<%= render RubyUI::Pagination.new do %><%= render RubyUI::PaginationContent.new do %><%= render RubyUI::PaginationItem.new(href: "/page/1") do %>Prev<% end %><%= render RubyUI::PaginationEllipsis.new %><%= render RubyUI::PaginationItem.new(href: "/page/4") do %>4<% end %><%= render RubyUI::PaginationItem.new(href: "/page/5", active: true) do %>5<% end %><%= render RubyUI::PaginationEllipsis.new %><%= render RubyUI::PaginationItem.new(href: "/page/6") do %>Next<% end %><% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/carousel
cat > gem/test/golden/views/carousel/horizontal.html.erb <<'ERB'
<%= render RubyUI::Carousel.new(orientation: :horizontal) do %><%= render RubyUI::CarouselContent.new do %><%= render RubyUI::CarouselItem.new do %>1<% end %><%= render RubyUI::CarouselItem.new do %>2<% end %><% end %><%= render RubyUI::CarouselPrevious.new %><%= render RubyUI::CarouselNext.new %><% end %>
ERB
cat > gem/test/golden/views/carousel/vertical.html.erb <<'ERB'
<%= render RubyUI::Carousel.new(orientation: :vertical) do %><%= render RubyUI::CarouselContent.new do %><%= render RubyUI::CarouselItem.new do %>1<% end %><%= render RubyUI::CarouselItem.new do %>2<% end %><% end %><%= render RubyUI::CarouselPrevious.new %><%= render RubyUI::CarouselNext.new %><% end %>
ERB
cat > gem/test/golden/views/carousel/with_options.html.erb <<'ERB'
<%= render RubyUI::Carousel.new(options: {loop: true, align: "start"}) do %><%= render RubyUI::CarouselContent.new do %><%= render RubyUI::CarouselItem.new do %>1<% end %><% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/chart
cat > gem/test/golden/views/chart/bar.html.erb <<'ERB'
<%= render RubyUI::Chart.new(options: {type: "bar", data: {labels: ["Phlex", "ERB"], datasets: [{label: "render time (ms)", data: [100, 520]}]}, options: {indexAxis: "y", scales: {y: {beginAtZero: true}}}}) %>
ERB
```

```bash
mkdir -p gem/test/golden/views/clipboard
cat > gem/test/golden/views/clipboard/default.html.erb <<'ERB'
<%= render RubyUI::Clipboard.new %>
ERB
cat > gem/test/golden/views/clipboard/custom_source_and_trigger.html.erb <<'ERB'
<%= render RubyUI::Clipboard.new(success: "Copiado!", error: "Falhou!") do %><%= render RubyUI::ClipboardSource.new do %>gem install ruby_ui<% end %><%= render RubyUI::ClipboardTrigger.new do %><%= render RubyUI::Button.new(icon: true) do %>C<% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/clipboard/popover_success.html.erb <<'ERB'
<%= render RubyUI::ClipboardPopover.new(type: :success) do %>success<% end %>
ERB
cat > gem/test/golden/views/clipboard/popover_error.html.erb <<'ERB'
<%= render RubyUI::ClipboardPopover.new(type: :error) do %>error<% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/theme_toggle
cat > gem/test/golden/views/theme_toggle/default.html.erb <<'ERB'
<%= render RubyUI::ThemeToggle.new do %>T<% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/bubble
cat > gem/test/golden/views/bubble/default.html.erb <<'ERB'
<%= render RubyUI::Bubble.new do %><%= render RubyUI::BubbleContent.new do %>Hi<% end %><% end %>
ERB
cat > gem/test/golden/views/bubble/muted_aligned_end_with_reactions.html.erb <<'ERB'
<%= render RubyUI::BubbleGroup.new do %><%= render RubyUI::Bubble.new(variant: :muted, align: :end) do %><%= render RubyUI::BubbleContent.new do %>Hi<% end %><%= render RubyUI::BubbleReactions.new do %>OK<% end %><% end %><% end %>
ERB
cat > gem/test/golden/views/bubble/content_as_anchor.html.erb <<'ERB'
<%= render RubyUI::Bubble.new do %><%= render RubyUI::BubbleContent.new(as: :a, href: "#") do %>Open<% end %><% end %>
ERB
cat > gem/test/golden/views/bubble/reactions_top_start.html.erb <<'ERB'
<%= render RubyUI::BubbleReactions.new(side: :top, align: :start) do %>OK<% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/message
cat > gem/test/golden/views/message/group_with_avatar_header_footer.html.erb <<'ERB'
<%= render RubyUI::MessageGroup.new do %><%= render RubyUI::Message.new do %><%= render RubyUI::MessageAvatar.new do %><%= render RubyUI::Avatar.new do %><%= render RubyUI::AvatarFallback.new do %>OL<% end %><% end %><% end %><%= render RubyUI::MessageContent.new do %><%= render RubyUI::MessageHeader.new do %>Oliver<% end %><%= render RubyUI::Bubble.new do %><%= render RubyUI::BubbleContent.new do %>Hi<% end %><% end %><%= render RubyUI::MessageFooter.new do %>Delivered<% end %><% end %><% end %><%= render RubyUI::Message.new(align: :end) do %><%= render RubyUI::MessageContent.new do %><%= render RubyUI::Bubble.new(align: :end) do %><%= render RubyUI::BubbleContent.new do %>Hey<% end %><% end %><% end %><% end %><% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/message_scroller
cat > gem/test/golden/views/message_scroller/default.html.erb <<'ERB'
<%= render RubyUI::MessageScrollerProvider.new do %><%= render RubyUI::MessageScroller.new do %><%= render RubyUI::MessageScrollerViewport.new do %><%= render RubyUI::MessageScrollerContent.new do %><%= render RubyUI::MessageScrollerItem.new(message_id: "m1") do %>first<% end %><%= render RubyUI::MessageScrollerItem.new(scroll_anchor: true, message_id: "m2") do %>last<% end %><% end %><% end %><%= render RubyUI::MessageScrollerButton.new %><% end %><% end %>
ERB
cat > gem/test/golden/views/message_scroller/provider_custom_values.html.erb <<'ERB'
<%= render RubyUI::MessageScrollerProvider.new(auto_scroll: false, previous_item_peek: 32, default_position: :last_anchor, preserve_on_prepend: false) do %>x<% end %>
ERB
cat > gem/test/golden/views/message_scroller/button_start.html.erb <<'ERB'
<%= render RubyUI::MessageScrollerButton.new(direction: :start) %>
ERB
```

- [ ] **Step 2: Run the suite**

```bash
cd /Users/cirdes/Workspaces/ruby_ui/gem
bundle exec rake golden 2>&1 | grep -oE "[0-9]+ runs, [0-9]+ assertions, [0-9]+ failures, [0-9]+ errors, [0-9]+ skips|[0-9]+ scenarios without an ERB fixture|(Failure|Error):.*|Golden[A-Za-z]+Test#test_[a-z_0-9]+"
```

Expected: `373 runs, … 1 failures, 0 errors, 0 skips`; only `GoldenCoverageTest#test_every_scenario_has_a_fixture`; `36 scenarios without an ERB fixture`.

- [ ] **Step 3: Confirm the ruler did not move**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain gem/test/golden/snapshots gem/test/golden/strict
find gem/test/golden/views -name '*.html.erb' | wc -l
```

Expected: no output; `152`.

- [ ] **Step 4: Commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/test/golden/views
git commit -m "$(cat <<'MSG'
[Feature] Golden suite: ERB fixtures for content and composition

empty, table, tabs, pagination, carousel, chart, clipboard,
theme_toggle, bubble, message, message_scroller — 23 fixtures, green
against the frozen snapshots. 36 scenarios remain: link and
typography.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
MSG
)"
```

---

## Task 7b: The first ERB render on a thread — create ActiveSupport's instrumenter before the pin

**Added during execution, after Task 7.** A controller run of the suite after Task 7 failed `GoldenSuiteTest#test_tooltip__default__erb` on its first assertion — the two consecutive renders of the fixture differed — while the same test passed in the Task 3 run and in thirteen other runs. Traced with a caller log on `Golden::Harness.next_hex`: the first `SecureRandom.hex` call inside the very first `render_erb` of the process comes from `ActiveSupport::Notifications::Instrumenter#unique_id` (`SecureRandom.hex(10)`), because ActionView instruments every render and the per-thread `Instrumenter` is created lazily on the first instrumented event. That call lands inside the pin window, takes the counter's first value, and every generated id in that one render is shifted by one (`tooltip00000002`); the next render, with the instrumenter already created, mints `tooltip00000001`. The scenario fails its own determinism check whenever one of the three fixtures whose component mints an id (`tooltip/default`, `select/default`, `date_picker/generated_id`) happens to be the first ERB-lane test Minitest runs — about 3 in 190 runs. The Phlex lane never instruments, so Phase 1 and 2.0a could not see it, and Button's fixtures mint no id.

Reproduced deterministically: in a fresh `Thread` (the instrumenter registry is per thread, `isolation_level = :thread`) two consecutive `render_erb` calls give `["tooltip00000002", "tooltip00000001"]`; with `ActiveSupport::Notifications.instrumenter` called before `@active = true`, `["tooltip00000001", "tooltip00000001"]` — same for the other two.

**Ruling recorded in the SDD ledger:** the Global Constraint "the harness does not change" is amended for this task only. The plan's STOP protects the spec's requirement that the harness pins the two sources of randomness so both lanes are stable; the defect is in the pin itself and the fix is one line plus one test, both reviewable and revertible. It is surfaced here, in the commit, in the PR body and in the execution's rulings list.

**Files:**
- Modify: `gem/test/golden/harness.rb` (`render_erb`, one line)
- Modify: `gem/test/golden/harness_test.rb` (two `require`s, one test)

**Interfaces:**
- Consumes: `Golden::Harness.render_erb(scenario)`, `Golden::Catalog.scenarios`, `Scenario#slug`.
- Produces: `render_erb` creates the current thread's `ActiveSupport::Notifications` instrumenter before activating the pin; `GoldenHarnessTest#test_erb_lane_mints_the_same_ids_on_a_threads_first_render`.

- [ ] **Step 1: Write the failing test**

In `gem/test/golden/harness_test.rb`, after `require "golden/harness"` add:

```ruby
require "golden/catalog"
require "golden/scenarios"
```

and inside `class GoldenHarnessTest`, after `test_pins_rand_to_the_same_value_on_every_render` and before `private`, add:

```ruby
  # ActionView instruments every render, and the first instrumentation on a
  # thread creates the Instrumenter, whose id is SecureRandom.hex(10). A fresh
  # thread reproduces "the first ERB render of the process": the pin must not
  # hand that call the counter's first value, or every generated id in that one
  # render is shifted by one and the scenario fails its own determinism check.
  def test_erb_lane_mints_the_same_ids_on_a_threads_first_render
    scenario = Golden::Catalog.scenarios.find { |candidate| candidate.slug == "tooltip/default" }
    first, second = Thread.new { Array.new(2) { Golden::Harness.render_erb(scenario) } }.value

    assert_equal second, first
    assert_includes first, 'id="tooltip00000001"'
  end
```

- [ ] **Step 2: Run it and confirm it fails**

```bash
cd /Users/cirdes/Workspaces/ruby_ui/gem
bundle exec rake test N=/test_erb_lane_mints_the_same_ids_on_a_threads_first_render/ 2>&1 | grep -v 'warning:' | grep -E "runs,|Failure|tooltip0000000[12]" | head -6
```

Expected: `1 runs, 1 assertions, 1 failures` — the `assert_equal` fails, and the diff it prints shows `id="tooltip00000002"` in the first render against `id="tooltip00000001"` in the second.

- [ ] **Step 3: Create the instrumenter before the pin**

In `gem/test/golden/harness.rb`, inside `render_erb`, before the line `@active = true`, insert:

```ruby
        # ActionView instruments the render, and the first instrumentation on a
        # thread creates the Instrumenter, whose id is SecureRandom.hex(10).
        # Inside the pin that call would take the counter's first value and
        # shift every generated id in that one render by one. Create it first.
        ActiveSupport::Notifications.instrumenter
```

so the method reads:

```ruby
      def render_erb(scenario)
        # ActionView instruments the render, and the first instrumentation on a
        # thread creates the Instrumenter, whose id is SecureRandom.hex(10).
        # Inside the pin that call would take the counter's first value and
        # shift every generated id in that one render by one. Create it first.
        ActiveSupport::Notifications.instrumenter
        @active = true
        @hex_calls = 0
        @rand_calls = 0
        RubyUI::TestApp.view(Golden::Catalog::VIEWS_ROOT).render(template: "#{scenario.component}/#{scenario.name}")
      ensure
        @active = false
      end
```

- [ ] **Step 4: Run the test and the suite**

```bash
cd /Users/cirdes/Workspaces/ruby_ui/gem
bundle exec rake test N=/test_erb_lane_mints_the_same_ids_on_a_threads_first_render/ 2>&1 | grep -E "runs,"
bundle exec rake golden 2>&1 | grep -oE "[0-9]+ runs, [0-9]+ assertions, [0-9]+ failures, [0-9]+ errors, [0-9]+ skips|[0-9]+ scenarios without an ERB fixture|(Failure|Error):.*|Golden[A-Za-z]+Test#test_[a-z_0-9]+"
bundle exec standardrb
```

Expected: `1 runs, 3 assertions, 0 failures` (`assert_includes` counts two); then `374 runs, … 1 failures, 0 errors, 0 skips` with only `GoldenCoverageTest#test_every_scenario_has_a_fixture` and `36 scenarios without an ERB fixture` (373 + this test); `423 files inspected, no offenses detected`.

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain gem/test/golden/snapshots gem/test/golden/strict
```

Expected: no output.

- [ ] **Step 5: Commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/test/golden/harness.rb gem/test/golden/harness_test.rb
git commit -m "$(cat <<'MSG'
[Bug Fix] Golden suite: the first ERB render no longer hands the instrumenter id to the pin

ActionView instruments every render, and the first instrumentation on a
thread creates ActiveSupport's Instrumenter, whose id is
SecureRandom.hex(10). That call landed inside the harness pin on the
first ERB render of a process, took the counter's first value, and
shifted every generated id in that one render by one — so
tooltip/default, select/default or date_picker/generated_id failed
their own determinism check whenever one of them was the first ERB-lane
test to run (about 3 runs in 190). render_erb now creates the
instrumenter before activating the pin; a test renders twice on a fresh
thread, where the registry is empty, and asserts identical output.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
MSG
)"
```

From here every count is one higher than the progress table shows: `rake golden` 410 and `rake` 776 at the end.

---

## Task 8: Batch 7 — the enumerative families, and the coverage test goes green (36 fixtures)

link (11), typography (25). Generated scenarios in the catalog (`%i[…].each`, `(1..9).each`) — each interpolated value written out (rule 9). After this task no scenario lacks a fixture and the suite is entirely green.

**Files:**
- Create: 36 files under `gem/test/golden/views/{link,typography}/`

**Interfaces:**
- Consumes: `Golden::Harness.render_erb(scenario)`, `RubyUI::TestApp.view(Golden::Catalog::VIEWS_ROOT)` (Phase 2.0a).
- Produces: 36 fixtures; `test_every_scenario_has_a_fixture` passes.

- [ ] **Step 1: Write the fixtures**

```bash
mkdir -p gem/test/golden/views/link
cat > gem/test/golden/views/link/variant_primary.html.erb <<'ERB'
<%= render RubyUI::Link.new(href: "/docs", variant: :primary) do %>primary<% end %>
ERB
cat > gem/test/golden/views/link/variant_secondary.html.erb <<'ERB'
<%= render RubyUI::Link.new(href: "/docs", variant: :secondary) do %>secondary<% end %>
ERB
cat > gem/test/golden/views/link/variant_destructive.html.erb <<'ERB'
<%= render RubyUI::Link.new(href: "/docs", variant: :destructive) do %>destructive<% end %>
ERB
cat > gem/test/golden/views/link/variant_outline.html.erb <<'ERB'
<%= render RubyUI::Link.new(href: "/docs", variant: :outline) do %>outline<% end %>
ERB
cat > gem/test/golden/views/link/variant_ghost.html.erb <<'ERB'
<%= render RubyUI::Link.new(href: "/docs", variant: :ghost) do %>ghost<% end %>
ERB
cat > gem/test/golden/views/link/variant_link.html.erb <<'ERB'
<%= render RubyUI::Link.new(href: "/docs", variant: :link) do %>link<% end %>
ERB
cat > gem/test/golden/views/link/size_sm.html.erb <<'ERB'
<%= render RubyUI::Link.new(href: "/docs", size: :sm) do %>sm<% end %>
ERB
cat > gem/test/golden/views/link/size_md.html.erb <<'ERB'
<%= render RubyUI::Link.new(href: "/docs", size: :md) do %>md<% end %>
ERB
cat > gem/test/golden/views/link/size_lg.html.erb <<'ERB'
<%= render RubyUI::Link.new(href: "/docs", size: :lg) do %>lg<% end %>
ERB
cat > gem/test/golden/views/link/size_xl.html.erb <<'ERB'
<%= render RubyUI::Link.new(href: "/docs", size: :xl) do %>xl<% end %>
ERB
cat > gem/test/golden/views/link/icon.html.erb <<'ERB'
<%= render RubyUI::Link.new(href: "/docs", icon: true) do %>X<% end %>
ERB
```

```bash
mkdir -p gem/test/golden/views/typography
cat > gem/test/golden/views/typography/heading_level_1.html.erb <<'ERB'
<%= render RubyUI::Heading.new(level: "1") do %>H1<% end %>
ERB
cat > gem/test/golden/views/typography/heading_level_2.html.erb <<'ERB'
<%= render RubyUI::Heading.new(level: "2") do %>H2<% end %>
ERB
cat > gem/test/golden/views/typography/heading_level_3.html.erb <<'ERB'
<%= render RubyUI::Heading.new(level: "3") do %>H3<% end %>
ERB
cat > gem/test/golden/views/typography/heading_level_4.html.erb <<'ERB'
<%= render RubyUI::Heading.new(level: "4") do %>H4<% end %>
ERB
cat > gem/test/golden/views/typography/heading_custom_size.html.erb <<'ERB'
<%= render RubyUI::Heading.new(as: "h2", size: "7") do %>Custom Heading<% end %>
ERB
cat > gem/test/golden/views/typography/text_size_1.html.erb <<'ERB'
<%= render RubyUI::Text.new(size: "1") do %>Size 1<% end %>
ERB
cat > gem/test/golden/views/typography/text_size_2.html.erb <<'ERB'
<%= render RubyUI::Text.new(size: "2") do %>Size 2<% end %>
ERB
cat > gem/test/golden/views/typography/text_size_3.html.erb <<'ERB'
<%= render RubyUI::Text.new(size: "3") do %>Size 3<% end %>
ERB
cat > gem/test/golden/views/typography/text_size_4.html.erb <<'ERB'
<%= render RubyUI::Text.new(size: "4") do %>Size 4<% end %>
ERB
cat > gem/test/golden/views/typography/text_size_5.html.erb <<'ERB'
<%= render RubyUI::Text.new(size: "5") do %>Size 5<% end %>
ERB
cat > gem/test/golden/views/typography/text_size_6.html.erb <<'ERB'
<%= render RubyUI::Text.new(size: "6") do %>Size 6<% end %>
ERB
cat > gem/test/golden/views/typography/text_size_7.html.erb <<'ERB'
<%= render RubyUI::Text.new(size: "7") do %>Size 7<% end %>
ERB
cat > gem/test/golden/views/typography/text_size_8.html.erb <<'ERB'
<%= render RubyUI::Text.new(size: "8") do %>Size 8<% end %>
ERB
cat > gem/test/golden/views/typography/text_size_9.html.erb <<'ERB'
<%= render RubyUI::Text.new(size: "9") do %>Size 9<% end %>
ERB
cat > gem/test/golden/views/typography/text_weight_light.html.erb <<'ERB'
<%= render RubyUI::Text.new(weight: "light") do %>light<% end %>
ERB
cat > gem/test/golden/views/typography/text_weight_regular.html.erb <<'ERB'
<%= render RubyUI::Text.new(weight: "regular") do %>regular<% end %>
ERB
cat > gem/test/golden/views/typography/text_weight_medium.html.erb <<'ERB'
<%= render RubyUI::Text.new(weight: "medium") do %>medium<% end %>
ERB
cat > gem/test/golden/views/typography/text_weight_bold.html.erb <<'ERB'
<%= render RubyUI::Text.new(weight: "bold") do %>bold<% end %>
ERB
cat > gem/test/golden/views/typography/text_as_p.html.erb <<'ERB'
<%= render RubyUI::Text.new(as: "p") do %>p<% end %>
ERB
cat > gem/test/golden/views/typography/text_as_span.html.erb <<'ERB'
<%= render RubyUI::Text.new(as: "span") do %>span<% end %>
ERB
cat > gem/test/golden/views/typography/text_as_div.html.erb <<'ERB'
<%= render RubyUI::Text.new(as: "div") do %>div<% end %>
ERB
cat > gem/test/golden/views/typography/text_as_label.html.erb <<'ERB'
<%= render RubyUI::Text.new(as: "label") do %>label<% end %>
ERB
cat > gem/test/golden/views/typography/inline_code.html.erb <<'ERB'
<%= render RubyUI::InlineCode.new do %>RubyUI::VERSION<% end %>
ERB
cat > gem/test/golden/views/typography/inline_link.html.erb <<'ERB'
<%= render RubyUI::InlineLink.new(href: "/docs") do %>the docs<% end %>
ERB
cat > gem/test/golden/views/typography/blockquote.html.erb <<'ERB'
<%= render RubyUI::TypographyBlockquote.new do %>After all, we are all Rubyists.<% end %>
ERB
```

- [ ] **Step 2: Run the suite — everything green**

```bash
cd /Users/cirdes/Workspaces/ruby_ui/gem
bundle exec rake golden 2>&1 | grep -oE "[0-9]+ runs, [0-9]+ assertions, [0-9]+ failures, [0-9]+ errors, [0-9]+ skips|[0-9]+ scenarios without an ERB fixture|(Failure|Error):.*|Golden[A-Za-z]+Test#test_[a-z_0-9]+"
```

Expected: exactly one line, `410 runs, … 0 failures, 0 errors, 0 skips`. No `Failure:`, no test name, no `scenarios without an ERB fixture`.

- [ ] **Step 3: Confirm the ruler did not move and the lane is complete**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain gem/test/golden/snapshots gem/test/golden/strict
find gem/test/golden/views -name '*.html.erb' | wc -l
find gem/test/golden/snapshots -name '*.html' | wc -l
```

Expected: no output; `188`; `188`.

- [ ] **Step 4: Commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/test/golden/views
git commit -m "$(cat <<'MSG'
[Feature] Golden suite: ERB fixtures for link and typography — every scenario has one

The last 36: link's six variants, four sizes and icon; typography's
headings, nine text sizes, four weights, four elements, inline code,
inline link and blockquote. 188 scenarios, 188 fixtures, 188 canonical
and 188 strict snapshots, every component still Phlex. From here a
migration changes an implementation, never the ruler.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
MSG
)"
```

---

## Task 9: Record decision 10 and amend the spec and the catalog header

Decision 8 named trim mode (`<%-`/`-%>`) as one of the two ways to keep a sidecar or fixture whitespace-tight. Measured through Herb (table above, Appendix A), it is not that for an indented one-render-per-line layout: the newline after a content-terminated `end` and the indentation before an output tag both survive. That goes into the decision log so plan 2.1 does not rediscover it when it writes the first sidecar, and the spec's three passages that assume trim mode, or a strict lane limited to text-bearing components, are amended: §6 Phase 2.0, §6.2's definition of done, §9.1 part 2.

**Files:**
- Modify: `design/v2/decisions.md` (append entry 10)
- Modify: `design/2026-09-19-rubyui-2-0-design.md` (§6 Phase 2.0 ERB-lane bullet; §6.2 definition of done; §9.1 part 2)
- Modify: `gem/test/golden/scenarios.rb` (header comment only)

- [ ] **Step 1: Append entry 10 to the decision log**

Append to the end of `design/v2/decisions.md`:

```markdown

## 10. Every ERB fixture is one line; what Herb's trim mode removes and what it keeps — 2026-09-20

Decision 8 said fixtures and sidecars are written "one line, or `<%-`/`-%>`".
Measured through the harness — a template under `Rails.root`, compiled by
ReActionView 0.4.1's handler and so by Herb 0.10.4, the engine every fixture
and every 2.0 sidecar compiles with (a `<div><span></div>` probe raised
`ActionView::SyntaxErrorInTemplate`, which Erubi would not) — trim mode does
the following. Each line is reproduced from a probe whose source and output
are in plan 2.0b's Appendix A.

- `-%>` on an opening tag removes the newline after it, and `<%-` removes
  the indentation before the tag on the same line
  (`  <%- if true -%>\nA<% end %>\n` → `A\n`).
- The `end` that closes a `<%= … do %>` block ignores its own `-%>` and `<%-`
  for the newline after it (`Body<% end -%>\nAfter` → `Body</div>\nAfter`):
  `visit_erb_block_end_node` in `herb/engine/compiler.rb` never reads the
  end tag's trim markers. It trims Erubi-style — the indentation before it
  and the newline after it — only when it stands alone at the start of its
  line, and then the newline *before* it, the one ending the content line,
  stays (`Body\n<% end %>\nAfter` → `Body\n</div>After`).
- Indentation before an output tag is text and is emitted
  (`\n  <%= render … -%>` puts two spaces in the output).

So an indented, one-render-per-line layout is not whitespace-tight under this
combination: every content line ending in `end` puts a newline into the
output, every indented `<%=` puts its indentation there, and the strict lane
sees both. Two layouts do emit nothing: a break only after each opening tag,
with every `end` kept adjacent to its content and siblings on one line
(`<%= render A.new do -%>\n<%= render B.new do -%>\nBody<% end %><% end %>`),
and a break inside a tag (`<%=\n  render … %>` … `<%\n  end %>`).

**Decision.** Every ERB fixture under `gem/test/golden/views/` is one line
plus a trailing newline, as Button's 15 already were. This is a convention,
chosen because one mechanical shape is the one a reviewer can compare with
the scenario block without thinking, and neither whitespace-tight multi-line
layout reads better than one line for a fixture. The suite proves a fixture's
*output*, not its faithfulness — an argument the component ignores renders
identical HTML — so comparing each fixture with its scenario block stays part
of review. The inside-tag form and the adjacent-`end` form are the candidates
for the sidecars, where users read and edit the file; plan 2.1 chooses when it
writes the first one, measures again under whatever Herb it pins, and records
the choice here.

**Cost if wrong:** about fifteen composite fixtures between 700 and 3,000
characters on one line. **What would reverse it:** Herb honouring the trim
markers on a block-closing `end`, at which point `-%>` is enough and decision
8 stands as written.
```

- [ ] **Step 2: Amend the spec**

In `design/2026-09-19-rubyui-2-0-design.md`, §6 "Phase 2.0 Foundation", the ERB-lane bullet currently ends:

```
  fixture renders a component that is still Phlex, so all 188 fixtures are
  written before any migration — Button's 15 in plan 2.0a, the rest in 2.0b
  (decision 7).
```

Replace those three lines with:

```
  fixture renders a component that is still Phlex, so all 188 fixtures are
  written before any migration — Button's 15 in plan 2.0a, the other 173 in
  plan 2.0b (decision 7). Every fixture is one line: under Herb 0.10.4, trim
  mode keeps the newline after an `end` that follows content on its line and
  emits the indentation before an output tag (decision 10).
```

In §9.1, the resolution's part 2 currently reads:

```
2. **Phase 2 sidecars use ERB trim mode**, so they emit no whitespace Phlex
   did not.
```

Replace with:

```
2. **Phase 2 sidecars emit no whitespace Phlex did not.** Trim mode was the
   intended means; measured through Herb 0.10.4 it keeps the newline after
   an `end` that follows content on its line and emits the indentation
   before an output tag, so an indented one-render-per-line sidecar is not
   whitespace-tight. What is: one line, a break only after opening tags with
   every `end` adjacent, or a break inside an ERB tag (decision 10).
```

In §6 "2.2 The bulk", the definition of done currently begins:

```
**Definition of done, per component.** A plain Ruby class with no Phlex; a
sidecar in trim mode; the snapshot matching; the strict lane matching if the
component carries text; a scenario passing the String form of every enum
```

Replace those three lines with (the rest of the paragraph is unchanged):

```
**Definition of done, per component.** A plain Ruby class with no Phlex; a
sidecar that emits no whitespace Phlex did not (decision 10); the canonical
and the strict snapshot matching for every one of its scenarios (decision
8); a scenario passing the String form of every enum
```

- [ ] **Step 3: Tell the catalog's reader where the fixtures are**

In `gem/test/golden/scenarios.rb`, after the paragraph that ends `keeps the scenario meaningful rather than a bare `<td>`.` and before the `# Variant coverage is enumerative…` paragraph, insert:

```ruby
#
# Every scenario also has an ERB fixture at
# test/golden/views/<component>/<name>.html.erb: the same composition written
# as `<%= render RubyUI::X.new(...) do %>...<% end %>`, on one line, because
# the strict lane sees every newline a fixture adds and Herb's trim mode keeps
# the one after an `end` that follows content (decisions 7, 8 and 10). Both lanes
# compare against the same snapshots; while a scenario keeps its Phlex block,
# that lane records and the ERB lane compares.
```

- [ ] **Step 4: Run everything and commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui/gem
bundle exec rake
```

Expected: `776 runs, … 0 failures, 0 errors, 0 skips`; `423 files inspected, no offenses detected`.

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add design/v2/decisions.md design/2026-09-19-rubyui-2-0-design.md gem/test/golden/scenarios.rb
git commit -m "$(cat <<'MSG'
[Documentation] Decision 10: fixtures are one line; Herb's trim mode measured

Through Herb 0.10.4, `-%>` removes the newline after an opening tag and
`<%-` the indentation before one, but the `end` closing a `<%= … do %>`
block ignores its own trim markers and the indentation before an output
tag is emitted — so an indented one-render-per-line template is not
whitespace-tight, and decision 8's "or <%-/-%>" does not hold for it.
Fixtures are one line; the two layouts that do emit nothing are the
candidates for sidecars, decided in 2.1. Spec §6 Phase 2.0, §6.2 and
§9.1 amended; the catalog header points at the fixtures.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
MSG
)"
```

---

## Task 10: Final verification and the pull request

**Files:** none.

- [ ] **Step 1: Confirm the branch is clean and complete**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain
git log --oneline v2/foundation..HEAD
git diff --stat v2/foundation..HEAD -- gem/lib gem/test/golden/snapshots gem/test/golden/strict gem/test/golden/catalog.rb gem/test/golden/canonical_html.rb gem/test/test_helper.rb docs mcp
git diff --stat v2/foundation..HEAD -- gem/test/golden/harness.rb gem/test/golden/harness_test.rb
```

Expected: no output from the first; twelve commits from the second (the plan, Task 1, seven batches, the plan amendment that added Task 7b, Task 7b, Task 9); **no output from the third** — nothing under `gem/lib`, no snapshot, no catalog/canonicalizer/helper change, nothing in `docs/` or `mcp/` changed; from the fourth, exactly two files — `harness.rb` with a handful of inserted lines and `harness_test.rb` with one test — Task 7b's change and nothing else.

- [ ] **Step 2: Run everything from a clean state**

```bash
cd /Users/cirdes/Workspaces/ruby_ui/gem
bundle exec rake
bundle exec rake golden 2>&1 | grep -E "runs,"
find test/golden/views -name '*.html.erb' | wc -l
find test/golden/views -name '*.html.erb' -exec awk 'END { if (NR != 1) print FILENAME " has " NR " lines" }' {} \;
find test/golden/views -name '*.html.erb' -exec sh -c 'for f; do [ "$(tail -c1 "$f" | wc -l)" -eq 1 ] || echo "$f lacks a trailing newline"; done' _ {} +
cd /Users/cirdes/Workspaces/ruby_ui/mcp && bundle exec exe/ruby-ui-mcp-build >/dev/null && git diff --exit-code data/registry.json && echo "registry current"
```

Expected: `776 runs, … 0 failures, 0 errors, 0 skips` and `423 files inspected, no offenses detected`; `410 runs, … 0 failures`; `188`; no output from the `awk` line or the `tail` line (every fixture is exactly one line, and that line ends in a newline — `awk`'s `NR == 1` alone would also accept an unterminated line); `registry current`.

- [ ] **Step 3: Ask the user before pushing**

Pushing and opening a PR are outward-facing. Do not run Step 4 until the user has said to go ahead.

- [ ] **Step 4: Push and open the PR against `v2/foundation`**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git push -u origin v2/fixtures
gh pr create --base v2/foundation --title "[Feature] RubyUI 2.0 — Phase 2.0b: the other 173 ERB fixtures" --body "$(cat <<'MSG'
## What

Stacked on #548. Every one of the 188 golden scenarios now has an ERB
fixture under `gem/test/golden/views/`, rendered through the harness
(ReActionView → Herb) and compared against the canonical **and** strict
snapshots Phase 2.0a froze from Phlex — with every component still Phlex,
through `phlex-rails`. Button's 15 were in #548; the other 173 are here, in
seven batches, each green before the next.

- A coverage test, `every scenario has a fixture`, red from the first commit
  (173 missing) to the last (0). Its message was the inventory.
- Every fixture is one line, plus a trailing newline. Decision 10 records why:
  measured through Herb 0.10.4, the `end` closing a `<%= … do %>` block
  ignores its own trim markers and the indentation before an output tag is
  emitted, so an indented one-render-per-line template is not
  whitespace-tight — and the strict lane would see every such character.
  The plan's Appendix A has each probe's source and output.
- The shapes the catalog uses — a block parameter writing raw HTML,
  `yield(self)` with `group.ToggleGroupItem`, `DataTableForm` reaching for
  the view context, a block yielding nothing, a Ruby loop, a heredoc — were
  each measured strict-identical before the plan was written; the plan's
  evidence table has the list.

- **One harness fix the lane exposed (Task 7b).** ActionView instruments every
  render, and the first instrumentation on a thread creates ActiveSupport's
  `Instrumenter`, whose id is `SecureRandom.hex(10)` — inside the harness pin,
  on the first ERB render of a process, that call took the counter's first
  value and shifted every generated id in that render by one, so
  `tooltip/default`, `select/default` or `date_picker/generated_id` failed
  their own determinism check when one of them ran first (about 3 runs in
  190). `render_erb` now creates the instrumenter before the pin; a test
  renders twice on a fresh thread and asserts identical output. This amended
  the plan's "harness does not change" boundary by a ruling taken during
  execution — please ratify or revert it explicitly in review.

No component changes, no snapshot changes. Nothing under `gem/lib/`, `docs/`
or `mcp/` moves; the harness changes by that one line.

## Why

Decision 7: with every fixture written before any component migrates, a
migration from 2.1 on changes only an implementation, never the ruler — "did I
write the fixture right" and "did I port the component right" stop being one
failure. Plan: `design/plans/2026-09-20-phase-2-0b-fixtures-implementation.md`.

## Test steps

```bash
cd /Users/cirdes/Workspaces/ruby_ui/gem
bundle exec rake            # 776 runs, 0 failures, 0 skips; 423 files, no offenses
bundle exec rake golden     # 410 runs: 188 Phlex-lane + 188 ERB-lane + 7 coverage + 27 of the ruler's own
```

To see a fixture fail, add a space before `<% end %>` in
`test/golden/views/shortcut_key/default.html.erb` and re-run `rake golden`:
the canonical form passes, the strict form fails — whitespace only, exactly
what the strict lane exists for.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
MSG
)"
```

---

## Definition of done for Phase 2.0b

- 188 fixtures under `gem/test/golden/views/`, one per scenario, each one line; `test_every_scenario_has_a_fixture` green; `test_no_orphan_fixture_files` green.
- `bundle exec rake golden`: 410 runs, 0 failures — 188 Phlex-lane and 188 ERB-lane scenario tests, each also passing the strict comparison.
- `bundle exec rake` green (776 runs, 0 skips), `423 files inspected, no offenses detected`; `mcp/data/registry.json` unchanged.
- No file under `gem/lib/` changed; no canonical or strict snapshot changed; `catalog.rb`, `canonical_html.rb`, `test_helper.rb` unchanged; `harness.rb` changed only by Task 7b's instrumenter line, with its regression test in `harness_test.rb`.
- `design/v2/decisions.md` entry 10; spec §6 Phase 2.0 and §9.1 part 2 amended; the catalog header points at the fixtures.
- Every finding of the "STOP" kind (a faithful fixture that does not match; a missing pin) reported to the maintainer, none patched around.

## Not in this plan

- **`docs/Gemfile` pinned to the published 1.6 gem** — the first task of the 2.1 plan, as 2.0a scoped it; nothing in `docs/` breaks until the first component migrates.
- **Any component migration**, including the four of 2.1 (Dialog, Select, ToggleGroup and Toggle, Data Table). The first sidecar is where decision 10's inside-tag form is chosen or rejected for sidecars.
- **A `pending:` on a scenario the ERB lane cannot match** — none is expected (every shape in the catalog was measured); if one appears it is a STOP and a maintainer decision recorded in `decisions.md`, not a task here. `pending:` is scenario-level and skips the snapshot comparison in both lanes, so it is a cost to the ruler, not an ERB-only exception.
- **A fixture-format test** (one line, trailing newline). The strict lane already fails any fixture that adds whitespace between elements; the one-line rule beyond that is convention, checked by eye in Task 10's `awk` line, not by a test.

## Appendix A — Trim-mode probes, source and output

Measured 2026-09-20 on `v2/foundation` at `f855423`, Ruby 4.0.2, with the `Gemfile.lock` pins `reactionview (0.4.1)`, `herb (0.10.4)`, `phlex-rails (2.4.0)`, `actionview (8.1.3.1)`. Each probe was a file `gem/tmp/probe/views/x/pN.html.erb` — under `Rails.root`, so ReActionView's handler compiled it through Herb (a `<div><span></div>` file in the same directory raised `ActionView::SyntaxErrorInTemplate`; Erubi would have rendered it) — rendered with `RubyUI::TestApp.view("<gem>/tmp/probe/views").render(template: "x/pN")` after `require "test_helper"`, then the directory was deleted. `class="…"` attributes are stripped from the outputs below for legibility; nothing else is altered. To reproduce under a different Herb, recreate the files and the call.

```
p1  SRC "<%= render RubyUI::Card.new do -%>\nBody<% end -%>\nAfter\n"
    OUT "<div>Body</div>\nAfter\n"
    — the newline after the opening tag's -%> is removed; the one after the content-terminated `end -%>` is kept.

p2  SRC "<%= render RubyUI::Card.new do -%>\nBody\n<% end %>\nAfter\n"
    OUT "<div>Body\n</div>After\n"
    — `end` alone at line start trims the newline after it, Erubi-style; the newline before it (ending "Body") stays.

p3  SRC "<%= render RubyUI::Card.new do -%>\n  <%= render RubyUI::CardContent.new do -%>\nBody<% end %><% end %>\n"
    OUT "<div>  <div>Body</div></div>\n"
    — indentation before an output tag is emitted.

p4  SRC "  <%- if true -%>\nA<% end %>\n"
    OUT "A\n"
    — `<%-` removes the indentation before a statement tag on the same line; `-%>` removes the newline after it.

p5  SRC "<%= render RubyUI::Card.new do -%>\n<%= render RubyUI::CardContent.new do -%>\nBody<% end %><% end %>\n"
    OUT "<div><div>Body</div></div>\n"
    — breaks only after opening tags, every `end` adjacent: whitespace-tight.

p6  SRC "<%= render RubyUI::Card.new do %><%=\n  render RubyUI::CardContent.new do %>Body<%\n  end %><%\nend %>\n"
    OUT "<div><div>Body</div></div>\n"
    — breaks inside tags: whitespace-tight at any indentation.

p7  SRC "<%= render RubyUI::Card.new do -%>\n<%= render RubyUI::CardContent.new do -%>\nBody<%- end -%>\n<%- end -%>\n"
    OUT "<div><div>Body</div>\n</div>"
    — `<%- end -%>` after content: the newline after it is still kept.

p8  SRC "<%= render RubyUI::Card.new do -%>\n  <%= render RubyUI::CardContent.new do -%>\n    Body\n  <% end %>\n<% end %>\n"
    OUT "<div>  <div>    Body\n</div></div>"
    — the indented one-render-per-line layout: indentation before `<%=` and before "Body" emitted, the newline after "Body" kept; the two `end` lines themselves emit nothing.

p9  SRC "<%= render RubyUI::Card.new do -%>\n<%= render RubyUI::CardContent.new do -%>\nBody<% end %>\n<%= render RubyUI::CardFooter.new do -%>\nFoot<% end %><% end %>\n"
    OUT "<div><div>Body</div>\n<div>Foot</div></div>\n"
    — p5's layout with a sibling render on its own line: the newline after `<% end %>` reaches the output.
```

Why p1, p7 and p9 behave as they do: in `herb/engine/compiler.rb` (0.10.4), `visit_erb_block_end_node` — the visitor for the `end` that closes a `<%= … do %>` block — sets `@trim_next_whitespace` only when `at_line_start?` is true, and never consults `right_trim?`/`left_trim?` of the end tag for that purpose; the output-tag visitors — `process_erb_output` for `<%= … %>` and `visit_erb_block_node` for `<%= … do %>` — honour `right_trim?` but do nothing about the text token that precedes the tag, which is where indentation lives; `apply_trim`, for statement tags, consults only `left_trim?` and `at_line_start?`, so a statement tag alone on its line trims with or without markers and a mid-line `-%>` is ignored.

The same session measured the ERB lane's pins: `date_picker/generated_id`, `select/default` and `tooltip/default` rendered strict-identical to their snapshots, identical across two renders, with the minted ids `date-picker-00000001`, `content00000001` and `tooltip00000001`; a `SidebarWrapper` with two `SidebarMenuSkeleton` rendered identical widths across two renders.
