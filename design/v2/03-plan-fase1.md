# RubyUI 2.0 — Phase 1 (decision gate): plan

Date: 2026-09-07
Status: proposed, revision 2 — open decisions in §6

Sources: `design/v2/00-charter.md`, `design/v2/01-research/golden-suite.md`, the local repo (gem 1.6, golden suite, docs app), upstream code for Herb, ReActionView and rails/rails, the locally installed actionview 8.1.3 and phlex 2.4.1, and two empirical probes run on 2026-09-07 against actionview 8.1.3 and an isolated install of herb 0.10.3 (URLs and probe results at the end).

Revision 2 incorporates an external review. It restores the charter's Rails baseline, adds ToggleGroup as the block-with-context case the three named components do not cover, corrects what Herb 0.10.3 actually validates, fixes the performance ratio, and turns "flags" into pass/fail criteria frozen before execution.

## Context

Phase 1 of 2.0 answers one question: is an ERB component-and-slot layer expressive enough to carry this library, measured on Dialog (composition), Select (state + Stimulus) and Data Table (the limit case). The working hypothesis was that Herb and ReActionView are rendering engines with no component primitive, so 2.0 includes designing that layer.

Verification confirms the hypothesis for the published gems (§1). Two constraints are settled by the maintainer and are not reopened here: 2.0 is ERB-first with Phlex gone (charter), and **ViewComponent is not to be used** (decision of 2026-09-07). The layer under test is therefore an in-house one; §2 item 6 states that as a hypothesis with a falsifier rather than as a consequence. The plan restates the gate question (§3) and fits in 10 working days with **no slack**; running out of time yields "inconclusive", not a verdict (§4).

## 1. What Herb and ReActionView actually expose today (verified 2026-09-07)

| | Published | `main` (unreleased) |
| --- | --- | --- |
| **herb** | 0.10.3 (2026-08-01). C parser + `Herb::Engine` (Erubi-compatible) + validators. **What validation actually runs** (read at tag `v0.10.3` and confirmed by running the gem): `run_validation` instantiates `SecurityValidator`, `NestingValidator`, `AccessibilityValidator`; `RenderValidator` exists but is not run. `AccessibilityValidator` is a TODO stub (no checks). `NestingValidator` checks three things on the HTML AST: block element inside `<p>`, nested `<a>`, interactive element inside `<button>`; it ignores whatever ERB output emits. Unclosed or mismatched tags are caught by the **parser** (`Herb::Engine::CompilationError`), not by a validator. `SecurityValidator` rejects an ERB output tag in attribute position (`<div <%= attrs %>>` → `SecurityError`) with one syntactic exception: a call shaped `tag.attributes(...)`. **No** component, slot or composition primitive. Linter, formatter and LSP are npm packages. No railtie. | 78 files under `lib/herb/engine` (14 at 0.10.3). Experimental `ComponentTags::Visitor`: `<Card title="x">…</Card>` becomes `render Card.new(title: "x") do … end`. A `slots/` subsystem (`<Fragment>`, `<Fallback>`, `<Async>`, `<Lazy>`). Engine constructor changed relative to 0.10.3 (0.11 will break). |
| **reactionview** | 0.4.0 (2026-08-18). `actionview >= 7.0`, `herb >= 0.10, < 0.11`. Registers its own handlers (`:herb`, and `:erb` when `intercept_erb`). Passes validation mode, visitors and dev-tools wiring into the engine; in `external_template_mode: :fallback` it compiles gem templates with Herb and falls back to Erubi on error. **No** component model. CI runs Rails 7.0 through 8.2 (`main`). | A "slots" subsystem: `format.slots` returns the template's dynamic values (LiveView-style split). Reactivity, **not** composition slots. Requires `herb` `main`. Issue #57 (open since 2025-11): a component template calls a helper with a block, the helper does `render "partial", &block`, the partial does `<%= yield %>`; under ReActionView `<%= content %>` lands before the partial and `<% content %>` is dropped. |
| **rails/rails** | 8.1.3.1 has none of this. | #58552 merged 2026-08-25: `ActionView::Template::Handlers::ERB::Herb`, opt-in via `erb_implementation=`; `actionview` now depends on `herb >= 0.10`. The Herb-specific config follow-up never landed; the generic `config.action_view.erb_implementation` exists since 2026-08-07 (#58359). |
| **Both Herb handlers** | Rails' `ERB::Herb` and ReActionView's `Handlers::Herb::Herb` set `bufvar = "@output_buffer"` and disable Herb's contextual escaping (`escapefunc = ""`, `attrfunc/jsfunc/cssfunc = nil`), leaving escaping to `OutputBuffer`. The append protocol is equivalent; the **lanes are not**: only ReActionView runs validators, visitors, overlay and the Erubi fallback. | |
| **actionview** 8.1.3 (local, empirical) | `render(obj)` dispatches to `obj.render_in(view_context, &block)` (`rendering_helper.rb:149`). `capture(*args, &block)` returns `buffer.presence || value`: a block whose output is whitespace-only falls through to the block's return value. Measured with `render Probe.new do … end`: body `"\n"` → content `"\n"`; empty body → `nil`; body `"  "` → `"  "`; `capture(self, &block)` with `do |g|` passes the argument. `tag.attributes(flat_hash)` on a pre-serialized string→string hash emits `data-x=""` for `""`, `disabled="disabled"` for `true`, `style` verbatim, and does not touch key names. | |

Performance, per Herb itself: parser 10x to 90x **slower** than Erubi at compile time; hot render equal (ReActionView #96: −2% hot, +34% mean cold). No claim of rendering faster than Erubi.

## 2. Where the premises are wrong or weakly founded

1. **"ERB-first on Herb / ReActionView" conflates two layers.** Herb and ReActionView are the ERB compiler and its tooling. The component layer does not exist in them and is not on their roadmap in that shape. Herb sits underneath whatever layer 2.0 builds. The charter should say so; today it reads as if ReActionView were the authoring foundation.

2. **The Rails baseline stays as the charter fixes it.** The gate runs on the pinned ref `60eb5cb7…` (charter §3–4). The finding that ReActionView 0.4.0 also runs on released Rails 8.1 and registers its own handler is **evidence for the Risks section**, gathered by one extra lane run once, not a change of baseline. Likewise "Herb optional for consumers, mandatory in CI" is a hypothesis the decision document argues under Risks; it is not a premise of this plan.

3. **"Render performance within `<TBD>`x of 1.6" needs a frozen method and number.** The Herb-vs-Erubi hot factor is ~0; what costs is ERB + layer vs Phlex. The reference is Phlex-in-Rails; the slowdown is **time_ERB / time_Phlex = ips_Phlex / ips_ERB** (the earlier draft had the ratio inverted). Target frozen in §5 before any measurement.

4. **"What Phlex gave me for free" is attribute serialization and `mix`, not named slots.** None of the three named components has a named slot or a block parameter. What breaks parity is serialization semantics (`phlex-2.4.1/lib/phlex/sgml/attributes.rb`, `lib/phlex/helpers.rb`): Symbol keys `tr("_","-")` at every level, Symbol values dasherized, Integer `to_s`, `nil`/`false` omitted, `true` bare, `style:` hash → `"width: max-content; top: 0; left: 0;"`, `mix` concatenating String+String (`data-action` order visible at `full_frame.html:48,63`), Hash+Hash recursive, user `nil` not erasing the default, `key!` overriding. Rails' `tag.attributes` alone renders `data-x="false"` and `aria-x="true"`. Two consequences: the layer needs a serializer with Phlex semantics, with Phlex 2.4.1 in the bundle as differential oracle; and because `SecurityValidator` rejects a bare `<%= attrs %>` in attribute position but accepts `tag.attributes(...)`, templates emit root attributes as `<div <%= tag.attributes(component.attrs) %>>` where `component.attrs` is already flat (`"data-ruby-ui--dialog-open-value" => ""`, `nil`/`false` removed) and Rails only quotes and escapes. Both halves are verified (§1, last two rows). The element stays in HTML, so the parser and `NestingValidator` still see it.

5. **Block-with-context is used by 1.6 and the earlier draft did not test it.** `ToggleGroup#view_template` does `yield(self)` and exposes `group.ToggleGroupItem(**kwargs, &block)`, threading `item_context` (type, variant, size, disabled, selected values, spacing, orientation) into each item (`gem/lib/ruby_ui/toggle_group/toggle_group.rb:37-58`). `ToastRegion` also does `yield(self)`. Three golden scenarios pin ToggleGroup (`scenarios.rb:1060-1085`). `view_context.capture(self, &block)` passes the argument on Erubi (verified) and Herb compiles `render X.new do |g|` correctly (verified); the layer must support it and the gate must exercise it. ToggleGroup joins the gate as the fourth component (§6 item 1).

6. **The in-house layer is a hypothesis, not a consequence of excluding ViewComponent.** The alternative the charter lists is plain partials + helpers. The hypothesis: a plain-Ruby object with `render_in` is preferable because (a) `attrs` must be computable with no view context (`PaginationItem` reads `Button.new(...).attrs[:class]`), which a partial cannot offer; (b) sub-components need to be invoked from Ruby (`group.ToggleGroupItem`), and (c) the user-facing API stays `RubyUI::X.new(...)`. Falsifier: if the layer needs an ActionView patch or exceeds its budget (§3) to reproduce the scenarios, the document must weigh partials + helpers explicitly instead of declaring the hypothesis confirmed.

7. **Block-as-value is not reproducible in ERB; the corrected reason.** `capture` returns `buffer.presence || value`. An ERB block whose body is a newline produces buffer `"\n"`, `presence` is `nil`, and the block's return value is also `"\n"` (the value of the last `safe_append=`), so `capture` returns `"\n"` (measured). `SelectValue`'s 1.6 logic `value || @placeholder` therefore never falls back in ERB. The port is `content.presence || placeholder`. This changes behaviour for `""` and whitespace-only content (1.6 renders nothing; 2.0 renders the placeholder) and drops non-String return values; the document records it as a deviation with these exact cases.

8. **Portal is not a problem.** Dialog uses `<dialog>.showModal()` (native top layer); Select uses floating-ui in place.

9. **The invocation API changes regardless.** `RubyUI.Dialog { }` becomes `<%= render RubyUI::Dialog.new(open: true) do %>`. First written deviation for the document. Kit-style sugar is a later API decision.

10. **The golden suite is not committed yet.** `gem/test/golden/` is untracked on `v2-herb`. The gate depends on it; commit before day 1.

## 3. The gate question, restated

> On the charter's pinned Rails ref, with Herb as the ERB compiler through ReActionView 0.4.0, does a **minimal in-house component layer over `render_in`** reproduce the 18 golden snapshots of Dialog, Select, Data Table and ToggleGroup byte for byte, pass rich-content and behaviour tests with the 1.6 Stimulus controllers unchanged, stay within a fixed budget, and render within 2.0x of Phlex-in-Rails?

**Pass/fail criteria, frozen now.** Every item is mandatory for "proceed"; none may be replaced by "divergence recorded".

- Parity: all 18 snapshots byte-identical in canonical form on the pinned ref, herb lane and erubi control lane.
- Composition: ToggleGroup's three scenarios (block with context) and the rich-content differential scenarios (§4, day 5) pass.
- Behaviour: the system tests of §4 for Dialog, Select, ToggleGroup and Data Table pass with the 1.6 controllers via symlink, unedited.
- Budget: `base.rb` + `attributes.rb` + any other layer infrastructure ≤ **500 lines** (`wc -l`, comments included). No monkey patch of ActionView or Herb. No code path that exists only to satisfy a fixture. Exceeding the budget fails the budget; it does not prove impossibility, and the document says which.
- Performance: time_ERB / time_Phlex ≤ 2.0 for each of the three measured scenarios, same view context and render boundaries, on the pinned ref. A scenario whose interval overlaps 2.0 is "at threshold" and does not pass.
- Herb findings: every `HERB_FINDINGS.md` row is classified; an "upstream" row needs a reproducer that isolates the defect outside RubyUI.

Outcomes:
- **proceed**: all criteria met.
- **proceed only with an upstream contribution**: a mandatory criterion fails for a cause isolated upstream with a reproducer, and everything else passes.
- **postpone / reconsider**: a mandatory criterion fails for a cause inside the layer or the approach (budget, ActionView patch, Data Table not reproducible, performance).
- **inconclusive**: day 10 ends with mandatory evidence missing. Written as such; not a verdict.

## 4. Phases (10 working days, no slack)

Everything lives in `experiments/v2-gate/`, throwaway code. Nothing under `gem/lib`, `docs/`, `mcp/`. Reads from `gem/` without copying or editing: `gem/test/golden/canonical_html.rb` (nokogiri only), `gem/test/golden/snapshots/`, the `*_controller.js` files (via symlink) and, in the Phlex lane, the whole gem via `path:`.

```
experiments/v2-gate/
  README.md
  Gemfile.herb  Gemfile.erubi  Gemfile.core  Gemfile.phlex  Gemfile.stable   # lanes via BUNDLE_GEMFILE
  app/components/ruby_ui/
    base.rb                       # the layer: render_in, capture(self), template lookup, attrs
    attributes.rb                 # Phlex-semantics serializer + mix + tailwind_merge 1.5.5, output flat
    dialog/ select/ toggle_group/ data_table/ + neighbours   # <name>.rb + <name>.html.erb side by side
  app/javascript/controllers/ruby_ui/*.js   # symlinks to the 1.6 controllers, unchanged
  app/views/gate/                 # one view per scenario, as a user would write it
  app/controllers/gate_controller.rb        # form_authenticity_token => "csrf-token-placeholder"; employees route
  config/initializers/ruby_ui.rb  # the only wiring: prepend_view_path("app/components")
  test/golden/scenarios.rb        # 18 scenarios, same component/name keys as 1.6
  test/golden/parity_test.rb      # gem's canonical_html.rb + gem's snapshots
  test/golden/differential/       # rich-content scenarios: Phlex-lane oracle output vs ERB, no stored snapshot
  test/attributes_differential_test.rb      # same hash -> Phlex::HTML#div vs RubyUI::Attributes
  test/probes/                    # layer probes
  test/system/                    # dialog, select, toggle_group, data_table with the 1.6 controllers
  bench/                          # render_bench.rb, compile_bench.rb, bin/bench, RESULTS.md
  HERB_FINDINGS.md                # every Herb rejection or divergence, classified
  LAYER.md                        # what the layer is, wc -l, responsibilities, install step
```

Lanes, all on the **pinned ref** unless stated:
- `Gemfile.herb` — the gate: `rails github: "rails/rails", ref: "60eb5cb7…"` + reactionview 0.4.0 + herb 0.10.3, `intercept_erb = true`, `validation_mode = :raise`.
- `Gemfile.erubi` — control: pinned ref, no reactionview.
- `Gemfile.core` — smoke (day 9): pinned ref, no reactionview, `config.action_view.erb_implementation = ActionView::Template::Handlers::ERB::Herb`.
- `Gemfile.phlex` — bench reference and rich-content oracle: pinned ref + `ruby_ui path: ../../gem` + `phlex 2.4.1` + phlex-rails + the Zeitwerk loader from `docs/config/initializers/ruby_ui.rb`. Separate process: the 1.6 gem and the 2.0 layer collide on `RubyUI::Base`. If phlex-rails does not boot on the pinned ref, the bench and oracle move to Rails 8.1.3.1 for all lanes and the document says so.
- `Gemfile.stable` — risk evidence (day 9): Rails 8.1.3.1 + reactionview 0.4.0; parity suite run once.

Versions pinned to what the snapshots were recorded with: `tailwind_merge 1.5.5`, `phlex 2.4.1`. Ruby 3.4.7; the document records that 3.3 was not covered. Tailwind via the play CDN in the gate layout so `hidden`, `open:flex` and animation classes resolve in the browser; screenshots are saved as evidence, not compared.

**The layer, fixed before day 2.** `RubyUI::Base` is plain Ruby: `initialize(**attrs)`; `default_attrs` per subclass; `attrs` computed in `initialize` via `Attributes.mix` + `tailwind_merge`, returned **flat** (string keys already dasherized, `nil`/`false` removed, `true` → `""` for non-boolean attributes, `style` hash serialized); `render_in(view_context, &block)` stores the view context, captures `content = view_context.capture(self, &block)` when a block is given (so `yield(self)` components receive the component), and renders the sidecar `app/components/ruby_ui/<dir>/<name>.html.erb` with `component: self` as the only local. Templates use `<div <%= tag.attributes(component.attrs) %>>`, `<%= component.content %>`, and `<%= render RubyUI::Other.new(...) %>` for neighbours; sub-component methods like `ToggleGroup#ToggleGroupItem` call `@view_context.render`. `helpers` is the view context (CSRF via `form_authenticity_token`). Templates are `.html.erb` so the herb lane intercepts them. Nothing else: no named slots, no DSL, no monkey patch.

Policy: **the 1.6 snapshot is the reference.** If Herb rejects or changes markup that 1.6 emits, that becomes a row in `HERB_FINDINGS.md` (template, source — parser or which validator —, message, classification "template adjustment" vs "upstream", reproducer path), not an edit of the markup and not a relaxation of `validation_mode`.

### Phase 0 — Day 1: app, lanes, ruler, probes

- `rails new gate --minimal --no-skip-javascript --no-skip-hotwire --no-skip-system-test -j importmap -a propshaft` (`--minimal` alone turns off JS, Hotwire and system tests), then the pinned `rails` line in each Gemfile. `bin/importmap pin @floating-ui/dom`; register `form_field_controller.js` alongside the components' controllers.
- Parity runner: loads the gem's `Golden::CanonicalHtml`, compares `CanonicalHtml.call(html)` against the snapshot, renders twice (determinism), pins `SecureRandom.hex` as `harness.rb` does (`(n += 1).to_s(16).rjust(bytes * 2, "0")`, active only while a scenario renders), renders via `GateController.render(template:)`.
- Probes, results into `HERB_FINDINGS.md`: (i) `<div <%= tag.attributes(component.attrs) %>>` compiles on the herb lane and the emitted attributes canonicalize identically to the erubi lane for a hash covering `""`, boolean attributes, `style`, escaping; (ii) `<%= render Probe.new do |g| %>…<% end %>` with `capture(self, &block)` yields identical content on both lanes; (iii) a nested `render` inside that block; (iv) **control**: the exact #57 shape (component template → helper with block → `render "partial", &block` → `<%= yield %>`) — the layer does not use this path, so a failure here is a finding for users' templates, not a layer blocker.

**Acceptance:** (a) `BUNDLE_GEMFILE=Gemfile.herb bin/rails test test/golden` and the same for `erubi` are green with a sentinel scenario whose HTML is the literal `dialog/default` snapshot; (b) a template containing `<div><span></div>` compiles on the erubi lane and raises `Herb::Engine::CompilationError` on the herb lane; (c) probes (i)–(iii) identical on both lanes, (iv) recorded either way; (d) reactionview 0.4.0 boots on the pinned ref (if not, that is the first finding and the gate cannot proceed on the charter's stack).

### Phase 1 — Days 2 and 3: `Attributes`, the layer, Dialog

`RubyUI::Attributes` first, with a **differential test against Phlex 2.4.1**: a table of hashes (underscored keys at several levels, `nil`, `false`, `true`, Integer, Symbol, `style:` hash, `class:` array with nil, nested `data:`, `mix` with String+String, Hash+Hash, user `nil`, `key!`) rendered by `Phlex::HTML#div(**h)` and by `<div <%= tag.attributes(Attributes.flat(h)) %>>`, canonicalized, equal.

Then `RubyUI::Base` as specified, and Dialog (9 classes: the 8 in `dialog/` plus `Button`, which `dialog/default` uses). Layer probes as unit tests: a component that renders nothing (`DataTablePagination` with `total <= 1`); `Foo.new(...).attrs[:class]` with no view context; `content.presence` with empty and whitespace-only blocks; a generated id with pinned `SecureRandom`; a `<turbo-frame>` root; a component rendered with no request (`GateController.render`), the 2.0 equivalent of the `phlex { }` helper.

**Acceptance:** (a) differential test green; (b) the 6 `dialog/` snapshots byte-identical on both lanes; (c) probes green on both lanes; (d) system test with `dialog_controller.js` unedited: click trigger → `dialog[open]` present and `document.activeElement` inside the dialog; Esc → not open, `body` without `overflow-hidden`, focus back on the trigger; close button → same; (e) `LAYER.md` with `wc -l` and the `dialog/default` user view; (f) go/stop: Dialog not at parity by end of day 3 → stop and document.

### Phase 2 — Day 4: Select

8 classes. `SelectContent` mints `@id` with `SecureRandom.hex(4)` and emits two nested elements with the block in the inner one; `SelectValue` becomes `content.presence || placeholder`; `SelectInput` carries the foreign `ruby-ui--form-field` controller; `aria-activedescendant: true` becomes `""`.

**Acceptance:** (a) the 2 `select/` snapshots identical on both lanes, plus an explicit assert of `id="content00000001"`; (b) system test with `select_controller.js` and `select_item_controller.js` unedited: click trigger → `aria-expanded="true"`, `data-state="open"`, `aria-controls` pointing at the content id and items carrying `<contentId>-<index>` ids (from `generateItemsIds`); ArrowDown twice then Enter → second item selected, `input[name=person]` holds its value; Esc → final state `hidden` + `data-state="closed"` + `aria-expanded="false"`; (c) unit tests: empty block and whitespace-only block fall back to the placeholder, `""` case recorded as deviation.

### Phase 3 — Day 5: ToggleGroup and rich caller content

ToggleGroup (2 classes) + `Toggle` (101 lines, `Toggle.classes_for`). Exercises `capture(self, &block)`, a sub-component method that renders through the view context, context threading into children, and hidden inputs after the block.

Rich-content differential scenarios, oracle = the Phlex lane rendering the same composition in 1.6 and writing canonical HTML to `test/golden/differential/oracle/`: (a) Dialog content with headings, a list, a `link_to ... do` block and an inline `Button`; (b) caller text containing `<script>`, `&`, quotes, and an attribute value with quotes; (c) a `SelectItem` whose content is a `span` with a nested `Badge`-like element; (d) a `TableCell` containing a nested `Button` with a `data-action` of its own. ERB renders the same compositions; canonical forms must match.

**Acceptance:** (a) the 3 `toggle_group/` snapshots identical on both lanes; (b) system test with `toggle_group_controller.js` unedited: click item → `data-state="on"`, hidden input updated; ArrowRight moves focus to the next item; (c) the 4 differential scenarios identical to the oracle on both lanes.

### Phase 4 — Days 6 to 8: Data Table

The 7 scenarios (`scenarios.rb:455-520`) touch 14 classes in `data_table/` + `DataTableManualAdapter` + neighbours: `Button`, `Checkbox`, `Input`, `NativeSelect` + `NativeSelectIcon`, `DropdownMenu`/`Trigger`/`Content`, `Pagination`/`Content`/`Item`/`Ellipsis`, `Table`/`Header`/`Body`/`Row`/`Head`/`Cell`. **32 classes**, ~18 of them a root element + `default_attrs`. Pagy/Kaminari adapters and the unused sub-components are out of scope. Ruby logic moves into the class unchanged. What tests the layer: `<turbo-frame>` root, `PaginationItem` reading `Button.new(...).attrs[:class]`, `DropdownMenuContent`'s `style:` hash, merged `data-action` order in `DataTableSelectAllCheckbox`, `DataTablePagination` with no root when `total <= 1`.

**Acceptance:** (a) the 7 `data_table/` snapshots identical on both lanes, including `full_frame`; (b) request test: `get "/employees", params: {search: "alice", sort: "name", direction: "asc"}, headers: {"Turbo-Frame" => "employees"}` responds with `<turbo-frame id="employees">`, rows rendered from the gate controller's collection in ascending order, and the `name` `DataTableSortHead` linking to `?search=alice&sort=name&direction=desc`; (c) system test with `data_table_controller.js` and `data_table_search_controller.js` unedited: clicking the sort head swaps the frame and reverses row order without a full page load; typing in search updates the frame after the debounce; checking a row updates the selection summary text and shows the bulk actions; (d) `LAYER.md` updated with what the layer gained and its final `wc -l`; (e) `HERB_FINDINGS.md` with the parser/validator × template list from the herb lane.

### Phase 5 — Day 9: performance, smokes, distribution

- Bench per §5 on `Gemfile.herb`, `Gemfile.erubi`, `Gemfile.phlex`.
- `Gemfile.core` smoke: the 18 scenarios pass with Rails' own `ERB::Herb` handler.
- `Gemfile.stable` run: the 18 scenarios on Rails 8.1.3.1, result recorded as risk evidence.
- Distribution checks: `RAILS_ENV=production SECRET_KEY_BASE=x bin/rails runner` renders the 18 scenarios with `eager_load = true`; in development, editing a component template and re-requesting shows the change without restart, then the edit is reverted; `LAYER.md` names the single install step (`prepend_view_path`).

**Acceptance:** `bench/RESULTS.md` generated by `bin/bench` with stddev under 5% per row, ratio and absolute µs per scenario; `core` green; `stable` result recorded; both distribution checks recorded with output.

### Phase 6 — Day 10: decision document

`design/v2/01-research/erb-component-layer-decision.md` (English, `Date`, `Status: draft`):

1. Executive summary (10 lines): outcome (§3), strongest single reason.
2. Ecosystem: the §1 table with a "changed in the last two weeks" column.
3. Capability matrix: attribute pass-through, Tailwind merge, invocation, composition, block with context, block-as-value, rich caller content, rendering a neighbour, reading a neighbour's computed attribute, generated id, rootless component, custom element root, unit render without request, Stimulus colocation, copy into `app/` (production boot, dev reload) → how 2.0 does it → status → evidence file.
4. Gate per component: Dialog, Select, ToggleGroup, Data Table — snapshots, differential scenarios, behaviour tests.
5. The layer: `LAYER.md` content, `wc -l` against the 500-line budget, what it lacks, the partials + helpers alternative weighed per §2 item 6. ViewComponent's exclusion recorded as a maintainer decision.
6. Herb's role: what it caught (from `HERB_FINDINGS.md`), what it cannot check at 0.10.3 (accessibility stub, render validator not run, ERB-emitted elements invisible to nesting), compile cost, 0.10 → 0.11 churn.
7. `<TBD>`: measured ratios against the frozen 2.0x, absolute µs, cold compile.
8. Risks: charter baseline vs released Rails (`stable` evidence), Herb optional for consumers (hypothesis), single maintainer, `main` incompatible with published herb, #57 (control result), #103, Ruby 3.3 not covered.
9. Questions for upstream, with reproducers.
10. Deviations from 1.6 with reasons: invocation syntax, `SelectValue` semantics, and whatever else appears.

**Acceptance:** every external fact has a URL and date; every matrix row points at a file in `experiments/`; the outcome is exactly one of the four in §3.

## 5. Performance measurement — method and frozen number

Same Ruby (3.4.7), same machine, same Rails ref, `GateController`'s view context, each scenario rendered hot with `benchmark-ips` (5 s warmup, 10 s run), JSON per lane, `bin/bench` consolidates. Scenarios: `dialog/default`, `select/default`, `data_table/full_frame`. Render boundaries identical: both sides go through `view.render`, both include component instantiation, neither includes a layout.

| Row | Lane | What it renders |
| --- | --- | --- |
| Phlex 1.6 in Rails (**reference**) | `Gemfile.phlex` | `view.render RubyUI::Dialog.new { … }` via phlex-rails |
| Phlex 1.6 isolated (footnote) | `Gemfile.phlex` | `Phlex::HTML.new.call { RubyUI.Dialog { … } }` |
| ERB 2.0 / Erubi | `Gemfile.erubi` | `view.render template: "gate/dialog_default"` |
| ERB 2.0 / Herb | `Gemfile.herb` | same (isolates the Herb factor, expected ~0) |

Slowdown = time_ERB / time_Phlex = ips_Phlex / ips_ERB, reported with the combined stddev interval. **Frozen target: ≤ 2.0 for each scenario, on the Herb lane.** An interval overlapping 2.0 is "at threshold" and does not pass. Absolute µs per render alongside. Cold: compile time per template with `ActionView::Base.with_empty_template_cache`, Erubi vs Herb, extrapolated to the 251 classes of 1.6; reported, no target. The document may argue a different number for the charter; the gate verdict uses 2.0.

## 6. Open decisions (recommendation first)

1. **Add ToggleGroup as the fourth gate component.** The charter names three; ToggleGroup is the only 1.6 component whose block receives context (`yield(self)` + `group.ToggleGroupItem`), and it is already pinned by three snapshots. Without it the gate can pass with a layer that cannot express the existing surface. Cost: day 5. If declined, day 5 becomes slack and the document must state the gap.
2. **Layer budget 500 lines** for `base.rb` + `attributes.rb` + any other infrastructure, as a pass/fail ceiling. Adjustable only before day 2.
3. **No slack.** Ten days as scheduled; day 10 without mandatory evidence → "inconclusive". Alternative: 12 days with two days of slack.
4. **Decision document in `design/v2/01-research/`**, next to `golden-suite.md`.
5. **Commit the golden suite on `v2-herb` before day 1.**
6. **Components are born in `app/components/ruby_ui/`** of the throwaway app, class and template side by side, with `prepend_view_path` as the only wiring. Whether the generator later targets `app/components/` or `app/views/ruby_ui/` is a 2.0 design question the document lists.

Settled, not open: ViewComponent is not used (maintainer decision, 2026-09-07); the Rails baseline is the charter's pinned ref.

## 7. Out of scope and side findings

- No components beyond the 34 the scenarios require (32 for Data Table, `ToggleGroup`, `Toggle`); no changes to the generator, `dependencies.yml`, `mcp/`.
- No `main` of herb or reactionview; the document records what exists there as roadmap, with dates.
- No kit-style sugar helper, no named slots, no DSL.
- No `memory_profiler`, no page-level bench, no boot-time delta.
- 1.6 bugs found while reading, to fix on `main` outside this phase: `SelectContent(outlet_id:)` still appears in `select_docs.rb` and `select_test.rb`, but the constructor no longer accepts it and renders a literal `outlet-id="1"`; `DataTableExpandToggle` splats `**attrs` after the keywords, so a caller `data:` silently drops the Stimulus `data-action`; `SelectTrigger` emits a dead `aria-controls="radix-:r0:"`. These join the two already listed in `golden-suite.md`.

## 8. Verifying the plan as a whole

- `cd experiments/v2-gate && for g in Gemfile.herb Gemfile.erubi; do BUNDLE_GEMFILE=$g bin/rails test; done`: 18 parity scenarios, 4 differential scenarios, attribute differential, probes and system tests green.
- `BUNDLE_GEMFILE=Gemfile.core bin/rails test test/golden` green; `BUNDLE_GEMFILE=Gemfile.stable bin/rails test test/golden` result recorded.
- `bin/bench` regenerates `RESULTS.md` within the same order of magnitude.
- `wc -l app/components/ruby_ui/base.rb app/components/ruby_ui/attributes.rb` ≤ 500.
- `git status --porcelain gem docs mcp` identical before and after; `cd gem && bundle exec rake golden` still green.
- The decision document exists with exactly one outcome.

## Sources read and probes run (2026-09-07)

- https://github.com/marcoroth/herb — `herb.gemspec`; `lib/herb/engine.rb`, `lib/herb/engine/validators/{security,nesting,accessibility}_validator.rb` at tag `v0.10.3`; `lib/herb/engine/component_tags/*`, `lib/herb/engine/slots/*`, `lib/herb/cli.rb` on `main`; https://herb-tools.dev/projects/engine; https://rubygems.org/gems/herb/versions; `docs/docs/blog/whats-new-in-herb-v0-10.md`; issues #1094, #2422.
- https://github.com/marcoroth/reactionview — `reactionview.gemspec`, `lib/**`, `lib/reactionview/template/handlers/{erb,herb}.rb`, `lib/reactionview/template/handlers/herb/herb.rb` at `v0.4.0`; `.github/workflows/build.yml`, `Appraisals`; https://rubygems.org/gems/reactionview; issues #57, #82, #93, #95, #96, #103, #110.
- https://github.com/rails/rails/pull/58552; `actionview/lib/action_view/template/handlers/erb.rb` and `erb/herb.rb` at `60eb5cb7…`; `guides/source/configuring.md` (`config.action_view.erb_implementation`, commit `444665776`, PR #58359).
- Local: `actionview-8.1.3/lib/action_view/helpers/{rendering_helper,capture_helper}.rb`; `railties-8.1.3` `app_generator.rb:313-334` (`--minimal`); `phlex-2.4.1/lib/phlex/sgml/attributes.rb`, `lib/phlex/helpers.rb`; `gem/lib/ruby_ui/{base,dialog/*,select/*,data_table/*,toggle_group/*,toggle/toggle,toast/toast_region,pagination/pagination_item,dropdown_menu/dropdown_menu_content}.rb`; `gem/test/golden/*`; `gem/test/test_helper.rb`; `docs/Gemfile`; `docs/config/initializers/ruby_ui.rb`.
- Probe 1 (actionview 8.1.3, Erubi, `ActionView::Base.with_empty_template_cache.empty`, `render(inline:)` with a `render_in` object): body `"\n"` → capture `"\n"`; empty → `nil`; `"  "` → `"  "`; `"Apple"` → `"Apple"`; `do |g|` + `capture(self, &block)` → argument received; `tag.attributes({"data-x" => "", "disabled" => true, "style" => "…", "title" => "q\"<>&"})` → `data-x="" disabled="disabled" style="…" title="q&quot;&lt;&gt;&amp;"`; `tag.attributes({"data-x" => false, "data-y" => nil, "aria-z" => true})` → `data-x="false" aria-z="true"`.
- Probe 2 (herb 0.10.3 arm64-darwin, `Herb::Engine.new(src, validation_mode: :raise)`): `<div><span></div>` → `CompilationError`; `<div <%= attrs %>>` → `SecurityError` "ERB output tags (<%= %>) are not allowed in attribute position"; `<div <%= tag.attributes(component.attrs) %>>` → compiles; `<div class="<%= c %>">` → compiles (`::Herb::Engine.attr`); static `onchange="this.form.requestSubmit()"` → compiles; `<input class="hidden" name="person">` → compiles; `<turbo-frame …>` → compiles; `<%= render Probe.new do %>…<% end %>` and `do |g|` → compile to `render X.new do |g|; …; end`; `<button><a href="#">x</a></button>` → `CompilationError` (nesting).
