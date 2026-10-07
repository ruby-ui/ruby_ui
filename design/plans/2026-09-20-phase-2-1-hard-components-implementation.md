# Phase 2.1 — The Hard Components Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate the first components from Phlex to the 2.0 layer — Dialog (8 classes), Toggle and ToggleGroup (3), Select (8), Data Table (14, plus 3 adapters that emit no HTML) and ThemeToggle (1, pulled in because it renders Toggle) — with their 22 golden scenarios byte-identical to the frozen 1.6 snapshots in both the canonical and the strict form, their Stimulus controllers unedited, their unit tests ported and none deleted, and `docs/` pinned first to the `main` commit the ruler froze (a git ref, not RubyGems 1.6.0, which is behind `main`) so the site keeps building unchanged while the gem is mid-migration.

**Architecture:** Each component becomes a plain Ruby class inheriting `RubyUI::Component` (the layer Phase 2.0a built) beside a `.html.erb` sidecar that renders the computed attributes with `tag.attributes(component.attrs)` and the captured block with `component.content`. The ERB fixtures Phase 2.0b wrote are the ruler: they render the same composition before and after the migration, against the same snapshots, so a migration changes only an implementation. A migrated component's scenarios lose their Phlex block (the `Phlex::Kit` method that block calls no longer exists), leaving the ERB fixture as the only lane. Three gaps in the layer that these components expose are closed first: the nested attribute hash a component forwards to a neighbour (`mixed_attrs`), the sidecar file's final newline (dropped by `render_in`), and a subclass without a sidecar (renders its nearest ancestor's).

**Tech Stack:** Ruby 3.3 and 3.4 in CI (4.0.2 locally; 3.4.7 through `mise` for `docs/`), Minitest, ActionView / Railties 8.1.3.1, ReActionView 0.4.1, Herb 0.10.4, Phlex 2.4.1 and phlex-rails 2.4.0 (development only, for the components that have not migrated yet), tailwind_merge 1.5.5, Nokogiri.

**Reviewed:** by Codex on 2026-09-20 against `8ac23ac` (ten findings, each verified against the code before this revision; the verified ones are folded in below and listed in Appendix B).

**Spec:** `design/2026-09-19-rubyui-2-0-design.md` — §4.1 (anatomy), §4.3 (the layer's differences from 1.6), §6 "Phase 2.0" last bullet (the `docs/` pin), §6 "Phase 2.1 The hard components first" and §6 "Phase 2.2" (the per-component definition of done), §9.2 (upstream questions). Decisions 1–10 in `design/v2/decisions.md`, especially 7 (every fixture exists before any migration), 8 (the strict lane), 9 (scoped sidecar lookup) and 10 (what Herb's trim mode does; the sidecar layout was left to this plan). The "Not in this plan" section of `design/plans/2026-09-20-phase-2-0b-fixtures-implementation.md` is where this plan was scoped, and its "Translation rules" and Appendix A are the rules every fixture already follows. `design/v2/follow-up-issues.md` item 1 (#537, DataTable's nested forms) is ported as it is, not fixed here.

## Global Constraints

- Branch `v2/hard-components`, created from `v2/fixtures` (PR #554, unmerged, tip `8ac23ac`); the PR for this plan targets `v2/fixtures`. Never branch from, rebase onto, or push to `main`. Never push before Task 9 asks.
- Work in `gem/` for every task but Task 1 (`docs/`) and the registry rebuilds (`mcp/`). Run every command from the directory the step names. `ENV["RAILS_ENV"]` is `test` for every gem test run (the helper sets it).
- **No snapshot changes.** Never run `bundle exec rake golden:update` in this plan. `git status --porcelain gem/test/golden/snapshots gem/test/golden/strict` (from the repo root) is empty at the end of every task. Never hand-edit a file under either directory. A migration that needs a snapshot change is a port defect or a STOP (see "When a golden test fails"), never a re-record.
- **No fixture changes.** `gem/test/golden/views/**` is not touched: the fixtures are the translation of the scenarios and were proved against the snapshots with the components still Phlex (plan 2.0b). If a fixture seems wrong, that is a STOP.
- **The Stimulus controllers are unedited.** `git diff --quiet v2/fixtures -- 'gem/lib/ruby_ui/**/*.js'` succeeds at the end of every task.
- **The ruler does not change.** `gem/test/golden/harness.rb`, `catalog.rb`, `canonical_html.rb` and `golden_test.rb` are not touched. `gem/test/golden/scenarios.rb` changes only by removing the Phlex blocks of migrated scenarios (Tasks 3–7) and one paragraph of its header comment (Task 8).
- **A sidecar emits no whitespace of its own** (decision 12, taken in Task 2): no whitespace between `>` and `<`, none at a text–element boundary, a line break only inside an ERB tag or inside an HTML start tag between two attributes, no trim markers (`-%>`, `<%-`) anywhere, and the file ends with exactly one newline (which `render_in` drops). The sidecar rules below are the complete list; every sidecar in this plan is written out in full — copy it, do not reformat it.
- **Every attribute value that comes from the caller goes through `Attributes.flat`** and reaches the page through `tag.attributes` — never `name="<%= value %>"`. That is where nil omits the attribute, a Symbol dasherizes and a `javascript:` URL is dropped, as Phlex did on every element. Only a value the component picks from its own constants (`icon_class`, a polyline's points) may be interpolated.
- **`attrs` is flat; `mixed_attrs` is forwarded.** A sidecar hands `component.attrs` (String keys, serialized) to `tag.attributes`. Ruby that builds another component from a component's attributes, or merges more attributes in before serializing, uses `mixed_attrs` (Symbol keys, nested, classes merged — 1.6's `attrs`). Never splat `attrs` into a `.new`.
- **A migrated class has no Phlex in it:** no `view_template`, no `< Base`, no Phlex element call, no `plain`, no `safe` except the one `Phlex::SGML::SafeValue` `DataTablePerPageSelect` needs for a neighbour that is still Phlex (Task 7, with its comment).
- **Every `bundle exec rake golden` and `bundle exec rake test` in this plan ends with `0 failures, 0 errors, 0 skips`**, at the counts the progress table gives. A test filter is always anchored on the class — `N="/^RubyUI::DialogTest#/"` — because an unanchored `/DialogTest/` also selects `AlertDialogTest` and `/SelectTest/` selects `NativeSelectTest` and `DataTablePerPageSelectTest`. StandardRB is green at every commit. `mcp/data/registry.json` is rebuilt (`cd mcp && bundle exec exe/ruby-ui-mcp-build`) and committed in every task that changes a file under `gem/lib/ruby_ui/`.
- Every commit message ends with `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>`.

---

## What this plan measured — 2026-09-20

Every row was rendered through the real path — a template under the gem's `Rails.root`, compiled by ReActionView 0.4.1's handler and so by Herb 0.10.4 with `validation_mode = :raise` — on `v2/fixtures` at `8ac23ac`, Ruby 4.0.2. Probe sources are in Appendix A. "Strict-identical" means `Golden::CanonicalHtml.call(html, strict: true)` equal to the same form of the raw Phlex output.

| Question | Probe | Result |
| --- | --- | --- |
| A 2.0 component forwards its attributes to a Phlex neighbour (`Checkbox.new(**…)`): the nested hash, or the flat one? | 1a, 1b | The nested hash (`Attributes.mix(default_attrs, user_attrs)`) is strict-identical to 1.6's `DataTableRowCheckbox`. The flat hash is not: `"data-action"` lands beside Checkbox's `data: {action:}` and **two `data-action` attributes** reach the page where 1.6 concatenated them. Decision 11. |
| `yield(self)` with a component-scoped method — `do |group| … group.ToggleGroupItem(…) { "L" }` — through `helpers.render(X.new(…), &block)` | 2 | Renders; the `{ "L" }` block's String is the content (ActionView's `capture` returns the block's value when the buffer is empty). Works for a Phlex neighbour (Button) and a 2.0 one (a probe) alike. |
| An inline event handler for a Phlex neighbour: `NativeSelect.new(onchange: Phlex::SGML::SafeValue.new("…"))` from a sidecar, with the `<option>` elements written in the sidecar | 3 | Strict-identical to 1.6's `DataTablePerPageSelect`; Herb accepts `<option>` at the top level of a template. |
| Top-level `<li>`, a `<dialog>` root, `<svg viewbox>`, and line breaks inside a start tag between attributes | 4 | Compiles under `:raise`; a break between attributes is not output text. |
| A break inside an ERB tag — after `<%=`/`<%`, before `%>`, including the `<% end %>` that closes a `<%= … do %>` block | r5–r9 | Emits nothing, at any indentation. (Plan 2.0b's p6 confirmed; the newline the first probe run showed came from the next row.) |
| The sidecar *file's* final newline | r3, r10, r11 | **Is output.** Rendered inside a parent it is a text node after the component: `<b><i>B</i>\n</b>`. Decision 12 (b): `render_in` drops one trailing newline. |
| `-%>` on a block-closing `end` | r12 | The newline after it is kept (plan 2.0b p1 confirmed). |
| An `ActionView::Template` built inline with an identifier under `Rails.root` | 5a | Compiled by Herb (`<div><span></div>` raises `ActionView::SyntaxErrorInTemplate`); `render(inline:)` is compiled by Erubi (5b). The `erb` test helper (Task 2) uses the former. |
| `tag.attributes` with `"checked" => ""`, `"selected" => ""`, `"disabled" => ""`, `"aria-hidden" => ""` | 6 | `checked="checked" selected="selected" disabled="disabled" aria-hidden=""`; the canonical form equates `checked="checked"` with bare `checked` in both modes. Unit tests that grep for a bare `checked` must grep for `checked="checked"`. |
| Nested Ruby-side renders for a unit test: `view.render(A.new) { view.render(B.new) { "x" } }` | 7 | Works; the inner output is the outer content. |
| A Phlex component rendering a 2.0 component from Ruby (`render RubyUI::X.new`) | 8a, 8b | Works through phlex-rails **with a view context**; without one (`Phlex::HTML.new.call`, the golden suite's Phlex lane) it is `NoMethodError`. |
| `Phlex::Kit` and a constant that is not `Phlex::SGML` | 9 | No Kit method is defined: `RubyUI.Toggle` stops existing the moment `Toggle` migrates. `ThemeToggle` calls it (decision 14). |
| A subclass with no sidecar, defined outside every component root | 10 | Refused today (`under none of RubyUI.component_roots`). Decision 13. |
| A class whose file sits *directly* under a component root (`<root>/direct.rb`, a host's `app/components/my_button.rb`) | 24 | `File.split("direct")` is `[".", "direct"]`; `exists?("direct", ["."], …)` is `false` while `[""]` and `[]` are `true`. Today's `template` raises for it; the ancestor walk would have skipped its own sidecar. Task 2 normalizes the prefix. |
| 1.6 `SelectValue` with a block returning `" "`, `""`, `nil`, `"\n"`, `" x"` | 25 | `" "`, placeholder, placeholder, `"\n"`, `" x"`. Phlex emits the placeholder only when the block *output nothing* (`__yield_content__` runs `__implicit_output__` only if the buffer did not grow), so `presence` is wrong for whitespace; the rule is `content.nil? \|\| content.empty?`. |
| `ActionView::Template#source` | 25 | Returns the sidecar file's text, final newline included — what `render_in` checks before dropping one. |
| A Phlex component rendering a 2.0 component from Ruby, block bound correctly: `render(RubyUI::Probes::Div.new(id: "x")) { "y" }` | 25 | With a view context the block's `y` is rendered (the first run bound the block to `.new`); without one, calling the component directly is `NoMethodError: undefined method 'render' for nil`. Conclusion unchanged: a Phlex component needs a view context to render a 2.0 one. |
| The published `ruby_ui 1.6.0` gem against `gem/lib/ruby_ui` at the branch | `gem fetch`, `diff -rq` | **21 files differ** — Select, DropdownMenu, Popover, Sheet, HoverCard, Command, ContextMenu, Clipboard classes and controllers: `main` carries #506 (overlay exit animations) and #530 (HoverCard) after the release. The site renders `main`'s components today; a RubyGems pin would regress it and pair old markup with the checkout's controllers (`select_controller.js` reads a `panel` target the published `SelectContent` lacks). |
| `docs/Gemfile` with `gem "ruby_ui", github: "ruby-ui/ruby_ui", ref: "92f261931eb78bcc4682f4afb72b139553aba957", glob: "gem/*.gemspec"` and `mise exec ruby@3.4.7 -- bundle lock` | scratch copy | One hunk: the `PATH remote: ../gem` block becomes a `GIT` block with that revision and glob; specs and `BUNDLED WITH 2.6.4` unchanged. `Gem.loaded_specs["ruby_ui"].gem_dir` is `…/bundler/gems/ruby_ui-92f261931eb7/gem`, whose `lib/ruby_ui` differs from the branch's only in `context_menu_label.rb` (the Phase 1 fix on the ruler branch, `f471668`). `92f2619` is `main`'s tip and the merge base of this stack. |

Also read from the source, not measured: `docs/app/assets/stylesheets/application.tailwind.css` scans the directory `../../../../gem/lib/ruby_ui` (every file, `.html.erb` included), so the class strings a migration moves from a `.rb` into a sidecar stay in the site's CSS; the controller symlinks under `docs/app/javascript/controllers/ruby_ui/` point at the checkout, whose controllers this plan does not touch. `mcp`'s `RegistryBuilder` embeds every file under `lib/ruby_ui/<component>/` (`Dir.glob(File.join(dir, "*"))`), so the sidecars enter the registry with no builder change. `ComponentGenerator#components_file_paths` globs `*.rb` only, so the 1.6 generator would copy a migrated class without its sidecar — Phase 2.4 rewrites it (spec §6.2.4); nothing in this plan installs a component. The 17 sites in the gem that forward `**attrs` or merge `attrs` into another component are listed under decision 11 in Task 8; the ones in this plan's components are `DataTableRowCheckbox`, `DataTableSelectAllCheckbox`, `DataTableSortHead`, `DataTablePagination`, `DataTableExpandToggle`, `DataTableForm`, `DataTableSearch`, `DataTablePerPageSelect` and `ThemeToggle`.

## Decisions this plan takes

Recorded in `design/v2/decisions.md` by Task 8, applied from Task 2 on. Each is one paragraph there; the short form:

- **11. `attrs` stays flat; `mixed_attrs` is the hash a component forwards.** Measured above (1a/1b). The alternative — making `attrs` nested again and renaming what the sidecar hands to `tag.attributes` — would change the idiom in every sidecar to spare 17 Ruby sites.
- **12. Sidecars are whitespace-tight; a line breaks only inside a tag; `render_in` drops the file's final newline.** Measured above (4, r-series). The four largest sidecars in this plan (DialogContent, DataTableColumnToggle, DataTableSortHead, DataTablePagination) are the readability test decision 8 named; they are written out below so the maintainer judges them before execution, not after.
- **13. A class without a sidecar renders its nearest ancestor's.** Spec §6.2.1's open question. A host's `class MyButton < RubyUI::Button` inherited `view_template` in 1.6 and keeps working; `ToggleGroupItem < Toggle` has its own sidecar and uses it.
- **14. ThemeToggle migrates in 2.1; a migrated scenario keeps no Phlex block; the String form of an enum attribute is a unit test.** Measured above (8b, 9). The catalog already allows a block-less scenario (its ERB fixture is the only lane and the recording lane). Spec §6.2.2 asked for "a scenario passing the String form of every enum attribute"; the golden suite is the 1.6 contract and String coercion is 2.0 behaviour, so it is asserted as `render(size: :lg) == render(size: "lg")` in the component's unit tests instead — for every enumerated argument, `ToggleGroup`'s `type` and `orientation` and the item-level overrides included.
- **15. `docs/` pins a git ref of `main`, not RubyGems 1.6.0.** Measured above: the published gem is 21 files behind `main`, and the site renders `main`. `gem "ruby_ui", github: "ruby-ui/ruby_ui", ref: "92f2619…", glob: "gem/*.gemspec"` keeps the site on exactly the components it renders today; the spec's Phase 2.0 bullet and §3.3 said "the published 1.6" and are amended.

## Sidecar rules

How a 1.6 `view_template` becomes a class plus a sidecar. Every construct these five families use is here; the sidecars in the tasks are the rules applied.

| 1.6 (Phlex) | 2.0 |
| --- | --- |
| `class X < Base` | `class X < Component` (decision 6: the layer is `Component` until the last Phlex component goes) |
| `def view_template(&) = div(**attrs, &)` | delete the method; sidecar `<div <%= tag.attributes(component.attrs) %>><%= component.content %></div>` |
| `input(**attrs)` (a void element) | `<input <%= tag.attributes(component.attrs) %>>` |
| `yield`, `yield if block`, `block&.call`, `yield(self)` | `<%= component.content %>` — `render_in` already passed the component to the caller's block, so `do \|group\|` works with nothing more |
| `plain @label`, `{ @label }`, `{ plain p.to_s }` (text content) | `<%= component.label %>`, `<%= page %>` — a public `attr_reader` for every ivar the sidecar reads |
| an element whose attribute values come from the caller — `turbo_frame(id: @id, target: "_top")`, `input(type: "hidden", name: @name, value: v)`, `a(href: sort_href, class: "…")` | a public method returning `Attributes.flat(id: @id, target: "_top")` and `<turbo-frame <%= tag.attributes(component.frame_attrs) %>>`; never `id="<%= component.id %>"`, which would write `id=""` for nil, `foo_bar` for `:foo_bar`, and a `javascript:` href verbatim |
| a nested element with literal attributes — `span(class: "sr-only") { "Close" }`, `svg(viewbox: "…", fill_rule: "…") { \|s\| s.path(d: "…") }` | literal HTML: `<span class="sr-only">Close</span>`, `<svg viewbox="…" fill-rule="…"><path d="…"></path></svg>`. Attribute names are the Phlex keys dasherized (`fill_rule` → `fill-rule`, `stroke_width` → `stroke-width`); a key written `viewBox` stays `viewBox`, one written `viewbox` stays `viewbox`. Values verbatim. |
| a nested element with computed attributes — `input(type: "checkbox", checked: col.fetch(:visible, true), class: [...], data: {...})` | a public method returning `Attributes.flat({…})` and `<input <%= tag.attributes(component.checkbox_attrs(column)) %>>`. No Tailwind merge: Phlex did none on a raw element. |
| `el(literal: 1, **attrs)` or `el(**attrs.merge(h))` on the root element | a public method — `Attributes.flat({literal: 1}.merge(mixed_attrs))` or `Attributes.flat(mixed_attrs.merge(h))`, the same `merge` direction as 1.6's keyword splat — and `<el <%= tag.attributes(component.form_attrs) %>>` |
| `render RubyUI::X.new(args) { … }` | `<%= render RubyUI::X.new(args) do %>…<% end %>`. The neighbour may still be Phlex; the call is the same either way. |
| `render RubyUI::X.new(**attrs)`, `render RubyUI::X.new(class: "…", **attrs)` | `<%= render RubyUI::X.new(**component.mixed_attrs) %>`, `<%= render RubyUI::X.new(class: "…", **component.mixed_attrs) do %>…<% end %>` |
| `RubyUI.X(…)` (a Kit call from Ruby) | `<%= render RubyUI::X.new(…) %>` in the sidecar |
| a component-scoped method that renders — `def ToggleGroupItem(**kwargs, &block) = render RubyUI::ToggleGroupItem.new(…), &block` | `helpers.render(RubyUI::ToggleGroupItem.new(…), &block)` — `helpers` is the view context `render_in` stored before it captured the block, so the method is callable from inside that block |
| `return if total <= 1` | `<% if component.paginate? %>…<% end %>` with a public predicate; a false predicate renders `""` |
| `collection.each do … next if … end` | the filtering in a public Ruby method that returns pairs; `<% component.preserved_inputs.each do \|name, value\| %>…<% end %>` |
| `mix(a, b)` for a second element (Toggle's wrapper) | `Attributes.flat(Attributes.mix(a, b))` in a public method — no class merge, as 1.6's `mix` did none |
| `@size = size` then `SIZES[@size]`; `variant.to_sym` then `TABLE.fetch(variant, TABLE[:default])` | `@size = enum(size, SIZES, default: :md)`; `@variant = enum(variant, TABLE, default: :default)` — a String selects the same entry, an unknown value raises naming the allowed ones (spec decision B) |
| `safe("this.form.requestSubmit()")` for a Phlex neighbour's `onchange:` | `Phlex::SGML::SafeValue.new("this.form.requestSubmit()")` in a public method, with the comment Task 7 gives; a 2.2 item once NativeSelect migrates |
| `helpers.form_authenticity_token` behind `respond_to?` chains | `helpers.respond_to?(:form_authenticity_token) ? helpers.form_authenticity_token : "csrf-token-placeholder"` |
| `register_element :turbo_frame` then `turbo_frame(id:, target:)` | `<turbo-frame <%= tag.attributes(component.frame_attrs) %>>` with `frame_attrs = Attributes.flat(id: @id, target: "_top")` |
| `def default_attrs = {}` | delete it (`Component#default_attrs` is `{}`) |
| `before_template`, the development comment | nothing (spec §4.3) |

**Layout** (decision 12). Write the sidecar so that nothing but markup and ERB output reaches the page:

1. `>` is immediately followed by `<` or by an ERB tag; text sits directly against the tags around it (`>Close<`, `%>0 of <%=`).
2. A line may break inside a start tag, between two attributes, with the attributes indented — the shape Phlex source already has. The closing `>` of such a tag goes at the start of the next line, directly followed by the next `<`.
3. A line may break inside an ERB tag: `%><%=` at the end of a line and the Ruby indented on the next (`<%=\n  render … do %>`), or `<%\n  end %>`. A break inside the `<% end %>` that closes a render block is also silent (r5, r6), but every render block in this plan closes with `<% end %>` written whole, adjacent to what it closes.
4. No indentation outside a tag. No blank lines. No trim markers: never `-%>` or `<%-` (Herb honours them only partly, decision 10, and a `-%>` on the last tag would make `render_in`'s newline drop eat the content's own newline). The file ends with one `\n` and nothing after it.
5. A sidecar that fits on one line stays on one line.

A sidecar that breaks a rule is caught by the strict lane (a newline between siblings) or by the canonical lane (a newline that makes an empty element whitespace-only); both name the scenario.

## When a golden test fails

A migration is a refactor under a green test: the scenario's ERB fixture is green against the frozen snapshots before the component migrates (plan 2.0b) and must be green after. An `__erb` test that fails after a migration is handled in this order:

1. **Compare the sidecar with the Phlex `view_template` it replaces** — element, attribute names and values, the order of children, text — and the class with the 1.6 class — `default_attrs`, every ivar, every coercion. The failure message prints the expected and actual canonical (or strict) forms; a strict-only failure is whitespace the sidecar added (rule 1–4 above); a canonical failure is markup. Fix the port, re-run.
2. **If the port is faithful and the test still fails — STOP.** Report, without asserting a cause: the scenario slug; the sidecar and the class as written; the exception class and full message if it raised (`ActionView::SyntaxErrorInTemplate` carries Herb's annotated message; `ArgumentError` from `Attributes` names the attribute); otherwise the raw ERB-lane output (`Golden::Harness.render_erb(scenario)` from a console) and the canonical and strict diffs; the gem versions (`grep -E "^    (phlex|phlex-rails|reactionview|herb|actionview|railties|tailwind_merge) \(" Gemfile.lock`); and the reproducing command (`bundle exec rake test N=/test_<component>__<name>__erb/`). Two shapes that would be a STOP: a minted id that shifts (`select/default` renders `content00000001` today — a shift means something under the pin now calls `SecureRandom` that did not before, a `harness.rb` matter); and 1.6 markup that Herb refuses to compile (none is expected; the sidecars reproduce markup Herb already compiled through the fixtures' neighbours).
3. **The boundary holds either way.** Do not edit the snapshots, the fixtures, the harness, the canonical form, the catalog DSL, or a Stimulus controller. Do not mark a scenario `pending:`. A snapshot that "should" change is a maintainer decision recorded in `design/v2/decisions.md`, not a step here — follow-up issues 1–11 are the list of such changes, and this plan makes none of them.

A ported unit test that fails is handled the same way, with one more case: an assertion written against Phlex's serialization (a bare `checked`) is rewritten against the layer's (`checked="checked"`), which this plan does in the port itself (Task 7's `DataTableColumnToggleTest`).

## File Structure

| File | Responsibility |
| --- | --- |
| `docs/Gemfile`, `docs/Gemfile.lock` | `ruby_ui` from the GitHub repository at `main`'s commit `92f2619`, `glob: "gem/*.gemspec"`, instead of `path: "../gem"` (Task 1). |
| `gem/lib/ruby_ui/component.rb` | Gains `mixed_attrs`; `render_in` drops the sidecar file's final newline when the source has one; `template` walks the superclass chain; `own_template` (with the root-level prefix normalized); `component_root` returns nil instead of raising (Task 2). |
| `gem/test/test_helper.rb` | `ComponentTest#erb(source)`: an inline template compiled through Herb; `#descriptor`; the probe require glob widened to `test/probes/**/*.rb` (Task 2). |
| `gem/test/probes/ruby_ui/probes/inherited.rb`, `overridden.rb`, `overridden.html.erb`; `gem/test/probes/root_probe.rb`, `root_probe.html.erb` | The inheritance probes and the directly-under-a-root probe (Task 2). |
| `gem/test/ruby_ui/component_test.rb` | Nine new tests for the layer changes (Task 2). |
| `gem/lib/ruby_ui/dialog/*.rb` + `*.html.erb` | 8 classes, 8 sidecars (Task 3). |
| `gem/lib/ruby_ui/toggle/`, `toggle_group/`, `theme_toggle/` | 4 classes, 4 sidecars (Task 4). |
| `gem/lib/ruby_ui/select/*.rb` + `*.html.erb` | 8 classes, 8 sidecars (Task 5). |
| `gem/lib/ruby_ui/data_table/` | 14 classes, 14 sidecars; the 3 adapters untouched (Tasks 6–7). |
| `gem/test/ruby_ui/dialog_test.rb`, `select_test.rb`, `toggle_test.rb`, `toggle_group_test.rb`, `theme_toggle_test.rb`, `data_table_test.rb`, `data_table_*_test.rb` (14 rendering files) | Ported from `phlex { }` to `erb(…)`; every test kept (Tasks 3–7); the String-form enum tests, the SelectValue content tests, the CSRF test and the `javascript:` href test added where they belong. |
| `gem/test/golden/scenarios.rb` | 22 scenarios lose their Phlex block; the header comment gains a paragraph (Tasks 3–8). |
| `mcp/data/registry.json` | Rebuilt in Tasks 3–7. |
| `design/v2/decisions.md` | Entries 11–15 (Task 8). |
| `design/2026-09-19-rubyui-2-0-design.md` | §3.3, §4.3, §6 Phase 2.0 (the pin bullet), Phase 2.1 and 2.2, §9.2 amended (Task 8). |
| `design/v2/follow-up-issues.md` | Item 1's "2.0 note" corrected (Task 8). |

## Progress table

Baseline on `v2/fixtures` at `8ac23ac`: `bundle exec rake golden` → `410 runs` (188 Phlex-lane, 188 ERB-lane, 7 coverage, 27 of the ruler's own); `bundle exec rake test` → `776 runs`; `bundle exec standardrb` → `423 files inspected, no offenses detected`. Each migrated scenario removes one Phlex-lane test from both totals; the unit-test ports keep their counts (Dialog 10, Toggle 11, ToggleGroup 13, ThemeToggle 3, Select 3, DataTable 50, plus the 5 adapter tests that do not change); the new tests add theirs.

| After | Phlex-lane tests | `rake golden` runs | `rake test` runs | StandardRB files | What changed the counts |
| --- | --- | --- | --- | --- | --- |
| Task 1 | 188 | 410 | 776 | 423 | `docs/` only |
| Task 2 | 188 | 410 | 785 | 426 | +9 layer tests; +3 probe classes (`inherited.rb`, `overridden.rb`, `root_probe.rb`) |
| Task 3 | 182 | 404 | 781 | 426 | −6 dialog blocks; +2 enum tests |
| Task 4 | 175 | 397 | 781 | 426 | −7 blocks (toggle 3, toggle_group 3, theme_toggle 1); 27 tests ported; +7 enum and hidden-input tests |
| Task 5 | 173 | 395 | 782 | 426 | −2 select blocks; +3 SelectValue content tests |
| Task 6 | 171 | 393 | 781 | 426 | −2 blocks (`full_frame`, `expand_toggle_expanded`); +1 CSRF test |
| Task 7 | 166 | 388 | 777 | 426 | −5 blocks (the pagination, sort head and search scenarios); +1 `javascript:` href test |
| Task 8 | 166 | 388 | 777 | 426 | documentation only |

The check every migration task runs, from `gem/`:

```bash
bundle exec rake golden 2>&1 | grep -oE "[0-9]+ runs, [0-9]+ assertions, [0-9]+ failures, [0-9]+ errors, [0-9]+ skips|(Failure|Error):.*|Golden[A-Za-z]+Test#test_[a-z_0-9]+"
```

Expected: one `runs,` line with the task's numbers and `0 failures, 0 errors, 0 skips`, nothing else. Any test name in the output is a failing scenario — see "When a golden test fails".

Read before starting any task: `gem/lib/ruby_ui/component.rb`, `gem/lib/ruby_ui/attributes.rb` (the header comment is the serialization contract), `gem/test/test_helper.rb`, `gem/test/golden/catalog.rb` (`Scenario#lanes` and `#recording_lane`), the probes under `gem/test/probes/`, and the "Translation rules" of plan 2.0b.

---

## Task 1: The branch, and `docs/` on the `main` commit the ruler froze

**Files:**
- Modify: `docs/Gemfile:76` (the `ruby_ui` line)
- Modify: `docs/Gemfile.lock` (regenerated by Bundler, not by hand)

**Interfaces:**
- Consumes: the GitHub repository `ruby-ui/ruby_ui` at commit `92f261931eb78bcc4682f4afb72b139553aba957` — `main`'s tip and the merge base of this stack (`git merge-base main v2/fixtures`); Bundler's `glob:` option for a gemspec in a subdirectory; Ruby 3.4.7 through `mise` (`docs/.ruby-version` says `3.4.7`, `mise` does not switch to it in this checkout, so every `docs/` command below is prefixed with `mise exec ruby@3.4.7 --`).
- Produces: a `docs/` that renders exactly the components it renders today — `main`'s, which are 21 files ahead of the published 1.6.0 (decision 15) — whatever the gem under `../gem` becomes. `docs/config/initializers/ruby_ui.rb` reads `Gem.loaded_specs["ruby_ui"].gem_dir` and needs no change: with a git source that is `…/bundler/gems/ruby_ui-92f261931eb7/gem`. The Tailwind `@source` scans the checkout's `gem/lib/ruby_ui` directory and the controller symlinks point at the checkout; both are unaffected because a migration keeps every class string and touches no controller.

- [ ] **Step 1: Confirm the branch**

`v2/hard-components` already exists: it was created from `v2/fixtures` at `8ac23ac` when this plan was written, and its first commits are the plan and its revision. Run from the repo root:

```bash
git checkout v2/hard-components && git status --porcelain && git log --oneline -3 && git merge-base --is-ancestor 8ac23ac HEAD && echo "stacked on v2/fixtures" && git merge-base main v2/fixtures
```

Expected: an empty status, the plan commit(s) on top of `8ac23ac …Whole-branch review fixes…`, `stacked on v2/fixtures`, and `92f261931eb78bcc4682f4afb72b139553aba957`. If the merge base differs, `main` moved: use the printed commit in Step 2 instead of `92f2619…` and say so in the commit body. If PR #554 gained review commits after `8ac23ac`, rebase this branch onto the new tip first (`git rebase v2/fixtures`).

- [ ] **Step 2: Pin the gem in `docs/Gemfile`**

Replace line 76:

```ruby
gem "ruby_ui", path: "../gem", require: false
```

with:

```ruby
# Pinned to main's commit while ../gem migrates to 2.0 (spec §6 Phase 2.0,
# last bullet; decision 15 — RubyGems 1.6.0 is behind main). Phase 3.3 points
# it back at path: "../gem".
gem "ruby_ui", github: "ruby-ui/ruby_ui", ref: "92f261931eb78bcc4682f4afb72b139553aba957", glob: "gem/*.gemspec", require: false
```

- [ ] **Step 3: Regenerate the lockfile with Bundler under Ruby 3.4.7**

```bash
cd docs && mise exec ruby@3.4.7 -- ruby -v && mise exec ruby@3.4.7 -- bundle lock
```

Expected: `ruby 3.4.7 …`, then `Writing lockfile to …/docs/Gemfile.lock`, `Fetching https://github.com/ruby-ui/ruby_ui.git`, `Fetching gem metadata from https://rubygems.org/…`, `Resolving dependencies...`. Then review the diff:

```bash
git diff --stat docs/ && git diff docs/Gemfile.lock
```

Expected: exactly one hunk in the lock — the block

```
PATH
  remote: ../gem
  specs:
    ruby_ui (1.6.0)
```

becomes

```
GIT
  remote: https://github.com/ruby-ui/ruby_ui.git
  revision: 92f261931eb78bcc4682f4afb72b139553aba957
  ref: 92f261931eb78bcc4682f4afb72b139553aba957
  glob: gem/*.gemspec
  specs:
    ruby_ui (1.6.0)
```

`ruby_ui!` under `DEPENDENCIES` stays (git sources are `!` like path sources); `BUNDLED WITH` stays `2.6.4`; `RUBY VERSION` stays `ruby 3.4.7p58`. Any other hunk means Bundler re-resolved more than the pin; revert the lock (`git checkout docs/Gemfile.lock`) and run `mise exec ruby@3.4.7 -- bundle lock --conservative`, then review again.

- [ ] **Step 4: Prove the pinned components are the ones the site renders today**

Install the docs bundle under 3.4.7 and diff the pinned gem's component sources against the checkout's:

```bash
cd docs && mise exec ruby@3.4.7 -- bundle install --quiet && GEM_DIR=$(mise exec ruby@3.4.7 -- bundle exec ruby -e 'puts Gem.loaded_specs["ruby_ui"].gem_dir' 2>/dev/null | tail -1) && echo "$GEM_DIR" && diff -rq "$GEM_DIR/lib/ruby_ui" ../gem/lib/ruby_ui | grep -v "component.rb\|attributes.rb"
```

Expected: a path ending in `bundler/gems/ruby_ui-92f261931eb7/gem`, and exactly one differing file, `context_menu_label.rb` — the Phase 1 fix the ruler branch carries (`f471668`) and `main` does not yet. `component.rb` and `attributes.rb` exist only in the checkout (the 2.0 layer). Anything else differing is a STOP: the pin is not the code the site renders.

Then boot the app on it:

```bash
mise exec ruby@3.4.7 -- bin/rails runner 'puts Gem.loaded_specs["ruby_ui"].gem_dir; puts RubyUI::VERSION; puts RubyUI::SelectContent.instance_method(:view_template).source_location.first'
```

Expected: the same gem dir, `1.6.0`, and a `select_content.rb` path under that gem dir (the initializer autoloads from it). If `bundle install` fails on a native extension or `runner` on a missing database or Node asset — an environment problem unrelated to the pin — record the exact error in the commit body's last line and rely on the CI Docs job (it runs `pnpm build`, `standardrb` and `bin/rails db:test:prepare test` against this lock); do not change anything else in `docs/` to get past it.

- [ ] **Step 5: Confirm nothing under `gem/` or `mcp/` moved, then commit**

```bash
cd .. && git status --porcelain
```

Expected: exactly ` M docs/Gemfile` and ` M docs/Gemfile.lock`.

```bash
git add docs/Gemfile docs/Gemfile.lock
git commit -m "[Feature] RubyUI 2.0: docs/ consumes main's ruby_ui while the gem migrates

The site's Gemfile pointed at ../gem. From Phase 2.1 on that gem is
mid-migration to the 2.0 layer, and the first migrated component would
break the site (its Phlex Kit method stops existing). Pin docs/ to the
gem at main's commit 92f2619 — a git source with glob: gem/*.gemspec —
so the CI Docs job stays green through Phase 2; Phase 3.3 points it
back at the path.

Not the published 1.6.0, as spec §6 Phase 2.0 said: that gem is 21
files behind main (#506's overlay exit animations, #530's HoverCard),
and pinning to it would have regressed the site and paired its markup
with the checkout's newer controllers (decision 15). The pinned
sources differ from the branch's only in context_menu_label.rb, the
Phase 1 fix main does not have yet.

The initializer reads Gem.loaded_specs[\"ruby_ui\"].gem_dir and resolves
to the git checkout unchanged; Tailwind scans the repository's
gem/lib/ruby_ui directory and the Stimulus controller symlinks reach
../gem by relative path — a migration keeps every class string and
touches no controller.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

## Task 2: The layer — `mixed_attrs`, the sidecar's final newline, inherited sidecars, and an inline ERB test helper

**Files:**
- Modify: `gem/lib/ruby_ui/component.rb` (the whole file is given below)
- Modify: `gem/test/test_helper.rb:83` (the probe require glob) and `:96-107` (`ComponentTest`)
- Create: `gem/test/probes/ruby_ui/probes/inherited.rb`
- Create: `gem/test/probes/ruby_ui/probes/overridden.rb`, `gem/test/probes/ruby_ui/probes/overridden.html.erb`
- Create: `gem/test/probes/root_probe.rb`, `gem/test/probes/root_probe.html.erb`
- Test: `gem/test/ruby_ui/component_test.rb` (nine new tests; two existing ones keep passing with the new error message)

**Interfaces:**
- Consumes: `RubyUI::Attributes.mix`, `.merge_classes`, `.flat` (unchanged); `ActionView::LookupContext#exists?` and `#find`; `ActiveSupport::SafeBuffer#chomp` (returns a plain String) and `String#html_safe`.
- Produces, for every later task:
  - `Component#attrs` → `Hash<String, String>`: unchanged, the flat hash for `tag.attributes`.
  - `Component#mixed_attrs` → frozen `Hash<Symbol, Object>`: `Attributes.mix(default_attrs, user_attrs)` with `[:class]` Tailwind-merged — 1.6's `attrs`. Forward it: `RubyUI::Checkbox.new(**mixed_attrs)`, `Attributes.flat({type: "button"}.merge(mixed_attrs))`.
  - `Component#render_in(view_context, **, &block)` → `ActiveSupport::SafeBuffer` without the sidecar file's final newline (dropped only when the template source ends with one; the content's own trailing newline survives).
  - `Component.template` → the class's own sidecar or the nearest ancestor's — a class directly under a root (`<root>/my_button.rb`) finds `<root>/my_button.html.erb`; `ArgumentError` naming every path tried when the chain up to `Component` has none.
  - `ComponentTest#erb(source) → ActiveSupport::SafeBuffer`: compiles `source` through Herb (identifier under the gem) and renders it with a fresh `RubyUI::TestApp.view`.
  - `ComponentTest#descriptor(text) → String`: regexp source matching a Stimulus descriptor whether its `->` was escaped (`-&gt;`, by `tag.attributes`) or not (a sidecar literal, a Phlex neighbour). Used by the ported unit tests from Task 3 on.

- [ ] **Step 1: Write the failing tests**

Add to `gem/test/ruby_ui/component_test.rb`, inside `class LayerTest < ComponentTest`, after `test_a_class_outside_every_component_root_is_refused` (keep everything that is there):

```ruby
  def test_mixed_attrs_is_the_nested_hash_with_classes_merged
    component = RubyUI::Probes::Div.new(class: "p-4", data: {x: 1})

    assert_equal({class: "probe p-4", data: {probe: true, x: 1}}, component.mixed_attrs)
    assert_equal({"class" => "probe p-4", "data-probe" => "", "data-x" => "1"}, component.attrs)
  end

  def test_mixed_attrs_is_frozen
    assert_predicate RubyUI::Probes::Div.new.mixed_attrs, :frozen?
  end

  def test_the_sidecars_final_newline_is_not_output
    sidecar = File.join(RubyUI::TestApp::ROOT, "test/probes/ruby_ui/probes/div.html.erb")
    assert File.read(sidecar).end_with?("\n"), "the probe's sidecar must end with a newline for this test to mean anything"

    assert_equal %(<div class="probe" data-probe="">x</div>), view.render(RubyUI::Probes::Div.new) { "x" }
  end

  def test_nested_components_emit_nothing_between_them
    v = view
    html = v.render(RubyUI::Probes::Div.new(id: "o")) { v.render(RubyUI::Probes::Div.new(id: "i")) { "x" } }

    assert_equal %(<div class="probe" data-probe="" id="o"><div class="probe" data-probe="" id="i">x</div></div>), html
  end

  # A host's `class MyButton < RubyUI::Button`: defined under no component root,
  # with no sidecar of its own.
  class HostSubclass < RubyUI::Probes::Div
  end

  def test_a_subclass_without_a_sidecar_renders_its_nearest_ancestors
    assert_equal %(<div class="probe" data-probe="">i</div>), view.render(RubyUI::Probes::Inherited.new) { "i" }
    assert_equal %(<div class="probe" data-probe="">h</div>), view.render(HostSubclass.new) { "h" }
  end

  def test_a_subclass_with_its_own_sidecar_uses_it
    assert_equal %(<p class="probe" data-probe="">o</p>), view.render(RubyUI::Probes::Overridden.new) { "o" }
  end

  # A host's app/components/my_button.rb: the class file directly under a
  # root, where File.split gives "." for the prefix.
  def test_a_class_directly_under_a_root_finds_its_sidecar
    assert_equal "<i>r</i>", view.render(RootProbe.new) { "r" }
  end

  def test_the_contents_own_trailing_newline_survives
    assert_equal %(<div class="probe" data-probe="">body\n</div>), view.render(RubyUI::Probes::Div.new) { "body\n" }
  end

  def test_erb_compiles_an_inline_template_through_herb
    assert_raises(ActionView::SyntaxErrorInTemplate) { erb("<div><span></div>") }
    assert_equal %(<div class="probe" data-probe="">Hello</div>), erb(%(<%= render RubyUI::Probes::Div.new do %>Hello<% end %>))
  end
```

Create the two probes. `gem/test/probes/ruby_ui/probes/inherited.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  module Probes
    # No sidecar of its own: renders Div's, as a host subclass of a gem
    # component does (decision 13).
    class Inherited < Div
    end
  end
end
```

`gem/test/probes/ruby_ui/probes/overridden.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  module Probes
    # A subclass with its own sidecar — ToggleGroupItem's shape.
    class Overridden < Div
    end
  end
end
```

`gem/test/probes/ruby_ui/probes/overridden.html.erb` (one line, trailing newline):

```erb
<p <%= tag.attributes(component.attrs) %>><%= component.content %></p>
```

`gem/test/probes/root_probe.rb` — directly under the `test/probes` root, no namespace:

```ruby
# frozen_string_literal: true

# A class file directly under a component root — a host's
# app/components/my_button.rb — where the lookup prefix is empty.
class RootProbe < RubyUI::Component
end
```

`gem/test/probes/root_probe.html.erb` (one line, trailing newline):

```erb
<i><%= component.content %></i>
```

- [ ] **Step 2: Run the tests to verify they fail**

```bash
cd gem && bundle exec rake test N=/LayerTest/ 2>&1 | grep -E "runs,|Error:|Failure:|NoMethodError|ArgumentError" | head -20
```

Expected: `25 runs`, 9 failures/errors — `mixed_attrs` is `NoMethodError`; the newline tests fail on `"…</div>\n"` versus `"…</div>"` (the content-newline test on `"body\n</div>\n"`); `Inherited`, `HostSubclass` and `RootProbe` raise `ArgumentError` (`no sidecar template` / `component_roots`); `erb` is `NoMethodError`. (`RootProbe` is only defined once Step 4 widens the require glob; until then its test is a `NameError`, which also counts as red.)

- [ ] **Step 3: Rewrite `gem/lib/ruby_ui/component.rb`**

The whole file:

```ruby
# frozen_string_literal: true

require "action_view"
require_relative "attributes"

module RubyUI
  class << self
    # The directories that hold `ruby_ui/`: `app/components` in a host
    # application, `lib` in this gem. A component's sidecar template is looked
    # up under the root that contains its class file, and nowhere else — the
    # application's view paths are never consulted, so a host template at the
    # same virtual path cannot shadow it and it cannot shadow the host.
    def component_roots
      @component_roots ||= []
    end

    attr_writer :component_roots

    def lookup_for(root)
      (@lookups ||= {})[root] ||= ActionView::LookupContext.new(
        ActionView::PathRegistry.cast_file_system_resolvers([root]), {formats: [:html]}
      )
    end
  end

  # The 2.0 component layer: a plain Ruby object that ActionView renders
  # through `render_in`, with an ERB sidecar template next to the class file.
  #
  #   # app/components/ruby_ui/dialog/dialog.rb
  #   class RubyUI::Dialog < RubyUI::Component
  #     def initialize(open: false, **attrs)
  #       @open = open
  #       super(**attrs)
  #     end
  #
  #     private def default_attrs
  #       {data: {controller: "ruby-ui--dialog", ruby_ui__dialog_open_value: @open}}
  #     end
  #   end
  #
  #   # app/components/ruby_ui/dialog/dialog.html.erb
  #   <div <%= tag.attributes(component.attrs) %>><%= component.content %></div>
  #
  #   # a view
  #   <%= render RubyUI::Dialog.new(open: true) do %> ... <% end %>
  #
  # `attrs` is computed in `initialize` with no view context — mix, Tailwind
  # merge, then Phlex-semantics serialization (see Attributes) — so a component
  # can read a neighbour's computed attributes (`Button.new(...).attrs["class"]`).
  # `mixed_attrs` is the same hash before serialization — nested, Symbol-keyed,
  # classes merged; what `attrs` was in 1.6 — for a component that forwards its
  # attributes to another component in Ruby (`Checkbox.new(**mixed_attrs)`) or
  # merges more in before serializing (`Attributes.flat({type: "button"}.merge(mixed_attrs))`).
  # Forwarding the flat form instead puts `"data-action"` beside the neighbour's
  # `data: {action:}` and two attributes reach the page (decision 11).
  #
  # `render_in` captures the caller's block with the component as the block
  # argument (for `do |group|` components), renders the sidecar with
  # `component` as its only local, and drops the sidecar file's final newline
  # when the file has one: 1.6 emitted none, and inside a parent it would be a
  # text node after the component (decision 12). A class with no sidecar beside its own file
  # renders its nearest ancestor's, as a host's `class MyButton < RubyUI::Button`
  # inherited `view_template` in 1.6 (decision 13). Nothing else: no named
  # slots, no DSL.
  #
  # Named `Component` while the Phlex `RubyUI::Base` still exists; it takes
  # the name `Base` when the last Phlex component is gone.
  class Component
    attr_reader :attrs, :mixed_attrs, :content

    def initialize(**user_attrs)
      mixed = Attributes.mix(default_attrs, user_attrs)
      mixed[:class] = Attributes.merge_classes(mixed[:class]) if mixed[:class]
      @mixed_attrs = mixed.freeze
      @attrs = Attributes.flat(mixed)
    end

    # ActionView's renderable protocol. Rails passes `locals:`; the caller's
    # locals are not the component's, so they are accepted and ignored.
    # `content` is set on every call — nil without a block — so an instance
    # rendered twice never repeats its first content.
    def render_in(view_context, **, &block)
      @view_context = view_context
      @content = block ? view_context.capture(self, &block) : nil
      template = self.class.template
      rendered = template.render(view_context, {component: self})
      # The file's final newline, when the file has one; a sidecar never
      # carries a trim marker (decision 12), so the last byte of the source
      # is the last byte of the output.
      (template.source.end_with?("\n") && rendered.end_with?("\n")) ? rendered.chomp.html_safe : rendered
    end

    # The view context, for a component that needs a Rails helper from Ruby
    # (`helpers.form_authenticity_token`) or renders a neighbour from a method.
    # Set by render_in; raises before the first render.
    def helpers
      @view_context or raise ArgumentError, "#{self.class.name} has no view context outside render_in"
    end

    class << self
      # Looked up on every render, not cached here: the resolver behind the
      # lookup context caches compiled templates and Rails' reloader clears it,
      # so a Template cached on the class would outlive an edit in development.
      # The class's own sidecar, or the nearest ancestor's up to Component.
      def template
        klass = self
        reasons = []
        while klass < Component
          found, reason = klass.own_template
          return found if found

          reasons << reason
          klass = klass.superclass
        end
        raise ArgumentError, "#{name} has no sidecar template: #{reasons.join("; ")}"
      end

      # [template, nil] when a sidecar sits beside this class's own file under a
      # component root; [nil, why not] otherwise. `exists?` before `find`, so an
      # inherited sidecar costs no exception per render.
      def own_template
        root = component_root
        return [nil, "#{source_file} is under none of RubyUI.component_roots #{RubyUI.component_roots.inspect}"] unless root

        relative = source_file.delete_prefix("#{root}/").delete_suffix(".rb")
        prefix, base = File.split(relative)
        # A file directly under the root splits to ".", which the lookup
        # does not resolve; the empty prefix list does.
        prefixes = (prefix == ".") ? [] : [prefix]
        lookup = RubyUI.lookup_for(root)
        return [nil, "no #{relative}.html.erb under #{root}"] unless lookup.exists?(base, prefixes, false, [:component])

        [lookup.find(base, prefixes, false, [:component]), nil]
      end

      def source_file
        @source_file ||= Object.const_source_location(name)&.first or
          raise ArgumentError, "#{name}: no source location to derive a sidecar template from"
      end

      # Memoized on first use: set RubyUI.component_roots in an initializer,
      # before any render. nil when the file is under no root.
      def component_root
        @component_root ||= RubyUI.component_roots.map(&:to_s).find { |root| source_file.start_with?("#{root}/") }
      end
    end

    private

    def default_attrs
      {}
    end

    # Coerces and validates an enumerated attribute. `size: "lg"` from a tag or
    # from params arrives as a String, `size: :lg` from Ruby as a Symbol, and
    # both must select `table[:lg]`; nil takes the default. Anything else names
    # the allowed values instead of silently dropping the class.
    def enum(value, table, default:)
      key = value.nil? ? default : value
      key = key.to_sym if key.respond_to?(:to_sym)
      return key if table.key?(key)

      if value.nil?
        raise ArgumentError,
          "#{self.class.name}: default: #{default.inspect} is not one of #{table.keys.map(&:inspect).join(", ")}"
      end

      raise ArgumentError,
        "#{self.class.name}: #{value.inspect} is not one of #{table.keys.map(&:inspect).join(", ")}"
    end
  end
end
```

Two existing tests read the error message: `test_a_missing_sidecar_is_named` matches `ruby_ui/probes/bare\.html\.erb` (now inside `no ruby_ui/probes/bare.html.erb under …`) and `test_a_class_outside_every_component_root_is_refused` matches `/component_roots/` (now inside `… is under none of RubyUI.component_roots […]`). Both still pass; do not weaken them.

- [ ] **Step 4: Widen the probe glob and add the `erb` and `descriptor` helpers to `gem/test/test_helper.rb`**

Change the probe require line (the one after `RubyUI.component_roots = …`) from `test/probes/ruby_ui/**/*.rb` to every Ruby file under the root, so `root_probe.rb` loads:

```ruby
Dir.glob(File.join(RubyUI::TestApp::ROOT, "test/probes/**/*.rb")).sort.each { |probe| require probe }
```

Then replace the `ComponentTest` class at the end of the file with:

```ruby
class ComponentTest < Minitest::Test
  def render(component, &)
    component.call(&)
  end

  def phlex(&)
    render Phlex::HTML.new, &
  end

  def render_erb(template)
    RubyUI::TestApp.view.render(template: template)
  end

  # An inline template compiled through the same handler as a file under
  # Rails.root: ReActionView decides by the identifier, so an identifier under
  # the gem puts Herb in front of it (a malformed snippet raises), and a unit
  # test renders a composition without a fixture file. `render(inline:)` would
  # go through Erubi instead.
  def erb(source)
    handler = ActionView::Template.handler_for_extension(:erb)
    identifier = File.join(RubyUI::TestApp::ROOT, "test/inline.html.erb")
    ActionView::Template.new(source, identifier, handler, locals: [], format: :html).render(RubyUI::TestApp.view, {})
  end

  # In an attribute value that `tag.attributes` serialized, `->` is `-&gt;`
  # (ERB::Util.html_escape); in one a sidecar wrote literally, or a Phlex
  # neighbour rendered, it is `->`. A test that reads a Stimulus descriptor
  # accepts both, so it survives the neighbour's own migration.
  def descriptor(text)
    Regexp.escape(text).gsub('\->', "-(?:>|&gt;)")
  end
end
```

`Regexp.escape` writes `-` as `\-`, which is why the `gsub` looks for `\->`. `descriptor("click->x#y")` is `click-(?:>|&gt;)x\#y`; use it as `assert_match(/data-action="#{descriptor("click->x#y")}"/, output)`.

- [ ] **Step 5: Run the layer tests, then everything**

```bash
cd gem && bundle exec rake test N=/LayerTest/ 2>&1 | grep -E "runs,"
```

Expected: `25 runs, … 0 failures, 0 errors, 0 skips`.

```bash
bundle exec rake golden 2>&1 | grep -E "runs,"; bundle exec rake test 2>&1 | grep -E "runs,"; bundle exec standardrb
```

Expected: `410 runs` (unchanged — the golden lanes render Phlex components; the three new probes are under `test/probes`, not `lib`, so `component_classes` does not count them), `785 runs`, `426 files inspected, no offenses detected`. If StandardRB objects to the `while` loop in `template`, keep the loop and fix the offense it names; do not rewrite the walk with `ancestors`, which includes the modules the golden harness prepends.

- [ ] **Step 6: Guards, then commit**

```bash
cd .. && git status --porcelain gem/test/golden/snapshots gem/test/golden/strict gem/test/golden/views && git diff --quiet v2/fixtures -- 'gem/lib/ruby_ui/**/*.js' && echo clean
```

Expected: `clean` and nothing else. Then:

```bash
git add gem/lib/ruby_ui/component.rb gem/test/test_helper.rb gem/test/probes/ruby_ui/probes/inherited.rb gem/test/probes/ruby_ui/probes/overridden.rb gem/test/probes/ruby_ui/probes/overridden.html.erb gem/test/probes/root_probe.rb gem/test/probes/root_probe.html.erb gem/test/ruby_ui/component_test.rb
git commit -m "[Feature] RubyUI::Component: mixed_attrs, the sidecar's final newline, inherited sidecars, an inline ERB test helper

Three things the first migrations need from the layer, measured before
they were written (plan 2.1, \"What this plan measured\"):

- mixed_attrs: the nested, Symbol-keyed hash after mix and the class
  merge — 1.6's attrs — frozen. A component that builds another
  component in Ruby forwards this one; forwarding the flat attrs puts
  \"data-action\" beside the neighbour's data: {action:} and two
  attributes reach the page where 1.6 concatenated them (decision 11).
- render_in drops the sidecar file's final newline when the source
  ends with one. Every file ends with one, and rendered inside a parent
  it was a text node after the component — whitespace Phlex never
  emitted (decision 12). The content's own newline survives.
- template walks the superclass chain to the first class with a
  sidecar beside its own file, so a host's MyButton < RubyUI::Button
  keeps rendering as it did when it inherited view_template; a class
  with its own sidecar uses it; a class directly under a root finds
  its own (the lookup prefix is empty there, not "."); a chain with
  none raises naming every path tried (decision 13).

ComponentTest#erb compiles an inline template with an identifier under
the gem, which is what ReActionView checks, so unit tests render a
composition through Herb without a fixture file; #descriptor matches a
Stimulus descriptor whether tag.attributes escaped its -> or not.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

## Task 3: Dialog — the first components on the 2.0 layer

**Files:**
- Modify: `gem/lib/ruby_ui/dialog/dialog.rb`, `dialog_content.rb`, `dialog_description.rb`, `dialog_footer.rb`, `dialog_header.rb`, `dialog_middle.rb`, `dialog_title.rb`, `dialog_trigger.rb` (each file's whole content is given)
- Create: the eight sidecars beside them, `gem/lib/ruby_ui/dialog/<name>.html.erb`
- Modify: `gem/test/ruby_ui/dialog_test.rb` (whole file given)
- Modify: `gem/test/golden/scenarios.rb` — the `"dialog"` block
- Untouched: `gem/lib/ruby_ui/dialog/dialog_controller.js`, `dialog_docs.rb`
- Rebuild: `mcp/data/registry.json`

**Interfaces:**
- Consumes: `RubyUI::Component` (Task 2), `Component#enum`; `RubyUI::Button` (still Phlex) inside the compositions the tests and fixtures render.
- Produces: `RubyUI::Dialog.new(open: false, **attrs)`, `RubyUI::DialogContent.new(size: :md, **attrs)` — `size` accepts `:xs :sm :md :lg :xl :full` as Symbol or String and raises `ArgumentError` on anything else — and six plain wrappers `DialogDescription`, `DialogFooter`, `DialogHeader`, `DialogMiddle`, `DialogTitle`, `DialogTrigger`, each `new(**attrs)`. Rendered as `<%= render RubyUI::Dialog.new do %>…<% end %>`; the six golden fixtures under `gem/test/golden/views/dialog/` are the reference compositions.

- [ ] **Step 1: Port `dialog_test.rb` to the ERB helper, with two new enum tests**

Replace `gem/test/ruby_ui/dialog_test.rb` with:

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::DialogTest < ComponentTest
  DIALOG_WITH_CONTENT = %(<%= render RubyUI::Dialog.new do %><%= render RubyUI::DialogContent.new do %>Content<% end %><% end %>)

  def test_render_with_all_items
    output = erb(<<~ERB)
      <%= render RubyUI::Dialog.new do %><%= render RubyUI::DialogTrigger.new do %><%= render RubyUI::Button.new do %>Open Dialog<% end %><% end %><%= render RubyUI::DialogContent.new do %><%= render RubyUI::DialogHeader.new do %><%= render RubyUI::DialogTitle.new do %>RubyUI to the rescue<% end %><%= render RubyUI::DialogDescription.new do %>RubyUI helps you build accessible standard compliant web apps with ease<% end %><% end %><%= render RubyUI::DialogMiddle.new do %><%= render RubyUI::AspectRatio.new(aspect_ratio: "16/9", class: "rounded-md overflow-hidden border") do %><img alt="Placeholder" loading="lazy" src="https://avatars.githubusercontent.com/u/246692?v=4"><% end %><% end %><%= render RubyUI::DialogFooter.new do %><%= render RubyUI::Button.new(variant: :outline, data: {action: "click->ruby-ui--dialog#dismiss"}) do %>Cancel<% end %><%= render RubyUI::Button.new do %>Save<% end %><% end %><% end %><% end %>
    ERB

    assert_match(/Open Dialog/, output)
  end

  # Regression test for #343: Dialog content must use native <dialog> element, not <div>
  def test_dialog_content_renders_native_dialog_element
    output = erb(DIALOG_WITH_CONTENT)

    assert_match(/<dialog[\s>]/, output, "DialogContent must render a native <dialog> element")
    refute_match(/<template[\s>]/, output, "DialogContent must not use a <template> element")
  end

  def test_dialog_wrapper_renders_as_div_with_stimulus_controller
    output = erb(DIALOG_WITH_CONTENT)

    assert_match(/data-controller="ruby-ui--dialog"/, output)
    assert_match(/<div[^>]*data-controller="ruby-ui--dialog"/, output, "Dialog wrapper must be a <div>")
  end

  def test_dialog_content_has_stimulus_target
    assert_match(/data-ruby-ui--dialog-target="dialog"/, erb(DIALOG_WITH_CONTENT))
  end

  def test_dialog_content_has_backdrop_click_action
    assert_match(/data-action="#{descriptor("click->ruby-ui--dialog#backdropClick")}"/, erb(DIALOG_WITH_CONTENT))
  end

  # Regression test: a closed native <dialog> must stay hidden. The bare `flex`
  # utility (author CSS) overrides the UA `dialog:not([open]) { display: none }`,
  # making the dialog always visible. Display must be gated on the open: variant.
  def test_dialog_content_does_not_force_display_when_closed
    output = erb(DIALOG_WITH_CONTENT)

    classes = output[/<dialog\b.*?\sclass="([^"]*)"/m, 1].to_s.split
    refute_includes classes, "flex", "Bare `flex` forces a closed <dialog> to display; use `open:flex`"
    assert_includes classes, "open:flex", "Dialog must apply flex only when open (open:flex)"
  end

  def test_dialog_content_sizes
    {xs: "max-w-sm", sm: "max-w-md", md: "max-w-lg", lg: "max-w-2xl", xl: "max-w-4xl", full: "max-w-full"}.each do |size, expected_class|
      output = erb(%(<%= render RubyUI::Dialog.new do %><%= render RubyUI::DialogContent.new(size: #{size.inspect}) do %>Content<% end %><% end %>))

      assert_match(/#{Regexp.escape(expected_class)}/, output, "Size #{size} should apply class #{expected_class}")
    end
  end

  def test_dialog_open_value_is_set_on_wrapper
    output = erb(%(<%= render RubyUI::Dialog.new(open: true) do %><%= render RubyUI::DialogContent.new do %>Content<% end %><% end %>))

    assert_match(/data-ruby-ui--dialog-open-value/, output)
  end

  def test_close_button_has_dismiss_action
    assert_match(/data-action="#{descriptor("click->ruby-ui--dialog#dismiss")}"/, erb(DIALOG_WITH_CONTENT))
  end

  def test_trigger_has_open_action
    output = erb(%(<%= render RubyUI::Dialog.new do %><%= render RubyUI::DialogTrigger.new do %><%= render RubyUI::Button.new do %>Open<% end %><% end %><%= render RubyUI::DialogContent.new do %>Content<% end %><% end %>))

    assert_match(/data-action="#{descriptor("click->ruby-ui--dialog#open")}"/, output)
  end

  # 2.0 coerces the size (spec decision B); 1.6 silently dropped the class for "lg".
  def test_dialog_content_size_accepts_the_string_form
    assert_equal erb(%(<%= render RubyUI::DialogContent.new(size: :lg) do %>b<% end %>)),
      erb(%(<%= render RubyUI::DialogContent.new(size: "lg") do %>b<% end %>))
  end

  def test_dialog_content_refuses_an_unknown_size
    error = assert_raises(ArgumentError) { RubyUI::DialogContent.new(size: :huge) }

    assert_match(/:xs, :sm, :md, :lg, :xl, :full/, error.message)
  end
end
```

Run it against the still-Phlex components:

```bash
cd gem && bundle exec rake test N="/^RubyUI::DialogTest#/" 2>&1 | grep -E "runs,|Failure:|Error:" | head
```

Expected: `12 runs, … 2 failures` — the ten ported tests pass (phlex-rails renders the Phlex components from ERB), `test_dialog_content_size_accepts_the_string_form` fails (1.6 renders no size class for `"lg"`) and `test_dialog_content_refuses_an_unknown_size` fails (1.6 does not raise). Those two are the red tests for the migration.

- [ ] **Step 2: Drop the Phlex blocks from the dialog scenarios**

In `gem/test/golden/scenarios.rb`, replace the whole `Golden::Catalog.component "dialog" do … end` block (the one that begins with `scenario "default" do` / `RubyUI.Dialog do`) with:

```ruby
Golden::Catalog.component "dialog" do
  scenario "default"
  %i[sm md lg xl].each { |size| scenario "content_#{size}" }
  scenario "open"
end
```

```bash
bundle exec rake golden 2>&1 | grep -E "runs,"
```

Expected: `404 runs, … 0 failures, 0 errors, 0 skips` — six Phlex-lane tests gone, the six `__erb` tests still green against Phlex. This is the ruler standing on the fixtures alone before anything migrates.

- [ ] **Step 3: Write the eight classes and their sidecars**

`gem/lib/ruby_ui/dialog/dialog.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class Dialog < Component
    def initialize(open: false, **attrs)
      @open = open
      super(**attrs)
    end

    private

    def default_attrs
      {
        data: {
          controller: "ruby-ui--dialog",
          ruby_ui__dialog_open_value: @open
        }
      }
    end
  end
end
```

`gem/lib/ruby_ui/dialog/dialog.html.erb`:

```erb
<div <%= tag.attributes(component.attrs) %>><%= component.content %></div>
```

`gem/lib/ruby_ui/dialog/dialog_content.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DialogContent < Component
    SIZES = {
      xs: "max-w-sm",
      sm: "max-w-md",
      md: "max-w-lg",
      lg: "max-w-2xl",
      xl: "max-w-4xl",
      full: "max-w-full"
    }

    def initialize(size: :md, **attrs)
      @size = enum(size, SIZES, default: :md)
      super(**attrs)
    end

    private

    def default_attrs
      {
        data_ruby_ui__dialog_target: "dialog",
        data_action: "click->ruby-ui--dialog#backdropClick",
        class: [
          "fixed open:flex flex-col pointer-events-auto left-[50%] top-[50%] z-50 w-full max-h-screen overflow-y-auto translate-x-[-50%] translate-y-[-50%] gap-4 border bg-background p-6 shadow-lg duration-200 backdrop:bg-background/80 backdrop:backdrop-blur-sm open:animate-in open:fade-in-0 open:zoom-in-95 sm:rounded-lg md:w-full",
          SIZES[@size]
        ]
      }
    end
  end
end
```

`gem/lib/ruby_ui/dialog/dialog_content.html.erb` — the content, then the close button 1.6 appended after `yield`; attributes one per line inside the start tags, nothing between `>` and `<`:

```erb
<dialog <%= tag.attributes(component.attrs) %>><%= component.content %><button
  type="button"
  class="absolute end-4 top-4 rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:pointer-events-none"
  data-action="click->ruby-ui--dialog#dismiss"
><svg
  width="15"
  height="15"
  viewbox="0 0 15 15"
  fill="none"
  xmlns="http://www.w3.org/2000/svg"
  class="h-4 w-4"
><path
  d="M11.7816 4.03157C12.0062 3.80702 12.0062 3.44295 11.7816 3.2184C11.5571 2.99385 11.193 2.99385 10.9685 3.2184L7.50005 6.68682L4.03164 3.2184C3.80708 2.99385 3.44301 2.99385 3.21846 3.2184C2.99391 3.44295 2.99391 3.80702 3.21846 4.03157L6.68688 7.49999L3.21846 10.9684C2.99391 11.193 2.99391 11.557 3.21846 11.7816C3.44301 12.0061 3.80708 12.0061 4.03164 11.7816L7.50005 8.31316L10.9685 11.7816C11.193 12.0061 11.5571 12.0061 11.7816 11.7816C12.0062 11.557 12.0062 11.193 11.7816 10.9684L8.31322 7.49999L11.7816 4.03157Z"
  fill="currentColor"
  fill-rule="evenodd"
  clip-rule="evenodd"
></path></svg><span class="sr-only">Close</span></button></dialog>
```

`gem/lib/ruby_ui/dialog/dialog_description.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DialogDescription < Component
    private

    def default_attrs
      {
        class: "text-sm text-muted-foreground"
      }
    end
  end
end
```

`gem/lib/ruby_ui/dialog/dialog_description.html.erb`:

```erb
<p <%= tag.attributes(component.attrs) %>><%= component.content %></p>
```

`gem/lib/ruby_ui/dialog/dialog_footer.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DialogFooter < Component
    private

    def default_attrs
      {
        class: "flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2 gap-y-2 sm:gap-y-0 rtl:space-x-reverse"
      }
    end
  end
end
```

`gem/lib/ruby_ui/dialog/dialog_footer.html.erb`:

```erb
<div <%= tag.attributes(component.attrs) %>><%= component.content %></div>
```

`gem/lib/ruby_ui/dialog/dialog_header.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DialogHeader < Component
    private

    def default_attrs
      {
        class: "flex flex-col space-y-1.5 text-center sm:text-left rtl:sm:text-right"
      }
    end
  end
end
```

`gem/lib/ruby_ui/dialog/dialog_header.html.erb`:

```erb
<div <%= tag.attributes(component.attrs) %>><%= component.content %></div>
```

`gem/lib/ruby_ui/dialog/dialog_middle.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DialogMiddle < Component
    private

    def default_attrs
      {
        class: "py-4"
      }
    end
  end
end
```

`gem/lib/ruby_ui/dialog/dialog_middle.html.erb`:

```erb
<div <%= tag.attributes(component.attrs) %>><%= component.content %></div>
```

`gem/lib/ruby_ui/dialog/dialog_title.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DialogTitle < Component
    private

    def default_attrs
      {
        class: "text-lg font-semibold leading-none tracking-tight"
      }
    end
  end
end
```

`gem/lib/ruby_ui/dialog/dialog_title.html.erb`:

```erb
<h3 <%= tag.attributes(component.attrs) %>><%= component.content %></h3>
```

`gem/lib/ruby_ui/dialog/dialog_trigger.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DialogTrigger < Component
    private

    def default_attrs
      {
        data: {
          action: "click->ruby-ui--dialog#open"
        },
        class: "inline-block"
      }
    end
  end
end
```

`gem/lib/ruby_ui/dialog/dialog_trigger.html.erb`:

```erb
<div <%= tag.attributes(component.attrs) %>><%= component.content %></div>
```

Every sidecar above ends with exactly one newline. Check that with:

```bash
for f in lib/ruby_ui/dialog/*.html.erb; do printf "%s %s\n" "$(tail -c1 "$f" | xxd -p)" "$f"; done
```

Expected: `0a` before every path.

- [ ] **Step 4: Run the dialog scenarios, the dialog tests, then everything**

```bash
bundle exec rake test N=/test_dialog__/ 2>&1 | grep -E "runs,|Failure:|Error:"
```

Expected: `6 runs, … 0 failures, 0 errors, 0 skips` — the six ERB-lane scenarios, canonical and strict, against the frozen snapshots, now rendering the 2.0 classes. A failure here follows "When a golden test fails".

```bash
bundle exec rake test N="/^RubyUI::DialogTest#/" 2>&1 | grep -E "runs,"
```

Expected: `12 runs, … 0 failures` — the two red tests are green.

```bash
bundle exec rake golden 2>&1 | grep -E "runs,"; bundle exec rake test 2>&1 | grep -E "runs,"; bundle exec standardrb
```

Expected: `404 runs`, `781 runs`, `426 files inspected, no offenses detected`. `test_every_component_class_is_rendered_by_a_scenario` still passes: the eight classes are `Component` subclasses, recorded on `render_in` by the harness, reached through the ERB lane.

- [ ] **Step 5: Rebuild the registry, run the guards, commit**

```bash
cd ../mcp && bundle exec exe/ruby-ui-mcp-build && cd .. && git diff --stat mcp/data/registry.json
```

Expected: one file changed — the dialog entry now embeds sixteen files (eight `.rb`, eight `.html.erb`, the controller unchanged).

```bash
git status --porcelain gem/test/golden/snapshots gem/test/golden/strict gem/test/golden/views && git diff --quiet v2/fixtures -- 'gem/lib/ruby_ui/**/*.js' && echo clean
```

Expected: `clean`. Then:

```bash
git add gem/lib/ruby_ui/dialog gem/test/ruby_ui/dialog_test.rb gem/test/golden/scenarios.rb mcp/data/registry.json
git commit -m "[Feature] RubyUI 2.0: Dialog — the first components on the 2.0 layer

Eight classes from Phlex to RubyUI::Component with a sidecar each. The
six golden scenarios render identically to the frozen 1.6 snapshots in
both forms through their ERB fixtures; their Phlex blocks are gone, since
RubyUI.Dialog no longer exists (a Kit defines no method for a class that
is not Phlex::SGML). DialogContent's size goes through enum, so size:
\"lg\" selects max-w-2xl where 1.6 dropped the class; an unknown size
raises naming the six. The controller is unedited.

The DialogContent sidecar is the first with static markup after the
content: attributes one per line inside the start tags, nothing between
a > and the next < (decision 12).

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

## Task 4: Toggle, ToggleGroup, ToggleGroupItem and ThemeToggle

**Files:**
- Modify: `gem/lib/ruby_ui/toggle/toggle.rb`, `gem/lib/ruby_ui/toggle_group/toggle_group.rb`, `toggle_group_item.rb`, `gem/lib/ruby_ui/theme_toggle/theme_toggle.rb` (whole files given)
- Create: `gem/lib/ruby_ui/toggle/toggle.html.erb`, `gem/lib/ruby_ui/toggle_group/toggle_group.html.erb`, `toggle_group_item.html.erb`, `gem/lib/ruby_ui/theme_toggle/theme_toggle.html.erb`
- Modify: `gem/test/ruby_ui/toggle_test.rb` (11 tests), `gem/test/ruby_ui/toggle_group_test.rb` (13 tests), `gem/test/ruby_ui/theme_toggle_test.rb` (3 tests) — whole files given, every existing test kept
- Modify: `gem/test/golden/scenarios.rb` — the `"theme_toggle"`, `"toggle"` and `"toggle_group"` blocks
- Untouched: `toggle_controller.js`, `toggle_group_controller.js`
- Rebuild: `mcp/data/registry.json`

**Interfaces:**
- Consumes: `Component#mixed_attrs` (ThemeToggle forwards it), `Component#helpers` (ToggleGroup renders items from a method), `Component#enum`, `Attributes.mix` and `.flat` (Toggle's wrapper).
- Produces: `RubyUI::Toggle.new(pressed:, name:, value:, unpressed_value:, variant:, size:, disabled:, wrapper:, **attrs)` with public `name`, `wrapper_attrs`, `hidden_input_attrs`; `Toggle.classes_for(variant:, size:)` unchanged; `RubyUI::ToggleGroup.new(type:, name:, value:, variant:, size:, disabled:, spacing:, orientation:, **attrs)` with public `item_context`, `ToggleGroupItem(**kwargs, &block)`, `hidden_inputs → Array<[name, value]>` and `hidden_input_attrs(name, value)`; `RubyUI::ToggleGroupItem < Toggle`, `new(value:, group_context:, variant: nil, size: nil, **attrs)`; `RubyUI::ThemeToggle.new(**attrs)`. `variant` and `size` accept Strings; an unknown value raises. The `render X.new do |group|` form stays the way to write a ToggleGroup (spec §6.2.1's known limitation).

- [ ] **Step 1: Port the three test files, with seven new tests**

Replace `gem/test/ruby_ui/toggle_test.rb` (11 existing tests kept; the controller-action assertion goes through `descriptor` because the wrapper's attributes are serialized by `tag.attributes`; three tests added at the end):

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::ToggleTest < ComponentTest
  def test_renders_button_unpressed_by_default
    output = erb(%(<%= render RubyUI::Toggle.new do %>Bold<% end %>))
    assert_match(/<button[^>]*type="button"/, output)
    assert_match(/aria-pressed="false"/, output)
    assert_match(/data-state="off"/, output)
    assert_match(/Bold/, output)
  end

  def test_renders_pressed_when_pressed_true
    output = erb(%(<%= render RubyUI::Toggle.new(pressed: true) do %>Bold<% end %>))
    assert_match(/aria-pressed="true"/, output)
    assert_match(/data-state="on"/, output)
  end

  def test_renders_hidden_input_when_name_present
    output = erb(%(<%= render RubyUI::Toggle.new(name: "bold", value: "1") do %>Bold<% end %>))
    assert_match(/<input[^>]*type="hidden"[^>]*name="bold"/, output)
    assert_match(/value=""/, output)
  end

  def test_hidden_input_value_reflects_pressed
    output = erb(%(<%= render RubyUI::Toggle.new(name: "bold", value: "1", pressed: true) do %>Bold<% end %>))
    assert_match(/<input[^>]*name="bold"[^>]*value="1"/, output)
  end

  def test_no_hidden_input_when_name_absent
    output = erb(%(<%= render RubyUI::Toggle.new do %>Bold<% end %>))
    refute_match(/type="hidden"/, output)
  end

  def test_outline_variant_applies_border_class
    output = erb(%(<%= render RubyUI::Toggle.new(variant: :outline) do %>x<% end %>))
    assert_match(/border-input/, output)
  end

  def test_size_sm_applies_h8
    output = erb(%(<%= render RubyUI::Toggle.new(size: :sm) do %>x<% end %>))
    assert_match(/h-8/, output)
  end

  def test_size_lg_applies_h10
    output = erb(%(<%= render RubyUI::Toggle.new(size: :lg) do %>x<% end %>))
    assert_match(/h-10/, output)
  end

  def test_disabled_sets_attribute
    output = erb(%(<%= render RubyUI::Toggle.new(disabled: true) do %>x<% end %>))
    assert_match(/<button[^>]*disabled/, output)
  end

  def test_includes_stimulus_controller_and_action
    output = erb(%(<%= render RubyUI::Toggle.new do %>x<% end %>))
    assert_match(/data-controller="[^"]*ruby-ui--toggle/, output)
    assert_match(/data-action="[^"]*#{descriptor("click->ruby-ui--toggle#toggle")}/, output)
  end

  def test_includes_stimulus_values
    output = erb(%(<%= render RubyUI::Toggle.new(value: "x", unpressed_value: "y", pressed: true) do %>x<% end %>))
    assert_match(/data-ruby-ui--toggle-pressed-value="true"/, output)
    assert_match(/data-ruby-ui--toggle-value-value="x"/, output)
    assert_match(/data-ruby-ui--toggle-unpressed-value-value="y"/, output)
  end

  # 2.0: variant and size are coerced (spec decision B).
  def test_variant_and_size_accept_the_string_form
    assert_equal erb(%(<%= render RubyUI::Toggle.new(variant: :outline, size: :lg) do %>B<% end %>)),
      erb(%(<%= render RubyUI::Toggle.new(variant: "outline", size: "lg") do %>B<% end %>))
  end

  def test_an_unknown_variant_names_the_allowed_ones
    error = assert_raises(ArgumentError) { RubyUI::Toggle.new(variant: :ghost) }
    assert_match(/:default, :outline/, error.message)
  end

  def test_the_hidden_input_carries_the_unpressed_value_when_not_pressed
    output = erb(%(<%= render RubyUI::Toggle.new(name: "bold", value: "1", unpressed_value: "0") do %>B<% end %>))
    assert_match(/<input[^>]*type="hidden"[^>]*name="bold"[^>]*value="0"/, output)
  end
end
```

Replace `gem/test/ruby_ui/toggle_group_test.rb` (13 existing tests kept — `test_invalid_orientation_raises` asserts on the constructor, because an exception raised inside a rendering template reaches the test wrapped in `ActionView::Template::Error`; four tests added at the end):

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::ToggleGroupTest < ComponentTest
  LEFT_RIGHT = %(<%= g.ToggleGroupItem(value: "left") { "L" } %><%= g.ToggleGroupItem(value: "right") { "R" } %>)
  BOLD_ITALIC = %(<%= g.ToggleGroupItem(value: "bold") { "B" } %><%= g.ToggleGroupItem(value: "italic") { "I" } %>)
  A_B = %(<%= g.ToggleGroupItem(value: "a") { "A" } %><%= g.ToggleGroupItem(value: "b") { "B" } %>)
  ONLY_A = %(<%= g.ToggleGroupItem(value: "a") { "A" } %>)

  def test_single_uses_radiogroup_role
    output = group(%(type: :single, name: "align"), LEFT_RIGHT)
    assert_match(/role="radiogroup"/, output)
    assert_match(/role="radio"/, output)
  end

  def test_multiple_uses_group_role_with_aria_pressed
    output = group(%(type: :multiple, name: "fmt"), BOLD_ITALIC)
    assert_match(/role="group"/, output)
    assert_match(/aria-pressed=/, output)
    refute_match(/role="radio"/, output)
  end

  def test_single_initial_value_sets_pressed_item
    output = group(%(type: :single, name: "align", value: "right"), LEFT_RIGHT)
    # right item is pressed — assert both attributes appear (they are on the same button element)
    assert_match(/data-value="right"/, output)
    assert_match(/aria-checked="true"/, output)
    assert_match(/data-state="on"[^>]*data-value="right"|data-value="right"[^>]*data-state="on"/, output)
    # exactly one hidden input with selected value
    assert_match(/<input[^>]*type="hidden"[^>]*name="align"[^>]*value="right"/, output)
  end

  def test_multiple_initial_value_array_pressed
    output = group(%(type: :multiple, name: "fmt", value: %w[bold italic]), %(#{BOLD_ITALIC}<%= g.ToggleGroupItem(value: "underline") { "U" } %>))
    assert_match(/<input[^>]*name="fmt\[\]"[^>]*value="bold"/, output)
    assert_match(/<input[^>]*name="fmt\[\]"[^>]*value="italic"/, output)
    refute_match(/<input[^>]*name="fmt\[\]"[^>]*value="underline"/, output)
  end

  def test_single_roving_tabindex
    output = group(%(type: :single, name: "align", value: "left"), LEFT_RIGHT)
    assert_equal 1, output.scan('tabindex="0"').size
    assert_match(/tabindex="-1"/, output)
  end

  def test_disabled_group_disables_all_items
    output = group(%(type: :multiple, name: "fmt", disabled: true), BOLD_ITALIC)
    assert_equal 2, output.scan(/<button[^>]*disabled/).size
  end

  def test_group_controller_attached
    output = group(%(type: :single, name: "align"), %(<%= g.ToggleGroupItem(value: "left") { "L" } %>))
    assert_match(/data-controller="[^"]*ruby-ui--toggle-group/, output)
    assert_match(/data-ruby-ui--toggle-group-type-value="single"/, output)
    assert_match(/data-ruby-ui--toggle-group-name-value="align"/, output)
  end

  def test_group_items_dont_have_standalone_toggle_controller
    output = group(%(type: :single, name: "align"), %(<%= g.ToggleGroupItem(value: "left") { "L" } %>))
    # group controller present on wrapper, but item buttons should not be tagged with single-toggle controller
    refute_match(/<button[^>]*data-controller="[^"]*ruby-ui--toggle"/, output)
  end

  def test_joined_items_have_first_last_rounded
    output = group(%(type: :single, name: "x"), A_B)
    assert_match(/rounded-none/, output)
    assert_match(/first-of-type:rounded-l-md/, output)
    assert_match(/last-of-type:rounded-r-md/, output)
  end

  def test_spacing_adds_gap_class
    output = group(%(type: :single, name: "x", spacing: 2), A_B)
    assert_match(/gap-2/, output)
    refute_match(/rounded-none/, output)
  end

  def test_vertical_orientation
    output = group(%(type: :single, name: "x", orientation: :vertical), A_B)
    assert_match(/flex-col/, output)
    assert_match(/first-of-type:rounded-t-md/, output)
  end

  def test_outline_joined_adds_shadow_xs
    output = group(%(type: :single, name: "x", variant: :outline), ONLY_A)
    assert_match(/shadow-xs/, output)
    assert_match(/border-l-0/, output)
    assert_match(/first-of-type:border-l/, output)
  end

  def test_invalid_orientation_raises
    assert_raises(ArgumentError) { RubyUI::ToggleGroup.new(type: :single, name: "x", orientation: :diagonal) }
  end

  # 2.0: every enumerated argument accepts its String form (spec decision B).
  def test_variant_and_size_accept_the_string_form_through_the_items
    assert_equal group(%(variant: :outline, size: :sm), ONLY_A), group(%(variant: "outline", size: "sm"), ONLY_A)
  end

  def test_type_accepts_the_string_form
    assert_equal group(%(type: :multiple, name: "fmt", value: %w[bold]), BOLD_ITALIC),
      group(%(type: "multiple", name: "fmt", value: %w[bold]), BOLD_ITALIC)
  end

  def test_orientation_accepts_the_string_form
    assert_equal group(%(type: :single, name: "x", orientation: :vertical), A_B),
      group(%(type: :single, name: "x", orientation: "vertical"), A_B)
  end

  def test_an_items_variant_and_size_override_accept_the_string_form
    symbols = group(%(type: :single, name: "x"), %(<%= g.ToggleGroupItem(value: "a", variant: :outline, size: :lg) { "A" } %>))
    strings = group(%(type: :single, name: "x"), %(<%= g.ToggleGroupItem(value: "a", variant: "outline", size: "lg") { "A" } %>))
    assert_equal symbols, strings
    assert_match(/h-10/, strings)
  end

  private

  # A group with the given constructor arguments around the given items.
  def group(args, items)
    erb(%(<%= render RubyUI::ToggleGroup.new(#{args}) do |g| %>#{items}<% end %>))
  end
end
```

Replace `gem/test/ruby_ui/theme_toggle_test.rb` with:

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::ThemeToggleTest < ComponentTest
  def test_renders_as_toggle_button
    output = erb(%(<%= render RubyUI::ThemeToggle.new do %>icon<% end %>))
    assert_match(/<button[^>]*type="button"/, output)
    assert_match(/aria-pressed=/, output)
  end

  def test_wires_theme_toggle_controller
    output = erb(%(<%= render RubyUI::ThemeToggle.new do %>icon<% end %>))
    assert_match(/data-controller="[^"]*ruby-ui--theme-toggle/, output)
    assert_match(/data-controller="[^"]*ruby-ui--toggle/, output)
    assert_match(/#{descriptor("ruby-ui--toggle:change->ruby-ui--theme-toggle#apply")}/, output)
  end

  def test_block_content_rendered
    output = erb(%(<%= render RubyUI::ThemeToggle.new do %>SUN_AND_MOON<% end %>))
    assert_match(/SUN_AND_MOON/, output)
  end
end
```

```bash
cd gem && bundle exec rake test N="/^RubyUI::(ToggleTest|ToggleGroupTest|ThemeToggleTest)#/" 2>&1 | grep -E "runs,|Failure:|Error:" | head
```

Expected: `34 runs, 1 failures` — the one failure is `test_an_unknown_variant_names_the_allowed_ones` (1.6 falls back to the default silently); that is the red test for the migration. The other 33 pass against the still-Phlex components — the 27 ports through phlex-rails, the String-form tests because 1.6 already calls `.to_sym` everywhere, the hidden-input test because the markup does not change — and pin behaviour the migration must keep.

- [ ] **Step 2: Drop the Phlex blocks from the three families' scenarios**

In `gem/test/golden/scenarios.rb`, replace the `"theme_toggle"`, `"toggle"` and `"toggle_group"` component blocks with:

```ruby
Golden::Catalog.component "theme_toggle" do
  scenario "default"
end
```

```ruby
Golden::Catalog.component "toggle" do
  scenario "default"
  scenario "pressed_outline_with_name"
  scenario "disabled_small"
end
```

```ruby
Golden::Catalog.component "toggle_group" do
  scenario "single"
  scenario "multiple_outline_spaced_vertical"
  scenario "disabled"
end
```

(The blocks stay where they are in the file — the catalog is ordered alphabetically by component and `theme_toggle` sits before `toggle`.)

```bash
bundle exec rake golden 2>&1 | grep -E "runs,"
```

Expected: `397 runs, … 0 failures, 0 errors, 0 skips`.

- [ ] **Step 3: Write the four classes and their sidecars**

`gem/lib/ruby_ui/toggle/toggle.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class Toggle < Component
    BASE_CLASSES = [
      "inline-flex items-center justify-center gap-2 rounded-md text-sm font-medium whitespace-nowrap",
      "transition-[color,box-shadow] outline-none",
      "hover:bg-muted hover:text-muted-foreground",
      "focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50",
      "disabled:pointer-events-none disabled:opacity-50",
      "aria-invalid:border-destructive aria-invalid:ring-destructive/20",
      "data-[state=on]:bg-accent data-[state=on]:text-accent-foreground",
      "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
    ].freeze

    VARIANT_CLASSES = {
      default: "bg-transparent",
      outline: "border border-input bg-transparent shadow-xs hover:bg-accent hover:text-accent-foreground"
    }.freeze

    SIZE_CLASSES = {
      sm: "h-8 min-w-8 px-1.5",
      default: "h-9 min-w-9 px-2",
      lg: "h-10 min-w-10 px-2.5"
    }.freeze

    def self.classes_for(variant:, size:)
      [BASE_CLASSES, VARIANT_CLASSES.fetch(variant, VARIANT_CLASSES[:default]), SIZE_CLASSES.fetch(size, SIZE_CLASSES[:default])]
    end

    attr_reader :name

    def initialize(
      pressed: false,
      name: nil,
      value: "1",
      unpressed_value: nil,
      variant: :default,
      size: :default,
      disabled: false,
      wrapper: {},
      **attrs
    )
      @pressed = pressed
      @name = name
      @value = value
      @unpressed_value = unpressed_value
      @variant = enum(variant, VARIANT_CLASSES, default: :default)
      @size = enum(size, SIZE_CLASSES, default: :default)
      @disabled = disabled
      @wrapper = wrapper
      super(**attrs)
    end

    # The wrapper's attributes, mixed as 1.6 did — no Tailwind merge on them.
    def wrapper_attrs
      Attributes.flat(Attributes.mix(wrapper_default_attrs, @wrapper))
    end

    def hidden_input_attrs
      Attributes.flat(
        type: "hidden",
        name: @name,
        value: @pressed ? @value : @unpressed_value.to_s,
        data: {"ruby-ui--toggle-target": "input"}
      )
    end

    private

    def wrapper_default_attrs
      {
        class: "contents",
        data: {
          controller: "ruby-ui--toggle",
          action: "click->ruby-ui--toggle#toggle",
          "ruby-ui--toggle-pressed-value": @pressed.to_s,
          "ruby-ui--toggle-value-value": @value.to_s,
          "ruby-ui--toggle-unpressed-value-value": @unpressed_value.to_s
        }
      }
    end

    def default_attrs
      base = {type: "button"}
      base[:disabled] = true if @disabled
      base.merge(
        aria: {pressed: @pressed.to_s},
        data: {
          state: @pressed ? "on" : "off",
          "ruby-ui--toggle-target": "button"
        },
        class: self.class.classes_for(variant: @variant, size: @size)
      )
    end
  end
end
```

`gem/lib/ruby_ui/toggle/toggle.html.erb`:

```erb
<span <%= tag.attributes(component.wrapper_attrs) %>><button <%= tag.attributes(component.attrs) %>><%= component.content %></button><% if component.name %><input <%= tag.attributes(component.hidden_input_attrs) %>><% end %></span>
```

`gem/lib/ruby_ui/toggle_group/toggle_group.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class ToggleGroup < Component
    SPACING_GAP = {0 => nil, 1 => "gap-1", 2 => "gap-2", 3 => "gap-3", 4 => "gap-4"}.freeze
    VALID_TYPES = [:single, :multiple].freeze
    VALID_ORIENTATIONS = [:horizontal, :vertical].freeze

    def initialize(
      type: :single,
      name: nil,
      value: nil,
      variant: :default,
      size: :default,
      disabled: false,
      spacing: 0,
      orientation: :horizontal,
      **attrs
    )
      @type = type.to_sym
      raise ArgumentError, "type must be :single or :multiple" unless VALID_TYPES.include?(@type)

      @orientation = orientation.to_sym
      raise ArgumentError, "orientation must be :horizontal or :vertical" unless VALID_ORIENTATIONS.include?(@orientation)

      raise ArgumentError, "spacing must be an Integer 0..4" unless spacing.is_a?(Integer) && (0..4).cover?(spacing)

      @name = name
      @value = value
      @variant = enum(variant, Toggle::VARIANT_CLASSES, default: :default)
      @size = enum(size, Toggle::SIZE_CLASSES, default: :default)
      @disabled = disabled
      @spacing = spacing
      super(**attrs)
    end

    def item_context
      {
        type: @type,
        variant: @variant,
        size: @size,
        disabled: @disabled,
        selected_values: selected_values,
        spacing: @spacing,
        orientation: @orientation
      }
    end

    # Called on the block argument — `render ToggleGroup.new do |group| … group.ToggleGroupItem(…) { "L" } end` —
    # from inside the block render_in is capturing, so the view context is there.
    def ToggleGroupItem(**kwargs, &block)
      helpers.render(RubyUI::ToggleGroupItem.new(group_context: item_context, **kwargs), &block)
    end

    # [name, value] for each hidden input; none without a name. The single
    # name is passed as given — a Symbol dasherizes in Attributes.flat, as it
    # did in Phlex; the multiple names are interpolated Strings, as in 1.6.
    def hidden_inputs
      return [] unless @name

      if @type == :single
        [[@name, selected_values.first.to_s]]
      else
        selected_values.map { |v| ["#{@name}[]", v] }
      end
    end

    def hidden_input_attrs(name, value)
      Attributes.flat(type: "hidden", name: name, value: value, data: {"ruby-ui--toggle-group-target": "input"})
    end

    private

    def selected_values
      case @type
      when :single then @value.nil? ? [] : [@value.to_s]
      when :multiple then Array(@value).map(&:to_s)
      end
    end

    def default_attrs
      {
        role: (@type == :single) ? "radiogroup" : "group",
        data: {
          controller: "ruby-ui--toggle-group",
          "ruby-ui--toggle-group-type-value": @type.to_s,
          "ruby-ui--toggle-group-name-value": @name.to_s,
          orientation: @orientation.to_s,
          spacing: @spacing.to_s
        },
        class: container_classes
      }
    end

    def container_classes
      base = if @orientation == :vertical
        "flex w-fit flex-col items-stretch rounded-md"
      else
        "flex w-fit items-center rounded-md"
      end

      [
        base,
        SPACING_GAP[@spacing],
        (@spacing == 0 && @variant == :outline) ? "shadow-xs" : nil
      ].compact
    end
  end
end
```

`gem/lib/ruby_ui/toggle_group/toggle_group.html.erb`:

```erb
<div <%= tag.attributes(component.attrs) %>><%= component.content %><% component.hidden_inputs.each do |name, value| %><input <%= tag.attributes(component.hidden_input_attrs(name, value)) %>><% end %></div>
```

`gem/lib/ruby_ui/toggle_group/toggle_group_item.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class ToggleGroupItem < Toggle
    JOIN_BASE = "w-auto min-w-0 shrink-0 px-3 focus:z-10 focus-visible:z-10"

    def initialize(value:, group_context:, variant: nil, size: nil, **attrs)
      @item_value = value.to_s
      @group_context = group_context

      pressed = group_context[:selected_values].include?(@item_value)
      super(
        pressed: pressed,
        name: nil,
        value: @item_value,
        variant: variant || group_context[:variant],
        size: size || group_context[:size],
        disabled: group_context[:disabled],
        **attrs
      )
    end

    private

    def default_attrs
      attrs = {type: "button"}
      attrs[:disabled] = true if @disabled
      attrs[:data] = {
        state: @pressed ? "on" : "off",
        value: @item_value,
        "ruby-ui--toggle-group-target": "item",
        action: "click->ruby-ui--toggle-group#select keydown->ruby-ui--toggle-group#navigate"
      }
      attrs[:class] = [Toggle.classes_for(variant: @variant, size: @size), join_classes]

      if @group_context[:type] == :single
        attrs[:role] = "radio"
        attrs[:aria] = {checked: @pressed.to_s}
        attrs[:tabindex] = @pressed ? "0" : "-1"
      else
        attrs[:aria] = {pressed: @pressed.to_s}
        attrs[:tabindex] = "0"
      end

      attrs
    end

    def join_classes
      classes = [JOIN_BASE]
      return classes unless @group_context[:spacing] == 0

      classes << "rounded-none shadow-none"
      if @group_context[:orientation] == :vertical
        classes << "first-of-type:rounded-t-md last-of-type:rounded-b-md"
        classes << "border-t-0 first-of-type:border-t" if @group_context[:variant] == :outline
      else
        classes << "first-of-type:rounded-l-md last-of-type:rounded-r-md"
        classes << "border-l-0 first-of-type:border-l" if @group_context[:variant] == :outline
      end
      classes
    end
  end
end
```

`gem/lib/ruby_ui/toggle_group/toggle_group_item.html.erb` — its own sidecar, so the inherited `toggle.html.erb` (wrapper and hidden input) is not used (decision 13):

```erb
<button <%= tag.attributes(component.attrs) %>><%= component.content %></button>
```

`gem/lib/ruby_ui/theme_toggle/theme_toggle.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class ThemeToggle < Component
  end
end
```

`gem/lib/ruby_ui/theme_toggle/theme_toggle.html.erb` — 1.6 spread the caller's attributes after the Toggle's own, so a caller's key wins; `**component.mixed_attrs` last keeps that:

```erb
<%= render RubyUI::Toggle.new(variant: :default, size: :default, aria: {label: "Toggle theme"}, wrapper: {data: {controller: "ruby-ui--theme-toggle", action: "ruby-ui--toggle:change->ruby-ui--theme-toggle#apply"}}, **component.mixed_attrs) do %><%= component.content %><% end %>
```

Check the trailing newlines as in Task 3:

```bash
for f in lib/ruby_ui/toggle/*.html.erb lib/ruby_ui/toggle_group/*.html.erb lib/ruby_ui/theme_toggle/*.html.erb; do printf "%s %s\n" "$(tail -c1 "$f" | xxd -p)" "$f"; done
```

- [ ] **Step 4: Run the three families' scenarios, their tests, then everything**

```bash
bundle exec rake test N="/test_(toggle|toggle_group|theme_toggle)__/" 2>&1 | grep -E "runs,|Failure:|Error:"
```

Expected: `7 runs, … 0 failures, 0 errors, 0 skips`.

```bash
bundle exec rake test N="/^RubyUI::(ToggleTest|ToggleGroupTest|ThemeToggleTest)#/" 2>&1 | grep -E "runs,"
```

Expected: `34 runs, … 0 failures`.

```bash
bundle exec rake golden 2>&1 | grep -E "runs,"; bundle exec rake test 2>&1 | grep -E "runs,"; bundle exec standardrb
```

Expected: `397 runs`, `781 runs`, `426 files inspected, no offenses detected`.

- [ ] **Step 5: Rebuild the registry, run the guards, commit**

```bash
cd ../mcp && bundle exec exe/ruby-ui-mcp-build && cd .. && git diff --stat mcp/data/registry.json && git status --porcelain gem/test/golden/snapshots gem/test/golden/strict gem/test/golden/views && git diff --quiet v2/fixtures -- 'gem/lib/ruby_ui/**/*.js' && echo clean
```

Expected: the registry diff, then `clean`.

```bash
git add gem/lib/ruby_ui/toggle gem/lib/ruby_ui/toggle_group gem/lib/ruby_ui/theme_toggle gem/test/ruby_ui/toggle_test.rb gem/test/ruby_ui/toggle_group_test.rb gem/test/ruby_ui/theme_toggle_test.rb gem/test/golden/scenarios.rb mcp/data/registry.json
git commit -m "[Feature] RubyUI 2.0: Toggle, ToggleGroup, ToggleGroupItem and ThemeToggle

The block-parameter family. ToggleGroup's yield(self) is render_in's
capture with the component as the block argument, and
group.ToggleGroupItem renders through helpers.render from inside that
block. ToggleGroupItem < Toggle keeps its own sidecar (decision 13);
Toggle's wrapper is mixed without a Tailwind merge, as 1.6 did.

ThemeToggle is here because it rendered RubyUI.Toggle through the Kit,
which stops existing when Toggle migrates, and a Phlex component can
render a 2.0 one only with a view context the golden Phlex lane does
not have (decision 14). One class, one sidecar, one scenario.

variant and size go through enum in Toggle and ToggleGroup: a String
selects the same entry; an unknown value raises where 1.6 fell back to
the default silently. The 27 existing unit tests are ported, none
deleted; seven scenarios identical in both forms; the two controllers
unedited.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

## Task 5: Select

**Files:**
- Modify: `gem/lib/ruby_ui/select/select.rb`, `select_content.rb`, `select_group.rb`, `select_input.rb`, `select_item.rb`, `select_label.rb`, `select_trigger.rb`, `select_value.rb` (whole files given)
- Create: the eight sidecars beside them
- Modify: `gem/test/ruby_ui/select_test.rb` (whole file given)
- Modify: `gem/test/golden/scenarios.rb` — the `"select"` block
- Untouched: `select_controller.js`, `select_item_controller.js`, `select_docs.rb`
- Rebuild: `mcp/data/registry.json`

**Interfaces:**
- Consumes: `Component` (Task 2); `SecureRandom.hex(4)` in `SelectContent#initialize`, which the golden harness pins to `content00000001` — the fixture `select/default` must keep rendering that id.
- Produces: `RubyUI::Select.new(**attrs)`, `SelectContent.new(**attrs)` (mints its `id`), `SelectGroup.new(**attrs)`, `SelectInput.new(**attrs)`, `SelectItem.new(value: nil, **attrs)`, `SelectLabel.new(**attrs)`, `SelectTrigger.new(**attrs)`, `SelectValue.new(placeholder: nil, **attrs)` with public `placeholder` and `value` — the block's content, or the placeholder when the content is nil or empty; whitespace-only content is content, as Phlex rendered it (measured: probe 25).

- [ ] **Step 1: Port `select_test.rb`**

Replace the file with:

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::SelectTest < ComponentTest
  def test_render_with_all_items
    output = erb(<<~ERB)
      <%= render RubyUI::Select.new do %><%= render RubyUI::SelectInput.new(name: "NAME") %><%= render RubyUI::SelectTrigger.new do %><%= render RubyUI::SelectValue.new(placeholder: "Placeholder") %><% end %><%= render RubyUI::SelectContent.new(outlet_id: "1") do %><%= render RubyUI::SelectGroup.new do %><% [["John Doe", 1], ["Jane Doe", 2], ["Sam Smith", 3]].each do |name, id| %><%= render RubyUI::SelectItem.new(value: id) do %><%= name %><% end %><% end %><% end %><% end %><% end %>
    ERB

    assert_match(/John/, output)
    assert_match('name="NAME"', output)
  end

  def test_select_value_renders_placeholder_when_block_returns_nil
    output = erb(%(<%= render(RubyUI::SelectValue.new(placeholder: "Placeholder")) { nil } %>))

    assert_match(/Placeholder/, output)
  end

  # Phlex wrote the placeholder only when the block emitted nothing; a
  # whitespace-only block is content (probe 25).
  def test_select_value_renders_placeholder_when_block_is_empty
    output = erb(%(<%= render RubyUI::SelectValue.new(placeholder: "Placeholder") do %><% end %>))

    assert_match(/>Placeholder</, output)
  end

  def test_select_value_keeps_whitespace_only_content
    output = erb(%(<%= render RubyUI::SelectValue.new(placeholder: "Placeholder") do %> <% end %>))

    assert_match(/> </, output)
    refute_match(/Placeholder/, output)
  end

  def test_select_value_renders_its_content_over_the_placeholder
    output = erb(%(<%= render RubyUI::SelectValue.new(placeholder: "Placeholder") do %>Apple<% end %>))

    assert_match(/>Apple</, output)
    refute_match(/Placeholder/, output)
  end

  # `hidden` lands a frame after the animation ends; without a forwards fill mode that frame flashes.
  def test_content_holds_the_last_frame_of_the_exit_animation
    output = erb(%(<%= render RubyUI::SelectContent.new do %>options<% end %>))

    assert_match(/data-\[state=closed\]:fill-mode-forwards/, output)
  end
end
```

```bash
cd gem && bundle exec rake test N="/^RubyUI::SelectTest#/" 2>&1 | grep -E "runs,"
```

Expected: `6 runs, … 0 failures` against the Phlex components — the three new content tests pass against 1.6 too (they pin its behaviour: an empty block gives the placeholder, a whitespace-only one does not), so this task has no red test.

- [ ] **Step 2: Drop the Phlex blocks from the select scenarios**

Replace the `"select"` component block in `gem/test/golden/scenarios.rb` with:

```ruby
Golden::Catalog.component "select" do
  scenario "default"
  scenario "value_falls_back_to_placeholder"
end
```

```bash
bundle exec rake golden 2>&1 | grep -E "runs,"
```

Expected: `395 runs, … 0 failures, 0 errors, 0 skips`.

- [ ] **Step 3: Write the eight classes and their sidecars**

`gem/lib/ruby_ui/select/select.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class Select < Component
    private

    def default_attrs
      {
        data: {
          controller: "ruby-ui--select",
          ruby_ui__select_open_value: "false",
          action: "click@window->ruby-ui--select#clickOutside",
          ruby_ui__select_ruby_ui__select_item_outlet: ".item"
        },
        class: "group/select w-full relative"
      }
    end
  end
end
```

`gem/lib/ruby_ui/select/select.html.erb`:

```erb
<div <%= tag.attributes(component.attrs) %>><%= component.content %></div>
```

`gem/lib/ruby_ui/select/select_content.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class SelectContent < Component
    def initialize(**attrs)
      @id = "content#{SecureRandom.hex(4)}"
      super
    end

    private

    def default_attrs
      {
        id: @id,
        role: "listbox",
        tabindex: "-1",
        data: {
          ruby_ui__select_target: "content"
        },
        class: "hidden w-full absolute top-0 left-0 z-50"
      }
    end
  end
end
```

`gem/lib/ruby_ui/select/select_content.html.erb`:

```erb
<div <%= tag.attributes(component.attrs) %>><div
  class="max-h-96 w-full text-wrap overflow-auto rounded-md border bg-background p-1 text-foreground shadow-md data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[state=closed]:fill-mode-forwards slide-in-from-top-2"
  data-state="closed"
  data-ruby-ui--select-target="panel"
><%= component.content %></div></div>
```

`gem/lib/ruby_ui/select/select_group.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class SelectGroup < Component
  end
end
```

`gem/lib/ruby_ui/select/select_group.html.erb`:

```erb
<div <%= tag.attributes(component.attrs) %>><%= component.content %></div>
```

`gem/lib/ruby_ui/select/select_input.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class SelectInput < Component
    private

    def default_attrs
      {
        class: "hidden",
        data: {
          ruby_ui__select_target: "input",
          ruby_ui__form_field_target: "input",
          action: "change->ruby-ui--form-field#onChange invalid->ruby-ui--form-field#onInvalid"
        }
      }
    end
  end
end
```

`gem/lib/ruby_ui/select/select_input.html.erb`:

```erb
<input <%= tag.attributes(component.attrs) %>>
```

`gem/lib/ruby_ui/select/select_item.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class SelectItem < Component
    def initialize(value: nil, **attrs)
      @value = value
      super(**attrs)
    end

    private

    def default_attrs
      {
        role: "option",
        tabindex: "0",
        data_value: @value,
        aria_selected: "false",
        data_orientation: "vertical",
        class: [
          "item group relative flex cursor-pointer select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none transition-colors",
          "focus:bg-accent focus:text-accent-foreground",
          "hover:bg-accent hover:text-accent-foreground",
          "disabled:pointer-events-none disabled:opacity-50",
          "aria-selected:bg-accent aria-selected:text-accent-foreground",
          "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
          "aria-disabled:pointer-events-none aria-disabled:opacity-50 aria-disabled:cursor-not-allowed"
        ],
        data: {
          controller: "ruby-ui--select-item",
          action: "click->ruby-ui--select#selectItem keydown.enter->ruby-ui--select#selectItem keydown.down->ruby-ui--select#handleKeyDown keydown.up->ruby-ui--select#handleKeyUp keydown.esc->ruby-ui--select#handleEsc",
          ruby_ui__select_target: "item"
        }
      }
    end
  end
end
```

`gem/lib/ruby_ui/select/select_item.html.erb` — the icon first, then the content, as 1.6 ordered them. 1.6's class string carried a literal tab between `group-aria-selected:visible` and `mr-2`; the canonical form splits class tokens on any HTML whitespace in both modes, so a space here changes no snapshot:

```erb
<div <%= tag.attributes(component.attrs) %>><svg
  xmlns="http://www.w3.org/2000/svg"
  viewbox="0 0 24 24"
  fill="none"
  stroke="currentColor"
  class="invisible group-aria-selected:visible mr-2 h-4 w-4 flex-none"
  stroke-width="2"
  stroke-linecap="round"
  stroke-linejoin="round"
><path d="M20 6 9 17l-5-5"></path></svg><%= component.content %></div>
```

`gem/lib/ruby_ui/select/select_label.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class SelectLabel < Component
    private

    def default_attrs
      {
        class: "px-2 py-1.5 text-sm font-semibold"
      }
    end
  end
end
```

`gem/lib/ruby_ui/select/select_label.html.erb`:

```erb
<h3 <%= tag.attributes(component.attrs) %>><%= component.content %></h3>
```

`gem/lib/ruby_ui/select/select_trigger.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class SelectTrigger < Component
    private

    def default_attrs
      {
        type: "button",
        role: "combobox",
        data: {
          action: "ruby-ui--select#onClick",
          ruby_ui__select_target: "trigger"
        },
        aria: {
          controls: "radix-:r0:",
          expanded: "false",
          autocomplete: "none",
          haspopup: "listbox",
          activedescendant: true
        },
        class: [
          "truncate w-full flex h-9 items-center justify-between whitespace-nowrap rounded-md border border-input bg-transparent px-3 py-2 text-sm shadow-sm ring-offset-background",
          "placeholder:text-muted-foreground",
          "focus:outline-none focus:ring-1 focus:ring-ring",
          "disabled:cursor-not-allowed disabled:opacity-50",
          "aria-disabled:cursor-not-allowed aria-disabled:opacity-50 aria-disabled:pointer-events-none"
        ]
      }
    end
  end
end
```

`gem/lib/ruby_ui/select/select_trigger.html.erb` — the content, then the icon:

```erb
<button <%= tag.attributes(component.attrs) %>><%= component.content %><svg
  xmlns="http://www.w3.org/2000/svg"
  viewbox="0 0 24 24"
  fill="none"
  stroke="currentColor"
  class="ml-2 h-4 w-4 shrink-0 opacity-50"
  stroke-width="2"
  stroke-linecap="round"
  stroke-linejoin="round"
><path d="m7 15 5 5 5-5"></path><path d="m7 9 5-5 5 5"></path></svg></button>
```

`gem/lib/ruby_ui/select/select_value.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class SelectValue < Component
    attr_reader :placeholder

    def initialize(placeholder: nil, **attrs)
      @placeholder = placeholder
      super(**attrs)
    end

    # The block's content, or the placeholder when the block emitted nothing
    # (nil, or ""), as Phlex did — it wrote the placeholder only when the
    # buffer had not grown, so whitespace-only content is content.
    def value
      (content.nil? || content.empty?) ? placeholder : content
    end

    private

    def default_attrs
      {
        data: {
          ruby_ui__select_target: "value"
        },
        class: "truncate pointer-events-none"
      }
    end
  end
end
```

`gem/lib/ruby_ui/select/select_value.html.erb`:

```erb
<span <%= tag.attributes(component.attrs) %>><%= component.value %></span>
```

```bash
for f in lib/ruby_ui/select/*.html.erb; do printf "%s %s\n" "$(tail -c1 "$f" | xxd -p)" "$f"; done
```

Expected: `0a` before every path.

- [ ] **Step 4: Run the select scenarios, the select tests, then everything**

```bash
bundle exec rake test N=/test_select__/ 2>&1 | grep -E "runs,|Failure:|Error:"
```

Expected: `2 runs, … 0 failures, 0 errors, 0 skips`. `select/default`'s strict form carries `id="content00000001"` and `aria-controls` references to it; a different id is a STOP (the pin), not a re-record.

```bash
bundle exec rake test N="/^RubyUI::SelectTest#/" 2>&1 | grep -E "runs,"; bundle exec rake golden 2>&1 | grep -E "runs,"; bundle exec rake test 2>&1 | grep -E "runs,"; bundle exec standardrb
```

Expected: `6 runs`, `395 runs`, `782 runs`, `426 files inspected, no offenses detected`.

- [ ] **Step 5: Rebuild the registry, run the guards, commit**

```bash
cd ../mcp && bundle exec exe/ruby-ui-mcp-build && cd .. && git diff --stat mcp/data/registry.json && git status --porcelain gem/test/golden/snapshots gem/test/golden/strict gem/test/golden/views && git diff --quiet v2/fixtures -- 'gem/lib/ruby_ui/**/*.js' && echo clean
git add gem/lib/ruby_ui/select gem/test/ruby_ui/select_test.rb gem/test/golden/scenarios.rb mcp/data/registry.json
git commit -m "[Feature] RubyUI 2.0: Select

Eight classes and sidecars. SelectContent mints its id in initialize
exactly as 1.6 did, so the golden pin still yields content00000001 and
the cross-references line up; SelectValue writes the placeholder when
the block emitted nothing and keeps whitespace-only content, as Phlex
did.
SelectItem's class string loses a stray tab the canonical form could
never see. Two scenarios identical in both forms; both controllers
unedited.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

## Task 6: DataTable — the frame, the form and the leaves

**Files:**
- Modify: `gem/lib/ruby_ui/data_table/data_table.rb`, `data_table_toolbar.rb`, `data_table_bulk_actions.rb`, `data_table_pagination_bar.rb`, `data_table_selection_summary.rb`, `data_table_expand_toggle.rb`, `data_table_form.rb`, `data_table_row_checkbox.rb`, `data_table_select_all_checkbox.rb` (whole files given)
- Create: the nine sidecars beside them
- Modify: `gem/test/ruby_ui/data_table_test.rb`, `data_table_toolbar_test.rb`, `data_table_bulk_actions_test.rb`, `data_table_pagination_bar_test.rb`, `data_table_selection_summary_test.rb`, `data_table_expand_toggle_test.rb`, `data_table_form_test.rb`, `data_table_row_checkbox_test.rb`, `data_table_select_all_checkbox_test.rb` (whole files given)
- Modify: `gem/test/golden/scenarios.rb` — in the `"data_table"` block, `full_frame` and `expand_toggle_expanded` lose their blocks and the `columns` local goes; the other five keep theirs until Task 7
- Untouched: `data_table_controller.js`, `data_table_column_visibility_controller.js`, `data_table_search_controller.js`, `data_table_docs.rb`, the three adapters and their tests, and the five Task 7 classes
- Rebuild: `mcp/data/registry.json`

**Interfaces:**
- Consumes: `Component#mixed_attrs`, `Component#helpers`, `Attributes.flat`; `RubyUI::Checkbox` (Phlex) rendered from two sidecars with `**component.mixed_attrs`.
- Produces: `RubyUI::DataTable.new(id:, **attrs)` with public `frame_attrs`; `DataTableToolbar`, `DataTableBulkActions`, `DataTablePaginationBar` (`new(**attrs)`); `DataTableSelectionSummary.new(total_on_page: 0, **attrs)` with public `total_on_page`; `DataTableExpandToggle.new(controls:, expanded: false, label: "Toggle row details", **attrs)` with public `button_attrs`; `DataTableForm.new(action: "", method: "post", id: nil, **attrs)` with public `form_attrs`, `csrf_token` and `token_input_attrs`; `DataTableRowCheckbox.new(value:, name: "ids[]", label: nil, **attrs)`; `DataTableSelectAllCheckbox.new(**attrs)`. Until Task 7 the `full_frame` fixture renders a mix of these and the five still-Phlex classes, and stays green — the ERB lane renders both kinds.

- [ ] **Step 1: Port the nine test files, with one new CSRF test**

`gem/test/ruby_ui/data_table_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableTest < ComponentTest
  def test_renders_turbo_frame_with_given_id
    output = erb(%(<%= render RubyUI::DataTable.new(id: "employees") %>))
    assert_match %r{<turbo-frame[^>]*id="employees"[^>]*target="_top"}, output
  end

  def test_sets_data_controller_on_inner_div
    output = erb(%(<%= render RubyUI::DataTable.new(id: "x") %>))
    assert_match(/data-controller="ruby-ui--data-table"/, output)
  end

  def test_does_not_render_a_form_wrapper
    output = erb(%(<%= render RubyUI::DataTable.new(id: "x") %>))
    refute_match(/<form/, output)
  end

  def test_renders_children_inside_the_div
    output = erb(%(<%= render RubyUI::DataTable.new(id: "x") do %>INNER<% end %>))
    assert_match(/INNER/, output)
  end
end
```

`gem/test/ruby_ui/data_table_toolbar_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableToolbarTest < ComponentTest
  def test_renders_div_with_flex_layout_and_children
    output = erb(%(<%= render RubyUI::DataTableToolbar.new do %>INNER<% end %>))
    assert_match(/<div[^>]*class="[^"]*flex[^"]*"/, output)
    assert_match(/INNER/, output)
  end
end
```

`gem/test/ruby_ui/data_table_bulk_actions_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableBulkActionsTest < ComponentTest
  def test_starts_hidden_with_bulk_actions_target_and_renders_children
    output = erb(%(<%= render RubyUI::DataTableBulkActions.new do %>BUTTONS<% end %>))
    assert_match(/class="[^"]*hidden[^"]*"/, output)
    assert_match(/data-ruby-ui--data-table-target="bulkActions"/, output)
    assert_match(/BUTTONS/, output)
  end
end
```

`gem/test/ruby_ui/data_table_pagination_bar_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTablePaginationBarTest < ComponentTest
  def test_renders_flex_justify_between_layout_and_children
    output = erb(%(<%= render RubyUI::DataTablePaginationBar.new do %>INNER<% end %>))
    assert_match(/class="[^"]*flex[^"]*"/, output)
    assert_match(/class="[^"]*justify-between[^"]*"/, output)
    assert_match(/INNER/, output)
  end
end
```

`gem/test/ruby_ui/data_table_selection_summary_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableSelectionSummaryTest < ComponentTest
  def test_renders_selection_count_text_with_target
    output = erb(%(<%= render RubyUI::DataTableSelectionSummary.new(total_on_page: 10) %>))
    assert_match(/0 of 10 row\(s\) selected\./, output)
    assert_match(/data-ruby-ui--data-table-target="selectionSummary"/, output)
  end
end
```

`gem/test/ruby_ui/data_table_expand_toggle_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableExpandToggleTest < ComponentTest
  def test_renders_button_with_aria_attributes_and_delegated_action
    output = erb(%(<%= render RubyUI::DataTableExpandToggle.new(controls: "emp-1-detail") %>))
    assert_match(/<button[^>]*type="button"/, output)
    assert_match(/aria-expanded="false"/, output)
    assert_match(/aria-controls="emp-1-detail"/, output)
    assert_match(/aria-label="Toggle row details"/, output)
    assert_match(/data-action="[^"]*#{descriptor("click->ruby-ui--data-table#toggleRowDetail")}/, output)
    refute_match(/data-controller="ruby-ui--data-table-row-expand"/, output)
  end

  def test_accepts_custom_label_and_initial_expanded_state
    output = erb(%(<%= render RubyUI::DataTableExpandToggle.new(controls: "x", expanded: true, label: "Toggle") %>))
    assert_match(/aria-expanded="true"/, output)
    assert_match(/aria-label="Toggle"/, output)
  end
end
```

`gem/test/ruby_ui/data_table_form_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableFormTest < ComponentTest
  def test_renders_form_with_method_post_and_action
    output = erb(%(<%= render RubyUI::DataTableForm.new(action: "/x") %>))
    assert_match(/<form[^>]*action="\/x"[^>]*method="post"|<form[^>]*method="post"[^>]*action="\/x"/, output)
  end

  def test_renders_hidden_authenticity_token
    output = erb(%(<%= render RubyUI::DataTableForm.new %>))
    assert_match(/<input[^>]*type="hidden"[^>]*name="authenticity_token"[^>]*value="[^"]+"/, output)
  end

  def test_yields_children
    output = erb(%(<%= render RubyUI::DataTableForm.new do %>INNER<% end %>))
    assert_match(/INNER/, output)
  end

  def test_renders_form_with_id_attribute_when_given
    output = erb(%(<%= render RubyUI::DataTableForm.new(id: "my_form") %>))
    assert_match(/<form[^>]*id="my_form"/, output)
  end

  def test_renders_form_with_method_get_when_given
    output = erb(%(<%= render RubyUI::DataTableForm.new(method: "get") %>))
    assert_match(/<form[^>]*method="get"/, output)
  end

  def test_renders_form_with_method_delete_when_given
    output = erb(%(<%= render RubyUI::DataTableForm.new(method: "delete") %>))
    assert_match(/<form[^>]*method="delete"/, output)
  end

  # The gem's view context has no controller, so the token is the placeholder
  # the snapshots recorded; a host's view context answers form_authenticity_token.
  def test_uses_the_view_contexts_authenticity_token_when_it_has_one
    view = RubyUI::TestApp.view
    view.define_singleton_method(:form_authenticity_token) { "token-from-the-view" }

    assert_match(/name="authenticity_token"[^>]*value="token-from-the-view"/, view.render(RubyUI::DataTableForm.new))
  end
end
```

`gem/test/ruby_ui/data_table_row_checkbox_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableRowCheckboxTest < ComponentTest
  def test_renders_checkbox_input_with_name_and_value
    output = erb(%(<%= render RubyUI::DataTableRowCheckbox.new(value: 42) %>))
    assert_match(/<input[^>]*type="checkbox"/, output)
    assert_match(/name="ids\[\]"/, output)
    assert_match(/value="42"/, output)
  end

  def test_accepts_custom_name
    output = erb(%(<%= render RubyUI::DataTableRowCheckbox.new(value: 1, name: "selected[]") %>))
    assert_match(/name="selected\[\]"/, output)
  end

  def test_carries_stimulus_target_and_action
    output = erb(%(<%= render RubyUI::DataTableRowCheckbox.new(value: 1) %>))
    assert_match(/data-ruby-ui--data-table-target="rowCheckbox"/, output)
    assert_match(/data-action="[^"]*#{descriptor("change->ruby-ui--data-table#toggleRow")}/, output)
  end

  def test_aria_label_contains_the_value
    output = erb(%(<%= render RubyUI::DataTableRowCheckbox.new(value: 7) %>))
    assert_match(/aria-label="Select row 7"/, output)
  end

  def test_custom_aria_label_via_label_kwarg
    output = erb(%(<%= render RubyUI::DataTableRowCheckbox.new(value: 1, label: "Select Alice Johnson") %>))
    assert_match(/aria-label="Select Alice Johnson"/, output)
  end
end
```

`gem/test/ruby_ui/data_table_select_all_checkbox_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableSelectAllCheckboxTest < ComponentTest
  def test_carries_select_all_target_toggle_all_action_and_aria_label
    output = erb(%(<%= render RubyUI::DataTableSelectAllCheckbox.new %>))
    assert_match(/<input[^>]*type="checkbox"/, output)
    assert_match(/data-ruby-ui--data-table-target="selectAll"/, output)
    assert_match(/data-action="[^"]*#{descriptor("change->ruby-ui--data-table#toggleAll")}/, output)
    assert_match(/aria-label="Select all"/, output)
  end
end
```

```bash
cd gem && bundle exec rake test N="/^RubyUI::DataTable(Test|ToolbarTest|BulkActionsTest|PaginationBarTest|SelectionSummaryTest|ExpandToggleTest|FormTest|RowCheckboxTest|SelectAllCheckboxTest)#/" 2>&1 | grep -E "runs,|Failure:|Error:" | head
```

Expected: `23 runs, … 0 failures` against the still-Phlex components — including the new CSRF test, because phlex-rails' `helpers` is the same view context. This task adds no 2.0 behaviour, so it has no red test: the migration is a refactor under these 23 tests and the 12 golden ones.

- [ ] **Step 2: Drop the two Phlex blocks that render a class from this task**

In the `"data_table"` block of `gem/test/golden/scenarios.rb`, delete the `columns = […].freeze` local and the bodies of `full_frame` and `expand_toggle_expanded`, leaving the other five scenarios exactly as they are. The block becomes:

```ruby
Golden::Catalog.component "data_table" do
  scenario "full_frame"

  scenario "pagination_first_page" do
    RubyUI.DataTablePagination(page: 1, per_page: 10, total_count: 30, path: "/x", query: {})
  end

  scenario "pagination_wide_window" do
    RubyUI.DataTablePagination(page: 10, per_page: 1, total_count: 20, path: "/x", query: {}, window: 2)
  end

  scenario "pagination_manual_adapter" do
    RubyUI.DataTablePagination(
      with: RubyUI::DataTableManualAdapter.new(page: 2, per_page: 5, total_count: 21),
      path: "/x",
      query: {}
    )
  end

  scenario "sort_head_unsorted" do
    RubyUI.DataTableSortHead(column_key: :name, label: "Name", path: "/x", query: {})
  end

  scenario "expand_toggle_expanded"

  scenario "search_without_debounce" do
    RubyUI.DataTableSearch(path: "/x", debounce: false, preserved_params: {"sort" => "name"})
  end
end
```

```bash
bundle exec rake golden 2>&1 | grep -E "runs,"
```

Expected: `393 runs, … 0 failures, 0 errors, 0 skips`.

- [ ] **Step 3: Write the nine classes and their sidecars**

`gem/lib/ruby_ui/data_table/data_table.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DataTable < Component
    def initialize(id:, **attrs)
      @id = id
      super(**attrs)
    end

    # The frame's own attributes, serialized as Phlex did: a nil id is omitted,
    # a Symbol dasherizes.
    def frame_attrs
      Attributes.flat(id: @id, target: "_top")
    end

    private

    def default_attrs
      {
        class: "w-full space-y-4",
        data: {controller: "ruby-ui--data-table"}
      }
    end
  end
end
```

`gem/lib/ruby_ui/data_table/data_table.html.erb` — the frame carries only `id` and `target`, the component's attributes go on the inner `div`, as in 1.6:

```erb
<turbo-frame <%= tag.attributes(component.frame_attrs) %>><div <%= tag.attributes(component.attrs) %>><%= component.content %></div></turbo-frame>
```

`gem/lib/ruby_ui/data_table/data_table_toolbar.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DataTableToolbar < Component
    private

    def default_attrs
      {class: "flex items-center justify-between gap-2"}
    end
  end
end
```

`gem/lib/ruby_ui/data_table/data_table_toolbar.html.erb`:

```erb
<div <%= tag.attributes(component.attrs) %>><%= component.content %></div>
```

`gem/lib/ruby_ui/data_table/data_table_bulk_actions.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DataTableBulkActions < Component
    private

    def default_attrs
      {
        class: "hidden items-center gap-2",
        data: {"ruby-ui--data-table-target": "bulkActions"}
      }
    end
  end
end
```

`gem/lib/ruby_ui/data_table/data_table_bulk_actions.html.erb`:

```erb
<div <%= tag.attributes(component.attrs) %>><%= component.content %></div>
```

`gem/lib/ruby_ui/data_table/data_table_pagination_bar.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DataTablePaginationBar < Component
    private

    def default_attrs
      {class: "flex items-center justify-between gap-4 py-2"}
    end
  end
end
```

`gem/lib/ruby_ui/data_table/data_table_pagination_bar.html.erb`:

```erb
<div <%= tag.attributes(component.attrs) %>><%= component.content %></div>
```

`gem/lib/ruby_ui/data_table/data_table_selection_summary.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DataTableSelectionSummary < Component
    attr_reader :total_on_page

    def initialize(total_on_page: 0, **attrs)
      @total_on_page = total_on_page
      super(**attrs)
    end

    private

    def default_attrs
      {
        class: "text-sm text-muted-foreground",
        data: {"ruby-ui--data-table-target": "selectionSummary"}
      }
    end
  end
end
```

`gem/lib/ruby_ui/data_table/data_table_selection_summary.html.erb`:

```erb
<div <%= tag.attributes(component.attrs) %>>0 of <%= component.total_on_page %> row(s) selected.</div>
```

`gem/lib/ruby_ui/data_table/data_table_expand_toggle.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DataTableExpandToggle < Component
    def initialize(controls:, expanded: false, label: "Toggle row details", **attrs)
      @controls = controls
      @expanded = expanded
      @label = label
      super(**attrs)
    end

    # 1.6 spread the caller's attributes after the button's own, so a caller's
    # key replaced the button's; `merge` keeps that order.
    def button_attrs
      Attributes.flat({
        type: "button",
        aria_expanded: @expanded.to_s,
        aria_controls: @controls,
        aria_label: @label,
        data: {action: "click->ruby-ui--data-table#toggleRowDetail"}
      }.merge(mixed_attrs))
    end

    private

    def default_attrs
      {
        class: "group inline-flex items-center justify-center h-8 w-8 rounded-md hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
      }
    end
  end
end
```

`gem/lib/ruby_ui/data_table/data_table_expand_toggle.html.erb`:

```erb
<button <%= tag.attributes(component.button_attrs) %>><svg
  xmlns="http://www.w3.org/2000/svg"
  width="16"
  height="16"
  viewBox="0 0 24 24"
  fill="none"
  stroke="currentColor"
  stroke-width="2"
  stroke-linecap="round"
  stroke-linejoin="round"
  class="h-4 w-4 transition-transform duration-150 group-aria-expanded:rotate-90"
><polyline points="9 18 15 12 9 6"></polyline></svg></button>
```

`gem/lib/ruby_ui/data_table/data_table_form.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DataTableForm < Component
    def initialize(action: "", method: "post", id: nil, **attrs)
      @action = action
      @method = method
      @id = id
      super(**attrs)
    end

    # The form's own attributes first, the caller's after — a caller's key wins,
    # as it did through 1.6's keyword splat.
    def form_attrs
      form = {action: @action, method: @method}
      form[:id] = @id if @id
      Attributes.flat(form.merge(mixed_attrs))
    end

    # In a Rails request the view context answers form_authenticity_token.
    # Outside one (the gem's tests) it does not, and the placeholder is what
    # the golden snapshots recorded.
    def csrf_token
      helpers.respond_to?(:form_authenticity_token) ? helpers.form_authenticity_token : "csrf-token-placeholder"
    end

    def token_input_attrs
      Attributes.flat(type: "hidden", name: "authenticity_token", value: csrf_token)
    end
  end
end
```

`gem/lib/ruby_ui/data_table/data_table_form.html.erb`:

```erb
<form <%= tag.attributes(component.form_attrs) %>><input <%= tag.attributes(component.token_input_attrs) %>><%= component.content %></form>
```

`gem/lib/ruby_ui/data_table/data_table_row_checkbox.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DataTableRowCheckbox < Component
    def initialize(value:, name: "ids[]", label: nil, **attrs)
      @value = value
      @name = name
      @label = label
      super(**attrs)
    end

    private

    def default_attrs
      {
        name: @name,
        value: @value,
        aria_label: @label || "Select row #{@value}",
        data: {
          "ruby-ui--data-table-target": "rowCheckbox",
          action: "change->ruby-ui--data-table#toggleRow"
        }
      }
    end
  end
end
```

`gem/lib/ruby_ui/data_table/data_table_row_checkbox.html.erb` — the nested hash, so Checkbox's `mix` concatenates the two `data-action`s as 1.6 did (decision 11):

```erb
<%= render RubyUI::Checkbox.new(**component.mixed_attrs) %>
```

`gem/lib/ruby_ui/data_table/data_table_select_all_checkbox.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DataTableSelectAllCheckbox < Component
    private

    def default_attrs
      {
        aria_label: "Select all",
        data: {
          "ruby-ui--data-table-target": "selectAll",
          action: "change->ruby-ui--data-table#toggleAll"
        }
      }
    end
  end
end
```

`gem/lib/ruby_ui/data_table/data_table_select_all_checkbox.html.erb`:

```erb
<%= render RubyUI::Checkbox.new(**component.mixed_attrs) %>
```

```bash
for f in lib/ruby_ui/data_table/*.html.erb; do printf "%s %s\n" "$(tail -c1 "$f" | xxd -p)" "$f"; done
```

Expected: nine lines, `0a` before every path.

- [ ] **Step 4: Run the data_table scenarios, the ported tests, then everything**

```bash
bundle exec rake test N=/test_data_table__/ 2>&1 | grep -E "runs,|Failure:|Error:"
```

Expected: `12 runs, … 0 failures, 0 errors, 0 skips` — the seven ERB-lane tests (`full_frame` now rendering nine 2.0 classes beside five Phlex ones) and the five Phlex-lane tests that remain.

```bash
bundle exec rake test N="/^RubyUI::DataTable(Test|ToolbarTest|BulkActionsTest|PaginationBarTest|SelectionSummaryTest|ExpandToggleTest|FormTest|RowCheckboxTest|SelectAllCheckboxTest)#/" 2>&1 | grep -E "runs,"; bundle exec rake golden 2>&1 | grep -E "runs,"; bundle exec rake test 2>&1 | grep -E "runs,"; bundle exec standardrb
```

Expected: `23 runs, … 0 failures`, `393 runs`, `781 runs`, `426 files inspected, no offenses detected`.

- [ ] **Step 5: Rebuild the registry, run the guards, commit**

```bash
cd ../mcp && bundle exec exe/ruby-ui-mcp-build && cd .. && git diff --stat mcp/data/registry.json && git status --porcelain gem/test/golden/snapshots gem/test/golden/strict gem/test/golden/views && git diff --quiet v2/fixtures -- 'gem/lib/ruby_ui/**/*.js' && echo clean
git add gem/lib/ruby_ui/data_table gem/test/ruby_ui/data_table_test.rb gem/test/ruby_ui/data_table_toolbar_test.rb gem/test/ruby_ui/data_table_bulk_actions_test.rb gem/test/ruby_ui/data_table_pagination_bar_test.rb gem/test/ruby_ui/data_table_selection_summary_test.rb gem/test/ruby_ui/data_table_expand_toggle_test.rb gem/test/ruby_ui/data_table_form_test.rb gem/test/ruby_ui/data_table_row_checkbox_test.rb gem/test/ruby_ui/data_table_select_all_checkbox_test.rb gem/test/golden/scenarios.rb mcp/data/registry.json
git commit -m "[Feature] RubyUI 2.0: DataTable — the frame, the form and the leaves

Nine of the fourteen DataTable classes: the <turbo-frame> root, the form
that reads the CSRF token through helpers (the placeholder where the
view context has none, as the snapshots recorded), the two checkboxes
that forward mixed_attrs into the still-Phlex Checkbox so their
data-action concatenates as 1.6's did (decision 11), the expand toggle
whose caller attributes merge over the button's own, and four wrappers.

full_frame renders these beside the five classes Task 7 migrates and is
identical to its snapshot in both forms; the three controllers are
unedited.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

## Task 7: DataTable — search, per-page select, column toggle, sort head and pagination

**Files:**
- Modify: `gem/lib/ruby_ui/data_table/data_table_search.rb`, `data_table_per_page_select.rb`, `data_table_column_toggle.rb`, `data_table_sort_head.rb`, `data_table_pagination.rb` (whole files given)
- Create: the five sidecars beside them
- Modify: `gem/test/ruby_ui/data_table_search_test.rb`, `data_table_per_page_select_test.rb`, `data_table_column_toggle_test.rb`, `data_table_sort_head_test.rb`, `data_table_pagination_test.rb` (whole files given)
- Modify: `gem/test/golden/scenarios.rb` — the `"data_table"` block loses its last five Phlex blocks
- Untouched: the three controllers, `data_table_docs.rb`, the adapters
- Rebuild: `mcp/data/registry.json`

**Interfaces:**
- Consumes: `Component#mixed_attrs`, `Attributes.flat`; the Phlex neighbours `RubyUI::Input`, `NativeSelect`, `DropdownMenu`, `DropdownMenuTrigger`, `DropdownMenuContent`, `Button`, `TableHead`, `Pagination`, `PaginationContent`, `PaginationItem`, `PaginationEllipsis`, all rendered from sidecars with the same arguments 1.6 passed; `Phlex::SGML::SafeValue` for NativeSelect's `onchange:`.
- Produces: `DataTableSearch.new(path:, name: "search", value: nil, frame_id: nil, placeholder: "Search...", debounce: 300, preserved_params: {}, **attrs)` with public `name`, `value`, `placeholder`, `form_attrs`, `preserved_inputs → Array<[String, String]>`, `hidden_input_attrs(name, value)`; `DataTablePerPageSelect.new(path:, name: "per_page", value: nil, frame_id: nil, options: [5, 10, 25, 50], **attrs)` with public `name`, `options`, `form_attrs`, `option_attrs(option)`, `onchange`; `DataTableColumnToggle.new(columns:, label: "Columns", **attrs)` with public `columns`, `label`, `checkbox_attrs(column)`; `DataTableSortHead.new(column_key:, label:, sort: nil, direction: nil, sort_param: "sort", direction_param: "direction", page_param: "page", path: "", query: {}, **attrs)` with public `label`, `anchor_attrs` (the `href` through `Attributes.flat`, so a `javascript:` path is dropped as Phlex dropped it), `sort_href`, `icon_class`, `icon_points → Array<String>`; `DataTablePagination.new(with: nil, pagy: nil, kaminari: nil, page: nil, per_page: nil, total_count: nil, page_param: "page", path: "", query: {}, window: 1, prev_label: "<", next_label: ">", **attrs)` with public `paginate?`, `current`, `total`, `page_href(page)`, `windowed_pages`, `prev_label`, `next_label`.

- [ ] **Step 1: Port the five test files**

`gem/test/ruby_ui/data_table_search_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableSearchTest < ComponentTest
  def test_renders_get_form_with_search_input
    output = erb(%(<%= render RubyUI::DataTableSearch.new(path: "/x", value: "alice", name: "search") %>))
    assert_match(/<form[^>]*method="get"[^>]*action="\/x"/, output)
    assert_match(/name="search"/, output)
    assert_match(/value="alice"/, output)
  end

  def test_renames_param_via_name
    output = erb(%(<%= render RubyUI::DataTableSearch.new(path: "/x", name: "q") %>))
    assert_match(/name="q"/, output)
  end

  def test_emits_data_turbo_frame_when_frame_id_given
    output = erb(%(<%= render RubyUI::DataTableSearch.new(path: "/x", frame_id: "employees") %>))
    assert_match(/data-turbo-frame="employees"/, output)
  end

  def test_emits_debounce_controller_and_delay_value_and_action_by_default
    output = erb(%(<%= render RubyUI::DataTableSearch.new(path: "/x") %>))
    assert_match(/data-controller="ruby-ui--data-table-search"/, output)
    assert_match(/data-ruby-ui--data-table-search-delay-value="300"/, output)
    assert_match(/data-action="#{descriptor("input->ruby-ui--data-table-search#submit")}"/, output)
  end

  def test_debounce_500_sets_custom_delay
    output = erb(%(<%= render RubyUI::DataTableSearch.new(path: "/x", debounce: 500) %>))
    assert_match(/data-ruby-ui--data-table-search-delay-value="500"/, output)
  end

  def test_debounce_false_disables_auto_submit
    output = erb(%(<%= render RubyUI::DataTableSearch.new(path: "/x", debounce: false) %>))
    refute_match(/data-controller="ruby-ui--data-table-search"/, output)
    refute_match(/data-ruby-ui--data-table-search-delay-value/, output)
  end

  def test_debounce_0_disables_auto_submit
    output = erb(%(<%= render RubyUI::DataTableSearch.new(path: "/x", debounce: 0) %>))
    refute_match(/data-controller="ruby-ui--data-table-search"/, output)
  end

  def test_preserved_params_emits_hidden_inputs_for_each_key
    output = erb(%(<%= render RubyUI::DataTableSearch.new(path: "/x", name: "search", preserved_params: {"sort" => "name", "direction" => "asc", "per_page" => "10"}) %>))
    assert_match(/<input[^>]*type="hidden"[^>]*name="sort"[^>]*value="name"/, output)
    assert_match(/<input[^>]*type="hidden"[^>]*name="direction"[^>]*value="asc"/, output)
    assert_match(/<input[^>]*type="hidden"[^>]*name="per_page"[^>]*value="10"/, output)
  end

  def test_preserved_params_skips_blank_values
    output = erb(%(<%= render RubyUI::DataTableSearch.new(path: "/x", preserved_params: {"sort" => "", "direction" => nil}) %>))
    refute_match(/name="sort"/, output)
    refute_match(/name="direction"/, output)
  end

  def test_preserved_params_skips_the_search_param_itself
    output = erb(%(<%= render RubyUI::DataTableSearch.new(path: "/x", name: "q", preserved_params: {"q" => "alice", "sort" => "name"}) %>))
    refute_match(/<input[^>]*type="hidden"[^>]*name="q"/, output)
    assert_match(/name="sort"/, output)
  end
end
```

`gem/test/ruby_ui/data_table_per_page_select_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTablePerPageSelectTest < ComponentTest
  def test_renders_get_form_with_select_and_options
    output = erb(%(<%= render RubyUI::DataTablePerPageSelect.new(path: "/x", value: 25, options: [5, 10, 25, 50]) %>))
    assert_match(/<form[^>]*(method="get"[^>]*action="\/x"|action="\/x"[^>]*method="get")/, output)
    assert_match(/name="per_page"/, output)
    assert_match(/value="25"[^>]*selected|selected[^>]*value="25"/, output)
    assert_match(/onchange="this\.form\.requestSubmit\(\)"/, output)
  end

  def test_renames_param_via_name
    output = erb(%(<%= render RubyUI::DataTablePerPageSelect.new(path: "/x", name: "size") %>))
    assert_match(/name="size"/, output)
  end

  def test_includes_given_options
    output = erb(%(<%= render RubyUI::DataTablePerPageSelect.new(path: "/x", options: [5, 10, 25]) %>))
    assert_match(/<option[^>]*value="5"/, output)
    assert_match(/<option[^>]*value="10"/, output)
    assert_match(/<option[^>]*value="25"/, output)
  end
end
```

`gem/test/ruby_ui/data_table_column_toggle_test.rb` — the last test counted bare `checked` attributes; the layer serializes `checked="checked"`, so the regexp accepts both:

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableColumnToggleTest < ComponentTest
  def test_renders_dropdown_with_checkbox_per_column
    output = erb(%(<%= render RubyUI::DataTableColumnToggle.new(columns: [{key: :email, label: "Email"}, {key: :salary, label: "Salary"}]) %>))
    assert_match(/Columns/, output)
    assert_match(/data-controller="[^"]*ruby-ui--data-table-column-visibility/, output)
    assert_match(/data-column-key="email"/, output)
    assert_match(/data-column-key="salary"/, output)
    assert_match(/Email/, output)
    assert_match(/Salary/, output)
  end

  def test_renders_a_custom_trigger_label
    output = erb(%(<%= render RubyUI::DataTableColumnToggle.new(label: "Colunas", columns: [{key: :email, label: "Email"}]) %>))
    assert_match(/Colunas/, output)
  end

  def test_column_can_start_hidden
    output = erb(%(<%= render RubyUI::DataTableColumnToggle.new(columns: [{key: :email, label: "Email"}, {key: :salary, label: "Salary", visible: false}]) %>))
    # only the visible column renders the `checked` attribute — bare in Phlex,
    # checked="checked" through tag.attributes
    assert_equal 1, output.scan(/\bchecked(?:="checked")?(?:\s|>)/).length
  end
end
```

`gem/test/ruby_ui/data_table_sort_head_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableSortHeadTest < ComponentTest
  def test_renders_th_with_sort_link_cycling_nil_to_asc
    output = erb(%(<%= render RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", path: "/x", query: {}) %>))
    assert_match(/<th/, output)
    assert_match(/href="\/x\?(sort=name&(amp;)?direction=asc|direction=asc&(amp;)?sort=name)"/, output)
    assert_match(/Name/, output)
  end

  def test_current_asc_next_href_is_desc
    output = erb(%(<%= render RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", sort: "name", direction: "asc", path: "/x", query: {}) %>))
    assert_match(/direction=desc/, output)
  end

  def test_current_desc_next_href_clears_sort
    output = erb(%(<%= render RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", sort: "name", direction: "desc", path: "/x", query: {}) %>))
    assert_match(/href="\/x"/, output)
  end

  def test_preserves_other_query_params
    output = erb(%(<%= render RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", path: "/x", query: {"search" => "alice"}) %>))
    assert_match(/search=alice/, output)
  end

  def test_renames_sort_and_direction_params
    output = erb(%(<%= render RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", sort_param: "sort_by", direction_param: "sort_dir", path: "/x", query: {}) %>))
    assert_match(/sort_by=name/, output)
    assert_match(/sort_dir=asc/, output)
  end

  def test_custom_page_param_is_dropped_from_next_href_when_sorting
    output = erb(%(<%= render RubyUI::DataTableSortHead.new(column_key: :name, label: "Name", page_param: "p", path: "/x", query: {"p" => "3", "search" => "bob"}) %>))
    refute_match(/[?&]p=/, output)
    assert_match(/search=bob/, output)
  end

  # Phlex dropped a javascript: href on the anchor; Attributes.flat does the same.
  def test_a_javascript_path_never_reaches_the_href
    output = erb(%(<%= render RubyUI::DataTableSortHead.new(column_key: :x, label: "X", sort: "x", direction: "desc", path: "javascript:alert(1)", query: {}) %>))
    refute_match(/href=/, output)
    assert_match(/<a /, output)
  end
end
```

`gem/test/ruby_ui/data_table_pagination_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTablePaginationTest < ComponentTest
  def test_accepts_manual_keyword_shortcut
    output = erb(%(<%= render RubyUI::DataTablePagination.new(page: 2, per_page: 10, total_count: 25, path: "/x", query: {}) %>))
    assert_match(/href="\/x\?page=1"/, output)  # Previous
    assert_match(/href="\/x\?page=3"/, output)  # Next
  end

  def test_accepts_pagy_keyword_shortcut_duck_typed_double
    pagy_double = Data.define(:page, :pages, :count, :items).new(page: 1, pages: 2, count: 15, items: 10)
    output = RubyUI::TestApp.view.render(RubyUI::DataTablePagination.new(pagy: pagy_double, path: "/x", query: {}))
    assert_match(/href="\/x\?page=2"/, output)
  end

  def test_with_accepts_custom_adapter
    custom = Data.define(:current_page, :total_pages, :total_count, :per_page).new(1, 3, 20, 10)
    output = RubyUI::TestApp.view.render(RubyUI::DataTablePagination.new(with: custom, path: "/x", query: {}))
    assert_match(/href="\/x\?page=2"/, output)
  end

  def test_renames_page_param
    output = erb(%(<%= render RubyUI::DataTablePagination.new(page: 1, per_page: 10, total_count: 30, path: "/x", query: {}, page_param: "p") %>))
    assert_match(/p=2/, output)
  end

  def test_raises_when_no_adapter_and_no_manual_args
    assert_raises(ArgumentError) { RubyUI::DataTablePagination.new(path: "/x", query: {}) }
  end

  def test_window_kwarg_widens_numbered_page_range
    out_narrow = erb(%(<%= render RubyUI::DataTablePagination.new(page: 10, per_page: 1, total_count: 20, path: "/x", query: {}, window: 1) %>))
    out_wide = erb(%(<%= render RubyUI::DataTablePagination.new(page: 10, per_page: 1, total_count: 20, path: "/x", query: {}, window: 2) %>))
    refute_match(/page=8/, out_narrow)
    assert_match(/page=8/, out_wide)
  end
end
```

(The two tests that pass a Ruby object built in the test render through `view.render(component)` rather than an ERB string; the assertion is unchanged.)

```bash
cd gem && bundle exec rake test N="/^RubyUI::DataTable(SearchTest|PerPageSelectTest|ColumnToggleTest|SortHeadTest|PaginationTest)#/" 2>&1 | grep -E "runs,|Failure:|Error:" | head
```

Expected: `29 runs, … 0 failures` against the still-Phlex components — the `javascript:` test included, since Phlex already drops that href. No red test in this task; the composites add no 2.0 behaviour.

- [ ] **Step 2: Drop the last five Phlex blocks**

The `"data_table"` block in `gem/test/golden/scenarios.rb` becomes:

```ruby
Golden::Catalog.component "data_table" do
  scenario "full_frame"
  scenario "pagination_first_page"
  scenario "pagination_wide_window"
  scenario "pagination_manual_adapter"
  scenario "sort_head_unsorted"
  scenario "expand_toggle_expanded"
  scenario "search_without_debounce"
end
```

```bash
bundle exec rake golden 2>&1 | grep -E "runs,"
```

Expected: `388 runs, … 0 failures, 0 errors, 0 skips`. From here on the Phlex lane has 166 tests, none of them for the 22 scenarios of this plan.

- [ ] **Step 3: Write the five classes and their sidecars**

`gem/lib/ruby_ui/data_table/data_table_search.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DataTableSearch < Component
    attr_reader :name, :value, :placeholder

    def initialize(path:, name: "search", value: nil, frame_id: nil, placeholder: "Search...", debounce: 300, preserved_params: {}, **attrs)
      @path = path
      @name = name
      @value = value
      @frame_id = frame_id
      @placeholder = placeholder
      @debounce = debounce
      @preserved_params = preserved_params
      super(**attrs)
    end

    # 1.6 merged the form's own attributes over the caller's — a caller's
    # `data:` gave way to the controller wiring; `merge` in that direction.
    def form_attrs
      Attributes.flat(mixed_attrs.merge(method: "get", action: @path, data: form_data))
    end

    # [name, value] for the hidden inputs that carry the other query parameters
    # through a search. Blank values and the search parameter itself are
    # skipped, as in 1.6.
    def preserved_inputs
      @preserved_params.filter_map do |key, value|
        next if value.nil? || (value.respond_to?(:empty?) && value.empty?)
        next if key.to_s == @name

        [key.to_s, value.to_s]
      end
    end

    def hidden_input_attrs(name, value)
      Attributes.flat(type: "hidden", name: name, value: value)
    end

    private

    def debounce_enabled?
      @debounce && @debounce.to_i > 0
    end

    def form_data
      base = {}
      base[:turbo_frame] = @frame_id if @frame_id
      if debounce_enabled?
        base[:controller] = "ruby-ui--data-table-search"
        base[:"ruby-ui--data-table-search-delay-value"] = @debounce.to_i
        base[:action] = "input->ruby-ui--data-table-search#submit"
      end
      base
    end

    def default_attrs
      {class: "max-w-sm flex-1"}
    end
  end
end
```

`gem/lib/ruby_ui/data_table/data_table_search.html.erb`:

```erb
<form <%= tag.attributes(component.form_attrs) %>><%= render RubyUI::Input.new(type: :search, name: component.name, value: component.value, placeholder: component.placeholder, autocomplete: "off") %><% component.preserved_inputs.each do |name, value| %><input <%= tag.attributes(component.hidden_input_attrs(name, value)) %>><% end %></form>
```

`gem/lib/ruby_ui/data_table/data_table_per_page_select.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DataTablePerPageSelect < Component
    attr_reader :name, :options

    def initialize(path:, name: "per_page", value: nil, frame_id: nil, options: [5, 10, 25, 50], **attrs)
      @path = path
      @name = name
      @value = value
      @frame_id = frame_id
      @options = options
      super(**attrs)
    end

    def form_attrs
      form = {action: @path, method: "get"}
      form[:data] = {turbo_frame: @frame_id} if @frame_id
      Attributes.flat(mixed_attrs.merge(form))
    end

    def option_attrs(option)
      attributes = {value: option.to_s}
      attributes[:selected] = true if option.to_s == @value.to_s
      Attributes.flat(attributes)
    end

    # 1.6 passed the handler through Phlex's `safe`. NativeSelect is still
    # Phlex and refuses an `on*` attribute unless its value is a SafeObject;
    # the 2.0 Attributes has no such bypass, so this goes when NativeSelect
    # migrates and Phase 2.2 chooses between a bypass and a Stimulus action.
    def onchange
      Phlex::SGML::SafeValue.new("this.form.requestSubmit()")
    end
  end
end
```

`gem/lib/ruby_ui/data_table/data_table_per_page_select.html.erb`:

```erb
<form <%= tag.attributes(component.form_attrs) %>><%= render RubyUI::NativeSelect.new(name: component.name, onchange: component.onchange) do %><% component.options.each do |option| %><option <%= tag.attributes(component.option_attrs(option)) %>><%= option %></option><% end %><% end %></form>
```

`gem/lib/ruby_ui/data_table/data_table_column_toggle.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  class DataTableColumnToggle < Component
    attr_reader :columns, :label

    def initialize(columns:, label: "Columns", **attrs)
      @columns = columns
      @label = label
      super(**attrs)
    end

    # A raw <input> in 1.6: its classes are joined, not Tailwind-merged.
    def checkbox_attrs(column)
      Attributes.flat(
        type: "checkbox",
        checked: column.fetch(:visible, true),
        class: [
          "h-4 w-4 rounded border border-input accent-primary cursor-pointer",
          "checked:bg-primary checked:text-primary-foreground dark:checked:bg-secondary checked:text-primary checked:border-primary"
        ],
        data: {
          column_key: column[:key].to_s,
          action: "change->ruby-ui--data-table-column-visibility#toggle"
        }
      )
    end

    private

    def default_attrs
      {
        class: "relative",
        data: {controller: "ruby-ui--data-table-column-visibility"}
      }
    end
  end
end
```

`gem/lib/ruby_ui/data_table/data_table_column_toggle.html.erb` — the second of the four composites decision 12 names; breaks only inside tags:

```erb
<div <%= tag.attributes(component.attrs) %>><%= render RubyUI::DropdownMenu.new do %><%=
  render RubyUI::DropdownMenuTrigger.new do %><%=
    render RubyUI::Button.new(variant: :outline, size: :sm) do %><%= component.label %><svg
      xmlns="http://www.w3.org/2000/svg"
      width="16"
      height="16"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      class="w-4 h-4 ml-1"
    ><polyline points="6 9 12 15 18 9"></polyline></svg><% end %><% end %><%=
  render RubyUI::DropdownMenuContent.new do %><%
    component.columns.each do |column| %><label class="flex items-center gap-2 rounded-sm px-2 py-1.5 text-sm cursor-pointer hover:bg-accent"><input <%= tag.attributes(component.checkbox_attrs(column)) %>><span><%= column[:label] %></span></label><%
    end %><% end %><% end %></div>
```

`gem/lib/ruby_ui/data_table/data_table_sort_head.rb`:

```ruby
# frozen_string_literal: true

require "cgi"

module RubyUI
  class DataTableSortHead < Component
    attr_reader :label

    def initialize(column_key:, label:, sort: nil, direction: nil, sort_param: "sort", direction_param: "direction", page_param: "page", path: "", query: {}, **attrs)
      @column_key = column_key
      @label = label
      @sort = sort
      @direction = direction
      @sort_param = sort_param
      @direction_param = direction_param
      @page_param = page_param
      @path = path
      @query = query.to_h.transform_keys(&:to_s)
      super(**attrs)
    end

    def sort_href
      qs = build_query(next_params)
      qs.empty? ? @path : "#{@path}?#{qs}"
    end

    # Through Attributes.flat, so the href keeps Phlex's guard: a path that
    # decodes to javascript: is dropped, not written.
    def anchor_attrs
      Attributes.flat(href: sort_href, class: "inline-flex items-center gap-1 text-inherit no-underline hover:text-foreground transition-colors")
    end

    def icon_class
      current_direction ? "inline-block w-3 h-3" : "inline-block w-3 h-3 opacity-30"
    end

    # The lucide polylines: chevron-up, chevron-down, or chevrons-up-down.
    def icon_points
      case current_direction
      when "asc" then ["18 15 12 9 6 15"]
      when "desc" then ["6 9 12 15 18 9"]
      else ["8 15 12 19 16 15", "8 9 12 5 16 9"]
      end
    end

    private

    def current_direction
      (@sort.to_s == @column_key.to_s) ? @direction : nil
    end

    def next_params
      next_dir = {nil => "asc", "asc" => "desc", "desc" => nil}[current_direction]
      base = @query.except(@sort_param, @direction_param, @page_param)
      next_dir ? base.merge(@sort_param => @column_key.to_s, @direction_param => next_dir) : base
    end

    def build_query(hash)
      hash.flat_map { |k, v|
        Array(v).map { |val| "#{CGI.escape(k.to_s)}=#{CGI.escape(val.to_s)}" }
      }.join("&")
    end
  end
end
```

`gem/lib/ruby_ui/data_table/data_table_sort_head.html.erb` — the third composite; the label sits directly against the `<svg>` as 1.6's `plain @label` did:

```erb
<%= render RubyUI::TableHead.new(class: "text-foreground whitespace-nowrap", **component.mixed_attrs) do %><a <%= tag.attributes(component.anchor_attrs) %>><%= component.label %><svg
  xmlns="http://www.w3.org/2000/svg"
  width="12"
  height="12"
  viewBox="0 0 24 24"
  fill="none"
  stroke="currentColor"
  stroke-width="2"
  stroke-linecap="round"
  stroke-linejoin="round"
  class="<%= component.icon_class %>"
><% component.icon_points.each do |points| %><polyline points="<%= points %>"></polyline><% end %></svg></a><% end %>
```

`gem/lib/ruby_ui/data_table/data_table_pagination.rb`:

```ruby
# frozen_string_literal: true

require "cgi"
require_relative "data_table_manual_adapter"
require_relative "data_table_pagy_adapter"
require_relative "data_table_kaminari_adapter"

module RubyUI
  class DataTablePagination < Component
    attr_reader :prev_label, :next_label

    def initialize(with: nil, pagy: nil, kaminari: nil, page: nil, per_page: nil, total_count: nil, page_param: "page", path: "", query: {}, window: 1, prev_label: "<", next_label: ">", **attrs)
      @adapter = resolve_adapter(with:, pagy:, kaminari:, page:, per_page:, total_count:)
      @page_param = page_param
      @path = path
      @query = query.to_h.transform_keys(&:to_s)
      @window = window
      @prev_label = prev_label
      @next_label = next_label
      super(**attrs)
    end

    # 1.6 returned before rendering anything for a single page.
    def paginate?
      total > 1
    end

    def current = @adapter.current_page

    def total = @adapter.total_pages

    def page_href(p)
      qs = build_query(@query.merge(@page_param => p.to_s))
      qs.empty? ? @path : "#{@path}?#{qs}"
    end

    def windowed_pages
      return (1..total).to_a if total <= 7
      pages = [1]
      pages << :gap if current - @window > 2
      ((current - @window)..(current + @window)).each { |p| pages << p if p > 1 && p < total }
      pages << :gap if current + @window < total - 1
      pages << total
      pages
    end

    private

    def resolve_adapter(with:, pagy:, kaminari:, page:, per_page:, total_count:)
      return with if with
      return RubyUI::DataTablePagyAdapter.new(pagy) if pagy
      return RubyUI::DataTableKaminariAdapter.new(kaminari) if kaminari
      if page && per_page && total_count
        return RubyUI::DataTableManualAdapter.new(page:, per_page:, total_count:)
      end
      raise ArgumentError, "DataTablePagination requires one of: with:, pagy:, kaminari:, or page:+per_page:+total_count:"
    end

    def build_query(hash)
      hash.flat_map { |k, v|
        Array(v).map { |val| "#{CGI.escape(k.to_s)}=#{CGI.escape(val.to_s)}" }
      }.join("&")
    end
  end
end
```

`gem/lib/ruby_ui/data_table/data_table_pagination.html.erb` — the fourth composite, and the rootless one: nothing at all when `paginate?` is false (the layer drops the file's final newline, so the output is `""`). The two disabled `<li>`s, the numbered items and the gap follow 1.6's `prev_item`, `number_items`, `next_item` in that order:

```erb
<% if component.paginate? %><%= render RubyUI::Pagination.new(class: "mx-0 w-auto justify-end", **component.mixed_attrs) do %><%=
  render RubyUI::PaginationContent.new do %><%
    if component.current <= 1 %><li><span class="opacity-50 pointer-events-none px-3 h-9 inline-flex items-center text-sm"><%= component.prev_label %></span></li><%
    else %><%= render RubyUI::PaginationItem.new(href: component.page_href(component.current - 1)) do %><%= component.prev_label %><% end %><%
    end %><%
    component.windowed_pages.each do |page| %><%
      if page == :gap %><%= render RubyUI::PaginationEllipsis.new %><%
      else %><%= render RubyUI::PaginationItem.new(href: component.page_href(page), active: page == component.current) do %><%= page %><% end %><%
      end %><%
    end %><%
    if component.current >= component.total %><li><span class="opacity-50 pointer-events-none px-3 h-9 inline-flex items-center text-sm"><%= component.next_label %></span></li><%
    else %><%= render RubyUI::PaginationItem.new(href: component.page_href(component.current + 1)) do %><%= component.next_label %><% end %><%
    end %><% end %><% end %><% end %>
```

```bash
for f in lib/ruby_ui/data_table/*.html.erb; do printf "%s %s\n" "$(tail -c1 "$f" | xxd -p)" "$f"; done
```

Expected: fourteen lines, `0a` before every path.

- [ ] **Step 4: Run the data_table scenarios, the ported tests, then everything**

```bash
bundle exec rake test N=/test_data_table__/ 2>&1 | grep -E "runs,|Failure:|Error:"
```

Expected: `7 runs, … 0 failures, 0 errors, 0 skips` — all seven now ERB-only. `full_frame`'s strict form holds three `<form` elements (follow-up issue 1, #537); the port keeps all three, and each sidecar compiles alone, so Herb sees none of the nesting.

```bash
bundle exec rake test N="/^RubyUI::DataTable(SearchTest|PerPageSelectTest|ColumnToggleTest|SortHeadTest|PaginationTest)#/" 2>&1 | grep -E "runs,"; bundle exec rake golden 2>&1 | grep -E "runs,"; bundle exec rake test 2>&1 | grep -E "runs,"; bundle exec standardrb
```

Expected: `29 runs, … 0 failures`, `388 runs`, `777 runs`, `426 files inspected, no offenses detected`.

- [ ] **Step 5: Rebuild the registry, run the guards, commit**

```bash
cd ../mcp && bundle exec exe/ruby-ui-mcp-build && cd .. && git diff --stat mcp/data/registry.json && git status --porcelain gem/test/golden/snapshots gem/test/golden/strict gem/test/golden/views && git diff --quiet v2/fixtures -- 'gem/lib/ruby_ui/**/*.js' && echo clean
git add gem/lib/ruby_ui/data_table gem/test/ruby_ui/data_table_search_test.rb gem/test/ruby_ui/data_table_per_page_select_test.rb gem/test/ruby_ui/data_table_column_toggle_test.rb gem/test/ruby_ui/data_table_sort_head_test.rb gem/test/ruby_ui/data_table_pagination_test.rb gem/test/golden/scenarios.rb mcp/data/registry.json
git commit -m "[Feature] RubyUI 2.0: DataTable — search, per-page select, column toggle, sort head and pagination

The five composites: sidecars that render Phlex neighbours (Input,
NativeSelect, DropdownMenu, Button, TableHead, Pagination) with the
arguments 1.6 passed, forward mixed_attrs where 1.6 forwarded attrs, and
keep the loops and branches in ERB with breaks only inside tags
(decision 12). DataTablePagination renders nothing for a single page.
DataTablePerPageSelect keeps its inline onchange through Phlex's
SafeValue while NativeSelect is Phlex; the comment says when it goes.

The seven DataTable scenarios are identical to their snapshots in both
forms, nested forms and all (#537 is ported, not fixed); the three
controllers and the three adapters are unedited. With this commit the
golden Phlex lane has 166 scenarios left, none from Phase 2.1.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

## Task 8: Record decisions 11–15, amend the spec, the catalog header and follow-up 1

**Files:**
- Modify: `design/v2/decisions.md` (append five entries after entry 10)
- Modify: `design/2026-09-19-rubyui-2-0-design.md` — §4.3 (the bullet list, lines 144–170), §6 "2.0 Foundation" (the `docs/Gemfile` bullet, lines 325–327), §6 "2.1 The hard components first" (lines 334–355), §6 "2.2 The bulk" definition of done (lines 361–367), §9.2 (lines 653–666)
- Modify: `gem/test/golden/scenarios.rb` (header comment only)
- Modify: `design/v2/follow-up-issues.md` (item 1's "2.0 note")

- [ ] **Step 1: Append the five entries to `design/v2/decisions.md`**

```markdown

## 11. `attrs` stays flat; `mixed_attrs` is the hash a component forwards — 2026-09-20

Spec §4.3 made `attrs` the flat, String-keyed hash `tag.attributes` consumes.
1.6 components also *forward* their attributes in Ruby — `Checkbox.new(**attrs)`
in `DataTableRowCheckbox` and `DataTableSelectAllCheckbox`,
`TableHead.new(class: …, **attrs)` in `DataTableSortHead`,
`Pagination.new(class: …, **attrs)` in `DataTablePagination`,
`attrs.merge(form_attrs)` in `DataTableSearch` and `DataTablePerPageSelect`,
`**attrs` into `Toggle` from `ThemeToggle`; across the gem, `Button(**attrs)`
in `SidebarTrigger`, `CarouselNext` and `CarouselPrevious`, `Sheet(**attrs)`
in `MobileSidebar`, `Input(**attrs)` in `SidebarInput` and `MaskedInput`,
`Separator(**attrs)`, the three sidebar variants, `render RubyUI::Button.new(**attrs)`
in `AlertDialogAction` and `AlertDialogCancel`, `attrs.merge` in `Switch`, and
`attrs[:class]` in `PaginationItem`. Measured before the first migration
(plan 2.1, probes 1a/1b): forwarding the flat hash into a Phlex neighbour puts
`"data-action"` beside the neighbour's `data: {action:}` and two `data-action`
attributes reach the page, where 1.6's `mix` concatenated them.

**Decision.** `Component` keeps the nested, Symbol-keyed hash after `mix` and
the class merge — exactly 1.6's `attrs` — as `mixed_attrs`, frozen; `attrs`
stays the flat form. A forwarding site changes `**attrs` to `**mixed_attrs`
(and a merge before a raw element becomes `Attributes.flat({…}.merge(mixed_attrs))`);
a sidecar never needs it. **Alternative rejected:** making `attrs` nested
again and giving the sidecar another name for the flat form — it would change
the idiom in every sidecar (about 200 by the end of Phase 2.2) to spare 17
Ruby sites, and the spec, the layer's tests and the probes already use
`tag.attributes(component.attrs)`. **What would reverse it:** a 2.2 batch
finding a forwarding shape `mixed_attrs` cannot express.

## 12. Sidecars are whitespace-tight; a line breaks only inside a tag; the layer drops the file's final newline — 2026-09-20

Decision 10 left the sidecar layout to the first sidecar. Measured under the
same Herb 0.10.4 (plan 2.1, probe 4 and the r-series in its Appendix A): a
break inside an ERB tag — after `<%=` or `<%`, before `%>`, in a block-closing
`<% end %>` too — emits nothing; a break inside an HTML start tag, between two
attributes, is not text either; everything else between `>` and `<` is. And the
sidecar *file's* final newline is output: rendered inside a parent it becomes a
text node after the component (`<b><i>B</i>\n</b>`) — the whitespace Phlex
never emitted, in every composition, from a newline no editor lets a file omit.

**Decision.** (a) A sidecar has no whitespace between `>` and `<` and none at
a text–element boundary; a line breaks only inside an ERB tag or inside a
start tag between two attributes, so the Ruby and the attribute lists are
indented and the markup stays tight; it carries no trim marker (`-%>`,
`<%-`) — Herb honours them only partly (decision 10), and one on the last tag
would already have removed the file's newline, leaving (b) to eat the
content's own. (b) `Component#render_in` removes one trailing newline from the
sidecar's rendered output when the template source ends with one, so the file
ends with a newline like any other, a rootless render is `""`, and content
that itself ends in a newline keeps it. **Alternatives weighed:** ending every
sidecar with `<%= "" -%>` — measured to work, a ritual line in every file that
users would delete; omitting the file's final newline — editors, `git diff`
and Herb's formatter all put it back; a parser-level option in ReActionView —
none exists. The four largest 2.1 sidecars — `DialogContent`,
`DataTableColumnToggle`, `DataTableSortHead`, `DataTablePagination` — were
written out in plan 2.1 and read before it executed; they are the readability
test decision 8 named.
**Cost:** Herb's formatter would reintroduce the whitespace between elements;
that is question 4 of spec §9.2 for the upstream conversation. **What would
reverse it:** the maintainer judging the composites unreadable, at which point
decision 8's alternative — a strict-lane criterion computed from the output —
is the next plan, not a looser sidecar.

## 13. A class without a sidecar renders its nearest ancestor's — 2026-09-20

Spec §6.2.1's open question. 1.6 users subclass a component to change its
defaults (`class MyButton < RubyUI::Button` with a `default_attrs` override)
and inherited `view_template`; a 2.0 subclass has no sidecar beside its own
file, and before this decision the lookup refused it (plan 2.1, probe 10).
**Decision.** `Component.template` walks the superclass chain to the first
class with a sidecar beside its own file under a component root; a class with
its own sidecar (`ToggleGroupItem < Toggle`) uses its own; a chain with none
up to `Component` raises naming every file looked for. `exists?` runs before
`find`, so an inherited sidecar costs no exception per render. A class
directly under a root (a host's `app/components/my_button.rb`) looks its
sidecar up with an empty prefix list — `File.split` gives `"."` there, which
the lookup does not resolve (plan 2.1, probe 24).
**Cost:** a misnamed sidecar on a subclass silently renders the parent's; the
error a sidecar-less chain raises names the paths tried, so the failure is
diagnosable once noticed. **What would reverse it:** a 2.2 batch finding a
component whose subclass must *not* inherit.

## 14. ThemeToggle migrates in 2.1; a migrated scenario keeps no Phlex block; the String form of an enum is a unit test — 2026-09-20

`ThemeToggle` (one class) renders `RubyUI.Toggle(…)` through `Phlex::Kit`. A
Kit defines no method for a constant that is not `Phlex::SGML` (probe 9), and a
Phlex component can render a 2.0 component only through phlex-rails with a
view context (probes 8a/8b), which the golden suite's Phlex lane does not
have. So Toggle cannot migrate without ThemeToggle: it joins 2.1 as a fifth
family (1 class, 1 scenario). The same mechanism means a migrated component's
scenarios keep no Phlex block: the ERB fixture is the only lane and the
recording lane, as the catalog already allowed. The 22 scenarios of plan 2.1
(Dialog 6, Select 2, Toggle 3, ToggleGroup 3, DataTable 7, ThemeToggle 1) are
declared with no block; none of the 188 snapshots changed. Spec §6.2.2's
"a scenario passing the String form of every enum attribute" is a unit test
(`render(size: :lg) == render(size: "lg")` and an unknown value raising), for
every enumerated argument — `DialogContent#size`, `variant` and `size` on
`Toggle` and `ToggleGroup`, `ToggleGroup`'s `type` and `orientation`, the
item-level overrides — because the golden suite is the 1.6 contract and
String coercion is 2.0 behaviour.

## 15. `docs/` pins a git ref of `main`, not RubyGems 1.6.0 — 2026-09-20

Spec §6 Phase 2.0 said to point `docs/Gemfile` at the published `ruby_ui`
1.6 while the gem migrates. Measured (plan 2.1): the published 1.6.0 gem is
21 files behind `main` — Select, DropdownMenu, Popover, Sheet, HoverCard,
Command, ContextMenu and Clipboard classes and controllers, from #506 and
#530 after the release — and the site renders `main`. A RubyGems pin would
have regressed the site and paired old markup with the checkout's newer
controllers (the docs' controller symlinks point at `../gem`;
`select_controller.js` reads a `panel` target the published `SelectContent`
lacks).
**Decision.** `gem "ruby_ui", github: "ruby-ui/ruby_ui", ref: "92f261931eb78bcc4682f4afb72b139553aba957", glob: "gem/*.gemspec"`
— `main`'s tip and the merge base of the 2.0 stack, a commit that cannot move.
`Gem.loaded_specs["ruby_ui"].gem_dir` resolves to the git checkout's `gem/`,
so the docs initializer is unchanged; Tailwind keeps scanning the
repository's `gem/lib/ruby_ui` directory (a migration keeps every class
string) and the controller symlinks keep pointing at the checkout (Phase 2
edits no controller). The pinned sources differ from the branch's only in
`context_menu_label.rb`, the Phase 1 fix `main` does not have yet.
**Cost:** the docs bundle clones the repository in CI; the pin is bumped by
hand if the site should carry a fix merged to `main` before Phase 3.3 removes
it. **What would reverse it:** a 1.6.x release cut from `main`, at which point
the RubyGems pin the spec asked for becomes equivalent.
```

- [ ] **Step 2: Amend the spec**

In `design/2026-09-19-rubyui-2-0-design.md`:

(a) §4.3, the bullet that begins `- \`attrs\` keys are Strings (\`attrs["class"]\`), the flat form \`tag.attributes\`` (lines 144–146). Replace the bullet with:

```markdown
- `attrs` keys are Strings (`attrs["class"]`), the flat form `tag.attributes`
  consumes. 1.6 code reading `attrs[:class]` — `PaginationItem` — changes one
  character. `mixed_attrs` is the nested, Symbol-keyed hash after `mix` and
  the class merge — 1.6's `attrs` — for the 17 sites that forward attributes
  to another component (`Checkbox.new(**mixed_attrs)`) or merge more in before
  serializing; forwarding the flat form would put `"data-action"` beside a
  neighbour's `data: {action:}` (decision 11).
```

(b) §4.3, after the bullet that ends `so an instance rendered twice repeated its first content.` (line 161), insert two bullets:

```markdown
- The sidecar file's final newline is not output. Every file ends with one,
  and rendered inside a parent it was a text node after the component; a
  sidecar itself emits no whitespace between elements — a line breaks only
  inside an ERB tag or inside a start tag between attributes (decision 12).
- A class with no sidecar beside its own file renders its nearest ancestor's
  — a host's `class MyButton < RubyUI::Button` keeps rendering as it did when
  it inherited `view_template`; `ToggleGroupItem < Toggle` has its own sidecar
  and uses it (decision 13).
```

(c) §6 "2.0 Foundation", the last bullet (lines 325–327, `- Point \`docs/Gemfile\` at the published \`ruby_ui\` 1.6 instead of …`). Replace it with:

```markdown
- Point `docs/Gemfile` at the gem at `main`'s commit — a git source with
  `glob: "gem/*.gemspec"` — instead of `path: "../gem"`, so the site keeps
  building and the CI Docs job stays green while the gem is mid-migration.
  Not the published 1.6.0, which is 21 files behind `main` (decision 15).
  Phase 3 reverts it.
```

(d) §6 "2.1 The hard components first" (lines 334–355). Replace the first paragraph (`Dialog (9 classes), Select (8), ToggleGroup and Toggle (3), Data Table (32). About 52 classes, …`) with:

```markdown
Dialog (8 classes), Select (8), Toggle and ToggleGroup (3), Data Table (14,
plus 3 adapters that emit no HTML) and ThemeToggle (1, pulled in because it
renders Toggle — decision 14). 34 classes, and they are the ones that
exercise everything that can go wrong: a block that receives the component, a
generated id, a component that renders no root element, a `<turbo-frame>`
root, one component forwarding its computed attributes to another, a second
attribute hash mixed for a wrapper element, merged `data-action` ordering, a
CSRF token through the view context, an inline handler for a Phlex neighbour.
```

Replace the acceptance line (`**Acceptance.** The 18 snapshots of these four components identical to the frozen contract; the 1.6 Stimulus controllers unedited.`) with:

```markdown
**Acceptance.** The 22 scenarios of these five families identical to the
frozen contract in both forms, through their ERB fixtures alone; the 1.6
Stimulus controllers unedited; every unit test ported, none deleted.
```

Replace the closing paragraph (`Decide whether a subclass inherits its parent's sidecar: …`) with:

```markdown
Decided in 2.1 (decision 13): a subclass with no sidecar of its own renders
its nearest ancestor's. Plan: `design/plans/2026-09-20-phase-2-1-hard-components-implementation.md`.
```

(e) §6 "2.2 The bulk", the definition of done (lines 361–367): change `a sidecar that emits no whitespace Phlex did not (decision 10)` to `a sidecar that emits no whitespace Phlex did not (decisions 10 and 12)`, and `a scenario passing the String form of every enum attribute` to `a unit test passing the String form of every enum attribute (decision 14)`.

(f) §9.2, after item 3, add:

```markdown
4. **Formatting whitespace-sensitive markup.** A 2.0 sidecar keeps no
   whitespace between elements, because 1.6 emitted none and a browser renders
   it in an inline context; the layout puts line breaks only inside tags
   (decision 12). Herb's formatter would reintroduce the whitespace. Is a mode
   that never adds text between `>` and `<` — Prettier's
   `htmlWhitespaceSensitivity: strict` — on the roadmap?
```

- [ ] **Step 3: The catalog header and follow-up 1**

In `gem/test/golden/scenarios.rb`, after the header paragraph that ends `that lane records and the ERB lane compares.`, add:

```ruby
#
# A scenario whose component has migrated to 2.0 declares no block: its ERB
# fixture is its only lane and the one that records (decision 14). The Phlex
# block it had is in this file's history; the fixture is its translation.
```

In `design/v2/follow-up-issues.md`, item 1, replace the `- **2.0 note:** Herb's \`NestingValidator\` will likely reject this at compile time, …` bullet with:

```markdown
- **2.0 note (amended 2026-09-20, plan 2.1):** each sidecar compiles alone,
  so Herb never sees one component's `<form>` inside another's; the DataTable
  migration ported the three forms as they are and `data_table/full_frame`
  still holds all three. The restructure is a reviewed snapshot change on the
  2.0 line, after Phase 2.1.
```

- [ ] **Step 4: Verify nothing but documentation and a comment changed, then commit**

```bash
cd gem && bundle exec rake golden 2>&1 | grep -E "runs,"; bundle exec standardrb 2>&1 | tail -1; cd .. && git status --porcelain
```

Expected: `388 runs, … 0 failures`, `426 files inspected, no offenses detected`, and exactly four modified files: `design/2026-09-19-rubyui-2-0-design.md`, `design/v2/decisions.md`, `design/v2/follow-up-issues.md`, `gem/test/golden/scenarios.rb`.

```bash
git add design/2026-09-19-rubyui-2-0-design.md design/v2/decisions.md design/v2/follow-up-issues.md gem/test/golden/scenarios.rb
git commit -m "[Documentation] RubyUI 2.0: record what Phase 2.1 decided

Decisions 11–15 in design/v2/decisions.md: attrs stays flat and
mixed_attrs is what a component forwards; sidecars break lines only
inside tags, carry no trim marker, and the layer drops the file's final
newline; a class without a sidecar renders its nearest ancestor's;
ThemeToggle joined 2.1, a migrated scenario keeps no Phlex block, and
the String form of every enumerated argument is a unit test; docs/ pins
a git ref of main because RubyGems 1.6.0 is behind it. Spec §4.3, §6
Phase 2.0, §6.2.1, §6.2.2 and §9.2 say the same; the catalog header
explains a block-less scenario; follow-up 1's Herb note is corrected —
a sidecar compiles alone, so Herb cannot see a form nested across
components.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

## Task 9: Final verification and the pull request

**Files:** none new.

- [ ] **Step 1: The whole gem, from a clean tree**

```bash
cd gem && git status --porcelain && bundle exec rake 2>&1 | grep -E "runs,|files inspected|offenses"
```

Expected: an empty status; `777 runs, … 0 failures, 0 errors, 0 skips`; `426 files inspected, no offenses detected`. Then the golden task on its own, and the registry:

```bash
bundle exec rake golden 2>&1 | grep -E "runs,"; cd ../mcp && bundle exec exe/ruby-ui-mcp-build && git diff --exit-code data/registry.json && echo "registry current"; cd ..
```

Expected: `388 runs, … 0 failures, 0 errors, 0 skips`; `registry current`.

- [ ] **Step 2: The invariants of this plan, against the branch base**

```bash
git diff --stat v2/fixtures -- gem/test/golden/snapshots gem/test/golden/strict gem/test/golden/views gem/test/golden/harness.rb gem/test/golden/catalog.rb gem/test/golden/canonical_html.rb gem/test/golden_test.rb 'gem/lib/ruby_ui/**/*.js' | tail -1
```

Expected: no output (nothing under those paths changed). Then the shape of the migration:

```bash
grep -rlE "Phlex::|view_template|< Base\b" gem/lib/ruby_ui/dialog gem/lib/ruby_ui/select gem/lib/ruby_ui/toggle gem/lib/ruby_ui/toggle_group gem/lib/ruby_ui/theme_toggle gem/lib/ruby_ui/data_table --include='*.rb' | grep -v _docs.rb
```

Expected: exactly one file, `gem/lib/ruby_ui/data_table/data_table_per_page_select.rb` (the `Phlex::SGML::SafeValue` for NativeSelect, with its comment).

```bash
ls gem/lib/ruby_ui/dialog/*.html.erb gem/lib/ruby_ui/select/*.html.erb gem/lib/ruby_ui/toggle/*.html.erb gem/lib/ruby_ui/toggle_group/*.html.erb gem/lib/ruby_ui/theme_toggle/*.html.erb gem/lib/ruby_ui/data_table/*.html.erb | wc -l
```

Expected: `34`. And the count of block-less scenarios:

```bash
grep -cE '^  scenario "[a-z_0-9]+"$' gem/test/golden/scenarios.rb; grep -cE 'scenario "content_#\{size\}"' gem/test/golden/scenarios.rb
```

Expected: `18` and `1` (18 plain declarations plus the four Dialog sizes in one line = 22).

- [ ] **Step 3: Push and open the pull request against `v2/fixtures`**

```bash
git push -u origin v2/hard-components
gh pr create --base v2/fixtures --head v2/hard-components --title "[Feature] RubyUI 2.0 — Phase 2.1: the hard components first" --body-file - <<'BODY'
## What

The first components on the 2.0 layer — Dialog (8 classes), Toggle and ToggleGroup (3), Select (8), Data Table (14 + 3 adapters untouched) and ThemeToggle (1) — each a plain Ruby class inheriting `RubyUI::Component` beside an `.html.erb` sidecar. Their 22 golden scenarios are byte-identical to the frozen 1.6 snapshots in both the canonical and the strict form, through the ERB fixtures Phase 2.0b wrote; the scenarios' Phlex blocks are gone (the Kit methods they called no longer exist). No snapshot, fixture or Stimulus controller changed.

Before any of that, `docs/` is pinned to the gem at `main`'s commit `92f2619` (a git source with `glob:`), so the site keeps building unchanged while the gem migrates (Phase 3.3 points it back). Not RubyGems 1.6.0, which is 21 files behind `main` (decision 15).

Three layer changes the first sidecars needed, each measured before it was written (plan §"What this plan measured"): `mixed_attrs`, the nested hash a component forwards to a neighbour (decision 11); `render_in` drops the sidecar file's final newline, which was reaching the page as a text node inside every parent (decision 12); a class without a sidecar renders its nearest ancestor's, so a host's `MyButton < RubyUI::Button` keeps working (decision 13). Plus `ComponentTest#erb`, an inline template compiled through Herb for unit tests.

Every unit test of the five families is ported to the ERB helper, none deleted; the enumerated arguments (`DialogContent#size`, `Toggle`/`ToggleGroup` `variant` and `size`, `ToggleGroup` `type` and `orientation`) accept their String form and refuse unknown values, with tests; `SelectValue` keeps whitespace-only content as Phlex did; `DataTableSortHead`'s href keeps Phlex's `javascript:` guard.

Decisions 11–15 recorded; spec §4.3, §6 Phase 2.0, §6.2.1, §6.2.2, §9.2 amended; follow-up 1's Herb note corrected. The plan was reviewed by Codex before execution; its ten findings, verified, are folded in (plan Appendix B).

Stacked on #554 (Phase 2.0b), which is stacked on #548 (2.0a) and #536 (the ruler).

## Why

Spec §6 Phase 2.1: the hard components first, so a design error in the layer surfaces now rather than at component 55. It did surface three (decisions 11–13), each a one-place fix.

## Test steps

From `gem/`: `bundle exec rake` → 777 runs, 0 failures, 0 skips; `bundle exec rake golden` → 388 runs (166 Phlex-lane, 188 ERB-lane, 7 coverage, 27 of the ruler's own); `bundle exec standardrb` → 426 files, no offenses. `git diff --stat v2/fixtures -- gem/test/golden/snapshots gem/test/golden/strict gem/test/golden/views 'gem/lib/ruby_ui/**/*.js'` → empty. `cd mcp && bundle exec exe/ruby-ui-mcp-build && git diff --exit-code data/registry.json` → clean. The CI Docs job builds `docs/` against the gem at `main`'s `92f2619`.

Read first: the four composite sidecars — `dialog_content.html.erb`, `data_table_column_toggle.html.erb`, `data_table_sort_head.html.erb`, `data_table_pagination.html.erb` — they are decision 12's readability test.

Plan: `design/plans/2026-09-20-phase-2-1-hard-components-implementation.md`.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
BODY
```

- [ ] **Step 4: Watch CI**

```bash
gh pr checks --watch
```

Expected: `Gem (Ruby 3.3)`, `Gem (Ruby 3.4)`, `Docs (Rails)`, `MCP (Ruby 3.3)`, `MCP (Ruby 3.4)` and `MCP registry up to date` green. A red Docs job is investigated from its log before anything is changed: the only intended change there is the pin, and the failure is either the pin (report it) or something the job already had (report that).

- [ ] **Step 5: Report**

To the maintainer: the PR URL, the six CI results, the three counts (777 / 388 / 426), the one `Phlex` reference that remains (`DataTablePerPageSelect#onchange`) and the items under "Not in this plan" that are now next.

---

## Definition of done for Phase 2.1

- `docs/Gemfile` at the gem at `main`'s `92f2619` (git source, `glob: "gem/*.gemspec"`); the pinned `lib/ruby_ui` differs from the branch's only in `context_menu_label.rb`; the CI Docs job green on it.
- 34 sidecars beside 34 `RubyUI::Component` subclasses under `dialog/`, `select/`, `toggle/`, `toggle_group/`, `theme_toggle/`, `data_table/`; no `view_template`, no `< Base`, no Phlex reference in those directories except `DataTablePerPageSelect#onchange`.
- `bundle exec rake golden`: 388 runs, 0 failures — 22 scenarios ERB-only and identical to their canonical and strict snapshots; 188 snapshots and 188 fixtures unchanged from `v2/fixtures`.
- `bundle exec rake`: 777 runs, 0 failures, 0 skips; `426 files inspected, no offenses detected`; `mcp/data/registry.json` current.
- The layer: `mixed_attrs`, the source-guarded trailing-newline drop, the ancestor walk with the root-level prefix, `ComponentTest#erb` and `#descriptor`, each with its test; `component.rb` at about 170 lines and `attributes.rb` at 244 — the 500-line ceiling of §4.3 applies to the two together.
- Every unit test of the five families ported and green (Dialog 10, Toggle 11, ToggleGroup 13, ThemeToggle 3, Select 3, DataTable 50); the 23 new tests green (9 layer, 2 Dialog, 7 Toggle family, 3 SelectValue, 1 CSRF, 1 `javascript:` href); no test deleted.
- No Stimulus controller, `harness.rb`, `catalog.rb`, `canonical_html.rb` or `golden_test.rb` changed.
- `design/v2/decisions.md` entries 11–15; spec §4.3, §6 Phase 2.0, §6.2.1, §6.2.2, §9.2 amended; the catalog header; follow-up 1's note.
- Every STOP (a faithful port that does not match; a shifted id; a Herb rejection of 1.6 markup) reported to the maintainer, none patched around.

## Not in this plan

- **The other 47 components** — Phase 2.2, in batches, under the definition of done in spec §6.2.2 as amended here. The sidecar rules and the "When a golden test fails" protocol of this plan carry over unchanged.
- **`NativeSelect`'s `onchange` and inline handlers in general.** `RubyUI::Attributes` ports Phlex's guards without Phlex's `SafeObject` bypass, so a 2.0 `NativeSelect` cannot receive `onchange:` at all. Phase 2.2 decides, when NativeSelect migrates, between a safe-value marker in `Attributes` and a Stimulus action in `DataTablePerPageSelect` with a reviewed snapshot change, and records it.
- **Follow-up issue 1 (#537), DataTable's nested forms.** Ported as they are; the restructure is a reviewed snapshot change on the 2.0 line, separate from any migration.
- **The component generator copying `.html.erb`.** `ComponentGenerator#components_file_paths` globs `*.rb`; a migrated component installed with the 1.6 generator would arrive without its sidecar. Phase 2.4 rewrites the generator and the installer together (spec §6.2.4); until then the 2.0 line installs nothing.
- **`Component` → `Base`, the gemspec's runtime dependencies, the fresh-app install script** — Phase 2.4 (decisions 6 and 9).
- **Herb's formatter and the whitespace-tight layout** — spec §9.2 question 4, for the upstream conversation; decision 12 records what would change here if the answer is no.
- **Bumping the docs pin.** The site stays on `main`'s `92f2619` until Phase 3.3; a fix merged to `main` in the meantime (the ContextMenuLabel fix, once #536 merges) reaches the site only if the `ref:` is bumped by hand, a one-line change plus `bundle lock`.
- **A browser look at any of the 36 components** — Phase 3 (spec §9.4).

## Appendix A — Probe sources and outputs

Measured 2026-09-20 on `v2/fixtures` at `8ac23ac`, Ruby 4.0.2, `reactionview (0.4.1)`, `herb (0.10.4)`, `phlex (2.4.1)`, `phlex-rails (2.4.0)`, `actionview (8.1.3.1)`. Probe components lived under `gem/tmp/probe2N/ruby_ui/probes2N/` (added to `RubyUI.component_roots` at runtime) and probe views under `gem/tmp/probe2N/views/`, both under `Rails.root` so ReActionView compiled them through Herb; rendered with `RubyUI::TestApp.view("<gem>/tmp/probe2N/views").render(template: …)` or `.render(component)` after `require "test_helper"`, then deleted. `class="…"` attributes are shortened in the outputs below; nothing else is altered.

**1a / 1b — forwarding into a Phlex neighbour.** Two probe classes with `DataTableRowCheckbox`'s `default_attrs` (`name: "ids[]", value: 42, aria_label: …, data: {"ruby-ui--data-table-target": "rowCheckbox", action: "change->ruby-ui--data-table#toggleRow"}`), one exposing the nested hash (`Attributes.mix(default_attrs, attrs)`) and one only `attrs`; sidecars `<%= render RubyUI::Checkbox.new(**component.nested) %>` and `<%= render RubyUI::Checkbox.new(**component.attrs) %>`. Compared in strict form with `Phlex::HTML.new.call { RubyUI.DataTableRowCheckbox(value: 42) }`: nested `true`, flat `false`. The flat output:

```
<input type="checkbox" data-ruby-ui--form-field-target="input" data-ruby-ui--checkbox-group-target="checkbox" data-action="change->ruby-ui--checkbox-group#onChange change->ruby-ui--form-field#onInput invalid->ruby-ui--form-field#onInvalid" class="…" name="ids[]" value="42" aria-label="Select row 42" data-ruby-ui--data-table-target="rowCheckbox" data-action="change->ruby-ui--data-table#toggleRow">
```

against Phlex's single `data-action="change->ruby-ui--checkbox-group#onChange change->ruby-ui--form-field#onInput invalid->ruby-ui--form-field#onInvalid change->ruby-ui--data-table#toggleRow"`.

**2 — `yield(self)` and `helpers.render`.** A probe `Group < Component` with `def Item(**kw, &block) = helpers.render(RubyUI::Button.new(**kw), &block)` and `def Div(**kw, &block) = helpers.render(RubyUI::Probes::Div.new(**kw), &block)`, sidecar `<div <%= tag.attributes(component.attrs) %>><%= component.content %></div>`, view `<%= render RubyUI::Probes21::Group.new do |g| %><%= g.Item(variant: :outline) { "L" } %><%= g.Div(id: "d") { "M" } %><% end %>` → `<div ><button type="button" class="…">L</button><div class="probe" data-probe="" id="d">M</div>\n</div>` (the `\n` is `Probes::Div`'s sidecar newline, row r10). The Button's strict form is included in the strict form of `RubyUI.Button(variant: :outline) { "L" }` rendered by Phlex.

**3 — `SafeValue` and `<option>`.** Sidecar `<form action="/x" method="get"><%= render RubyUI::NativeSelect.new(name: "per_page", onchange: Phlex::SGML::SafeValue.new("this.form.requestSubmit()")) do %><% component.options.each do |opt| %><option <%= tag.attributes(component.option_attrs(opt)) %>><%= opt %></option><% end %><% end %></form>` with `options = [5, 10]` and `option_attrs(opt) = Attributes.flat({value: opt.to_s, selected: (opt == 10) || nil})` → strict-identical to `RubyUI.DataTablePerPageSelect(path: "/x", value: 10, options: [5, 10])`; the output carries `onchange="this.form.requestSubmit()"` and `<option value="10" selected="selected">10</option>`.

**4 — tags.** View source and output:

```
SRC "<li><span class=\"x\">&lt;</span></li><dialog\n  class=\"a b\"\n  data-action=\"click->x#y\"\n><svg\n  width=\"15\" viewbox=\"0 0 15 15\"\n><path d=\"M1 1\" fill-rule=\"evenodd\"></path></svg><span class=\"sr-only\">Close</span></dialog>"
OUT "<li><span class=\"x\">&lt;</span></li><dialog\nclass=\"a b\"\ndata-action=\"click->x#y\"\n><svg\nwidth=\"15\" viewbox=\"0 0 15 15\"\n><path d=\"M1 1\" fill-rule=\"evenodd\"></path></svg><span class=\"sr-only\">Close</span></dialog>"
```

Compiled under `:raise`; the newlines are inside start tags and the parser sees no text between elements.

**5a / 5b / 5c — inline templates.** `ActionView::Template.new("<div><span></div>", "#{Rails.root}/inline.html.erb", handler, locals: [], format: :html).render(view, {})` → `ActionView::SyntaxErrorInTemplate`. `view.render(inline: "<div><span></div>")` → rendered (Erubi). `ActionView::Template.new(%(<%= render RubyUI::Probes::Div.new do %>Hello<% end %>), …).render(view, {})` → `<div class="probe" data-probe="">Hello</div>\n` (the `\n` again from the probe sidecar).

**6 — booleans.** `view.tag.attributes({"checked" => "", "selected" => "", "disabled" => "", "aria-hidden" => ""})` → `checked="checked" selected="selected" disabled="disabled" aria-hidden=""`. `CanonicalHtml.call(%(<input checked="checked" disabled="disabled">), strict: true) == CanonicalHtml.call(%(<input checked disabled>), strict: true)` → `true`.

**7 — nested Ruby-side render.** `v.render(RubyUI::Probes::Div.new(id: "o")) { v.render(RubyUI::Probes::Div.new(id: "i")) { "x" } }` → `<div class="probe" data-probe="" id="o"><div class="probe" data-probe="" id="i">x</div>\n</div>\n`.

**8a / 8b — Phlex rendering 2.0** (corrected after the Codex review: the first run bound the `{ "y" }` block to `.new`, and called `render` on `main`). `class PhlexHost < Phlex::HTML; def view_template = div { render(RubyUI::Probes::Div.new(id: "from-phlex")) { "y" } }; end`: `v.render(PhlexHost.new)` → `<div><div class="probe" data-probe="" id="from-phlex">y</div>\n</div>` — phlex-rails' `render` bridges to the view context's `render`, block included; `PhlexHost.new.call` with no view context → `NoMethodError: undefined method 'render' for nil`. So a Phlex component renders a 2.0 one only with a view context, which the golden Phlex lane does not have.

**9 — Kit.** `module KitProbe; extend Phlex::Kit; class NotPhlex < RubyUI::Component; end; class IsPhlex < Phlex::HTML; end; end` → `KitProbe.respond_to?(:NotPhlex)` `false`, `respond_to?(:IsPhlex)` `true`.

**10 — a subclass outside every root.** `class Sub < RubyUI::Probes::Div; end` in the probe script; `v.render(Sub.new) { "s" }` → `ArgumentError: Sub: /…/probe22.rb is under none of RubyUI.component_roots`.

**r-series — newlines.** Two probe components: `Box` with sidecar `<b><%= component.content %></b>` (no trailing newline) and `Boxnl` with `<i><%= component.content %></i>\n`.

```
r1  SRC "A<%= render Box.new do %>B<% end %>C"                                   OUT "A<b>B</b>C"
r2  SRC "<%= render Box.new do %>B<% end %>"                                     OUT "<b>B</b>"
r3  SRC "<%= render Box.new do %>B<% end %>\n"                                   OUT "<b>B</b>\n"
r4  SRC "<%= render Box.new do %><%= render Box.new do %>B<% end %><% end %>"    OUT "<b><b>B</b></b>"
r5  SRC "<%= render Box.new do %><%=\n  render Box.new do %>Body<% end %><%\nend %>"        OUT "<b><b>Body</b></b>"
r6  SRC "<%= render Box.new do %><%=\n  render Box.new do %>Body<%\n  end %><% end %>"      OUT "<b><b>Body</b></b>"
r7  SRC "<%= render Box.new do %>x<% end\n%>"                                    OUT "<b>x</b>"
r8  SRC "<%= render Box.new do %><% [1].each do |n| %><%=\n    n %><%\n  end %><% end %>"  OUT "<b>1</b>"
r9  SRC "<%= render Box.new do %><% if false %>a<%\n  else %>b<%\n  end %><% end %>"      OUT "<b>b</b>"
r10 SRC "<%= render Boxnl.new do %>B<% end %>"                                   OUT "<i>B</i>\n"
r11 SRC "<%= render Box.new do %><%= render Boxnl.new do %>B<% end %><% end %>"  OUT "<b><i>B</i>\n</b>"
r12 SRC "<%= render Box.new(id: \"x\") do %>B<% end -%>\nZ"                      OUT "<b>B</b>\nZ"
r13 SRC "<%= render Box.new do %>B<% end %>Z<%= render Box.new do %>C<% end %>"  OUT "<b>B</b>Z<b>C</b>"
r14 SRC "<%= render Box.new do %>B<% end %>Z"                                    OUT "<b>B</b>Z"
```

(`Box` stands for `RubyUI::Probes23::Box` in the sources.) `view.render(Box.new) { "x" }.class` → `ActiveSupport::SafeBuffer`. A first run of the r5/r6 shapes against `RubyUI::Probes::Div` showed a `\n` before the outer closing tag; it was r10's newline from Div's sidecar file, not the ERB tag — which is what made decision 12 (b) necessary.

**Probe 24 — a class directly under a root.** `ROOT/direct.rb` (`class Direct < RubyUI::Component`) with `ROOT/direct.html.erb`, `ROOT` appended to `component_roots`: `File.split("direct")` → `[".", "direct"]`; `lookup.exists?("direct", ["."], false, [:component])` → `false`; with `[""]` → `true`; with `[]` → `true`; `v.render(Direct.new)` on the 2.0a layer → `ArgumentError: Direct has no sidecar template at direct.html.erb under …/probe24`.

**Probe 25 — SelectValue, `Template#source`, the bridge.** `Phlex::HTML.new.call { RubyUI.SelectValue(placeholder: "Pick") { val } }`, span content for each `val`: `" "` → `" "`; `""` → `"Pick"`; `nil` → `"Pick"`; `"\n"` → `"\n"`; `" x"` → `" x"` — Phlex's `__yield_content__` calls `__implicit_output__` (which writes the block's return value) only when the buffer did not grow, and SelectValue's `value || @placeholder` is that return value, so the placeholder appears exactly when the block emitted nothing. `RubyUI::Probes25::Nested.template.source` → `"<em><%= component.content %></em>\n"` (`ActionView::Template`). `v.render(Nested.new) { "body\n" }` on the 2.0a layer → `"<em>body\n</em>\n"`. 8a/8b as corrected above.

**The published gem.** `gem fetch ruby_ui -v 1.6.0`, unpacked; `diff -rq lib/ruby_ui gem/lib/ruby_ui` (the branch) minus the two layer files → 21 files differ: `clipboard_{controller.js,popover.rb}`, `command_{controller.js,dialog_content.rb,dialog_controller.js}`, `context_menu_{content.rb,controller.js,label.rb}`, `dropdown_menu{.rb,_content.rb,_controller.js}`, `hover_card{.rb,_content.rb,_controller.js,_docs.rb}`, `popover_{content.rb,controller.js}`, `select_{content.rb,controller.js}`, `sheet_content{.rb,_controller.js}`. `git merge-base main v2/fixtures` → `92f261931eb78bcc4682f4afb72b139553aba957`; `git log 92f2619..main` → empty; `git log v1.6.0..92f2619 -- gem/lib` → `10c01f0 HoverCard (#530)`, `3ebfbc5 Overlays: play the exit animation before hiding (#506)`.

**docs pin, scratch copies.** (1) With `gem "ruby_ui", "1.6.0"`: `mise exec ruby@3.4.7 -- bundle lock` → three hunks (the `PATH` block gone, `ruby_ui (1.6.0)` under `GEM specs`, `ruby_ui (= 1.6.0)` under `DEPENDENCIES`) — the pin the plan first proposed and the review rejected. (2) With `gem "ruby_ui", github: "ruby-ui/ruby_ui", ref: "92f261931eb78bcc4682f4afb72b139553aba957", glob: "gem/*.gemspec"`: `mise exec ruby@3.4.7 -- bundle lock` → `Fetching https://github.com/ruby-ui/ruby_ui.git`, one hunk (the `PATH` block becomes the `GIT` block Task 1 shows), `BUNDLED WITH 2.6.4` unchanged. (3) The same git source against the local repository (`git: "file:///…/ruby_ui"`) with `bundle install` into a scratch path: `Gem.loaded_specs["ruby_ui"].gem_dir` → `…/bundler/gems/ruby_ui-92f261931eb7/gem`, `RubyUI::VERSION` → `1.6.0`, `lib/ruby_ui` present; `diff -rq` against the branch's `gem/lib/ruby_ui` minus the layer files → only `context_menu_label.rb`.

## Appendix B — The Codex review of 2026-09-20 and what was done with it

Reviewed against `8ac23ac`; the reviewer extracted the proposed implementation into a scratch tree, found all 22 strict snapshots matching and all sidecars compiling, and reported ten findings. Each was verified here before the plan changed.

| # | Finding | Verified | Change to the plan |
| --- | --- | --- | --- |
| 1 | The RubyGems 1.6.0 pin regresses the site: the published gem lacks changes `main` has, while the docs controllers and Tailwind scan the checkout | Confirmed: 21 files differ (`gem fetch` + `diff -rq`); #506 and #530 postdate the release; `select_controller.js` reads a `panel` target the published `SelectContent` lacks | Task 1 pins a git ref of `main` (`92f2619`, the merge base) with `glob:`; verification is a `diff -rq` of the pinned sources; decision 15; spec §6 Phase 2.0 amended. The Tailwind `@source` is a directory and scans `.html.erb`, so it needs no change. |
| 2 | `DataTableSortHead` writes `href="<%= sort_href %>"` and bypasses Phlex's `javascript:` guard | Confirmed: 1.6 emits `<a class=…>` with no href for `path: "javascript:alert(1)"`; `Attributes.flat` drops it too | `anchor_attrs` through `Attributes.flat`; a regression test; a global constraint: every caller-supplied attribute value goes through `flat` |
| 3 | The "new" `toggle_test.rb` and `toggle_group_test.rb` would overwrite 11 + 13 existing tests | Confirmed: the files exist (a truncated directory listing hid them when the plan was written) | Task 4 ports all 24 and adds seven; the progress table, StandardRB count and DoD recomputed |
| 4 | `own_template` misses a sidecar directly under a root (`File.split` prefix `"."`) | Confirmed: `exists?` with `["."]` false, with `[]` true (probe 24) | The prefix is normalized; a `RootProbe` directly under `test/probes` with its own test; the probe require glob widened |
| 5 | `SelectValue` with `presence` turns whitespace-only content into the placeholder, unlike 1.6 | Confirmed (probe 25): Phlex writes the placeholder only when the block emitted nothing; `" "` is kept, `""` and `nil` give the placeholder | `SelectValue#value` = `(content.nil? \|\| content.empty?) ? placeholder : content`; three content tests; the nil test keeps a nil-returning brace block |
| 6 | Literal interpolation of caller values (`id="<%= id %>"`, hidden inputs) loses Phlex's coercions (nil omitted, Symbols dasherized) | Confirmed: `DataTable.new(id: nil)` → no id; `id: :foo_bar` → `id="foo-bar"`; `ToggleGroup` `name: :foo_bar` → `name="foo-bar"` | `frame_attrs`, `hidden_input_attrs` (ToggleGroup, DataTableSearch), `token_input_attrs` through `Attributes.flat`; the sidecar rules table gains the row |
| 7 | Output-level chomping cannot tell the file's newline from the content's when the sidecar ends with a trimmed output tag | Accepted as a limitation, not reproduced: it needs a `-%>` on the sidecar's last tag | `render_in` chomps only when `template.source` ends with a newline; sidecars carry no trim marker (rule and constraint); decision 12 weighs the reviewer's alternatives (`<%= "" -%>`, no final newline); a test that content's own newline survives |
| 8 | Probe 8a bound its block to `.new`, and 8b's error came from the outer call | Confirmed: `render(X.new) { "y" }` renders `y`; the component alone raises `for nil` | Appendix A corrected; decision 14's conclusion unchanged |
| 9 | The String-form tests skipped `ToggleGroup`'s `type` and `orientation` and the item-level overrides | Confirmed by reading the plan | Three tests added in Task 4; decision 14 names every enumerated argument |
| 10 | Counts: 14 DataTable classes and 34 sidecars; 7 coverage + 27 ruler tests; 15 (now 23) new tests; `component.rb` above 160 lines; unanchored `N=` filters select other classes | Confirmed: `/DialogTest/` runs 11 (AlertDialogTest included), `/^RubyUI::DialogTest#/` runs 10 | Every count and filter recomputed; the DoD states the layer's size honestly |
