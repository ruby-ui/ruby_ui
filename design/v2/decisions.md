# RubyUI 2.0 — decisions

One entry per decision or deviation from `design/2026-09-19-rubyui-2-0-design.md`,
newest last, each with the reason. The eleven decisions taken before execution
started are in §5 and §6 of that document; this file records what happens after.

## 1. The normalizer's whitespace blind spot (§9.1) — 2026-09-19

`Golden::CanonicalHtml` does not see whitespace between two element siblings,
or at a text–element boundary, in `:normal` mode. It cannot without giving up
the fixed-point property that makes the byte comparison a structural one.

`gem/test/golden/tools/inline_adjacency.rb` lists 8 components and 50 candidate
pairs. Reading them: Badge's 27 are the `all_variants` scenario laying 28
badges side by side — an artefact of the scenario, not a composition users
write; Dialog's, Sheet's and Sidebar's 14 are the close button's icon beside
its `sr-only` label, invisible either way; Codeblock's 5 sit inside `pre`,
which the normalizer preserves verbatim; Carousel's 2 are absolutely
positioned; Command's and ContextMenu's anchors are `flex` and so block-level.
The script also cannot see the text–element case at all, which is the one that
carries behaviour — `FormField` flips on `<div></div>` versus
`<div>\n</div>`, and that is now caught by the hardened canonical form (the
`test_distinguishes_an_empty_element_from_a_whitespace_only_one` test), not by
this inventory.

**Decision.** The number is not the criterion and does not need to be
accurate. Three things are:

1. The canonical form distinguishes an empty element from a whitespace-only
   one, for every component, per the canonical form's
   `test_distinguishes_an_empty_element_from_a_whitespace_only_one` test.
2. Phase 2 sidecars are written in ERB trim mode (`<%-` / `-%>`), so the ERB
   lane emits no whitespace Phlex did not. This is a rule for all 256
   classes, not for eight.
3. Phase 2.0 defines a strict lane — raw output, attribute order normalized,
   nothing else — and every component that carries text runs through it.
   Badge, Typography, InlineCode, InlineLink, ShortcutKey and FormFieldError
   are the first entries on that list; this inventory is one way to find more.

**What would reverse this.** A Phase 2 component showing a visible spacing
difference in a browser that both lanes reported as parity. §9.4 of the design
is the reason that cannot be caught automatically before Phase 3.

## 2. Normalizer observations from the whole-branch review — 2026-09-19

Three more gaps the review of this branch surfaced in `Golden::CanonicalHtml`.

**Decision: none of the three observations below is acted on in Phase 1.**
Each is real, none changes what the ruler measures today, and each is an
input to the strict lane Phase 2.0 defines — that is where they are weighed.
What would reverse this: a Phase 2 component whose parity depends on one of
them before the strict lane exists.

**F4.** Adjacent text nodes separated only by an HTML comment
(`<div>a<!-- -->b</div>`) are not a fixed point (`a\n  b` → `a b`) and
over-strict against a browser (`ab`). Reachable only through a comment
sitting between two text runs; 1.6 emits comments only in Rails development.
Candidate fix: merge consecutive text children in `significant_children`
after dropping comments.

**F5.** §9.1's exclusion should also name whitespace runs inside text under
CSS `white-space: pre*` (no component sets `whitespace-pre*` today), and that
`combobox_controller.js` reads `input.parentElement.textContent` — so
`ComboboxItem` joins the strict-lane candidate list alongside
`FormFieldError`.

**F9.** U+00A0 is written literally by `escape_text`; a snapshot line holding
one is indistinguishable from spaces in a PR diff. No component emits it
today; escaping it to `&nbsp;` would keep review honest.

## 3. Paths chosen ahead of the upstream conversation — 2026-09-19

The maintainer meets Herb's author the following week. Rather than hold Phase 2
on the three questions in spec §9.2, a path is chosen for each now and
validated afterwards — changing course is cheap while nothing has merged to
`main`.

- **Attribute typing.** Decision B stands: the component coerces and validates
  its enum attributes (`enum` helper in `Base`); nothing depends on Herb typing
  attributes. If upstream ships typed attributes, the coercion becomes
  redundant and stays harmless.
- **Block parameters.** `ToggleGroup` and `ToastRegion` keep the ERB form
  (`render X.new do |group|`), documented as the exception to the tag syntax.
  No implicit-context redesign in 2.0. If a `<Card as |c|>` form is on Herb's
  roadmap, 2.0 waits for it; if not, the redesign is a 2.1 item.
- **herb 0.11 and the ReActionView release that accepts it.** Decision D
  stands: Herb is required from 2.0.0 via ReActionView, the gemspec constraint
  is `reactionview >= 0.4.1` with no upper bound, and the tag syntax arrives
  through `bundle update`. Only the date is open.

**Also decided the same day:** `main` stays as is. The seven 1.6 defects in
`design/v2/follow-up-issues.md` (#537–#543) are addressed on the 2.0 line, not
as 1.6 patches; the 2.0 migration therefore ports those components as they are
and fixes them with a reviewed snapshot change. Phase 2 branches from
`feat/golden-suite`, stacked on PR #536, rather than from `main`.

## 4. Decision 11 reversed: `ruby_ui:install:docs` stays — 2026-09-19

Spec §6 originally removed the docs generator in 2.0, because the 52 pages it
ships are Phlex and migrating them pulls the `VisualCodeExample` redesign into
Phase 2. The maintainer chose the other side: the generator keeps working in
2.0.0. So the pages, the six docs primitives and the redesign become Phase 2
sub-phase 2.3, and Phase 3 shrinks to the site's own chrome and pages.

**Cost accepted:** roughly 450 example files and the primitive redesign land
before the gem release instead of after it.

**What would reverse this:** sub-phase 2.3 proving larger than the component
migration itself, in which case the generator ships in 2.1 instead.

## 5. The gem's test harness is an inline Rails application — 2026-09-20

Decision A said `actionview` + `reactionview`, no controller, no dummy app.
The premise this started from — that `local_template?` treats a template
outside `Rails.root` as "external" and falls back to Erubi — doesn't hold
without an application: `Rails.root` is then `nil`, `nil.to_s` is `""`, and
every identifier `start_with?("")`, so every template counts as local. The
reasons that do hold: ReActionView's Railtie registers its ERB handler
(`ActionView::Template.register_template_handler :erb, …`) only from
`config.after_initialize`, which a Railtie runs only when a
`Rails::Application` boots, inside the `:action_view` load hook that fires
when `ActionView::Base` loads — without an application, Erubi stays the
`:erb` handler and Herb's validation never runs on anything, local or not;
and `Rails.env`
defaults to `development` unless `RAILS_ENV`/`RACK_ENV` is set (it does not
need an application, but nothing else in a bare `require "rails"` sets it
either), which turns on 1.6 `Base`'s dev comment. So the tests need a `Rails`,
and its root must be the gem. `test_helper.rb` boots the smallest
`Rails::Application` — no `app/` directory, no routes, no database — with
`config.root` at the gem and `RAILS_ENV=test`. Measured: the existing suite is
unchanged under it and `ActionView::Template.handler_for_extension(:erb)` is
ReActionView's.
**Cost if wrong:** `railties` as a development dependency and ~1 s of boot per
test run. **What would reverse it:** ReActionView registering its ERB handler
outside an application-boot initializer, at which point the app object's only
remaining job is `Rails.env`, which `ENV["RAILS_ENV"] = "test"` alone already
covers.

## 6. The 2.0 layer is `RubyUI::Component` until the last Phlex component is gone — 2026-09-20

`RubyUI::Base` is the Phlex base that 256 components inherit; the 2.0 layer
cannot take the name while they exist. It lands as `RubyUI::Component`, every
migrated component inherits `Component`, and one mechanical commit in Phase
2.4 — after the last migration, before the installer is rewritten — renames
`Component` to `Base`. Users never see `Component`. The alternative, renaming
the Phlex base first, touches all 256 files for no user benefit.
**Cost if wrong:** one sed across the migrated files at the end.

## 7. Every ERB fixture is written before any component migrates — 2026-09-20

With `phlex-rails` loaded (development only), an ERB fixture renders a
component that is still Phlex, so the ERB lane can be green for all 188
scenarios while nothing has migrated. Plan 2.0a proves it on Button's 15;
plan 2.0b writes the other 173. After that a migration changes only an
implementation, never the ruler — "did I write the fixture right" and "did I
port the component right" stop being one failure. While a scenario keeps its
Phlex block, that lane records and the ERB lane compares.
**Cost if wrong:** ~2,000 lines of ERB written ahead of the first migration.
`phlex-rails` leaves the gemspec with the last Phlex component.

## 8. The strict lane is the canonical form in preserve mode, for every scenario — 2026-09-20

Every scenario keeps a second snapshot, `CanonicalHtml.call(html, strict: true)`:
the whole fragment in the normalizer's preserve mode (text and whitespace
verbatim, attributes sorted, comments dropped, the fragment's own edges
trimmed). Same fixed-point discipline, same recording rule, same runner. The 188
strict snapshots were recorded from Phlex.

The spec named seven text-bearing components; the plan first mapped that to
five directories. Review found a sixth (Breadcrumb), and an audit of the raw
Phlex output found text inside an inline element in 38 of 54 components — any
list is one review away from missing one. So there is no list: the contract is
the literal one, *the 2.0 sidecar emits what Phlex emitted*, and Phlex never
emitted whitespace between elements. Fixtures and sidecars are written
whitespace-tight — one line, or `<%-`/`-%>` — because the strict form sees
every newline they add; the canonical form stays as the diagnostic (canonical
passes, strict fails: whitespace only).
**Cost if wrong:** 188 more files to keep, sidecars without newlines between
static elements, and strictness where a browser would not have cared (inside a
flex parent, say). **What would reverse it:** sidecars for the large composites
proving unreadable under the rule, at which point the strict lane narrows to a
criterion computed from the output (text adjacent to an element sibling) rather
than a hand-picked list.

## 9. Sidecar lookup takes a list of roots; the fresh-app script moves to 2.4 — 2026-09-20

`RubyUI.component_roots` is an Array — `lib` and `test/probes` in the gem, one
entry in a host app — and a class's sidecar is found under the root that
contains its file, through a `LookupContext` scoped to that root. Collision
with a host template is impossible by construction, and "two sidecars for one
class" cannot happen (one class file, one directory). The fresh-app install
script the spec put in Phase 2.0 moves to Phase 2.4: until the installer writes
the 2.0 initializer, the script would only exercise the 1.6 installer, which
proves nothing about 2.0.

The scoped lookup registers each root's resolver through
`ActionView::PathRegistry.cast_file_system_resolvers` — a `:nodoc:` API
present since Rails 7.1 — because that registration is what lets the
reloader's `DetailsKey.clear` and `CacheExpiry` see the sidecars; a test pins
it. ReActionView allows `actionview >= 7.0`; the 2.4 gemspec floors Rails at
7.1.

**Cost if wrong:** installation is first exercised end to end in 2.4 rather
than now.

## 10. Every ERB fixture is one line; what Herb's trim mode removes and what it keeps — 2026-09-20

Decision 8 said fixtures and sidecars are written "one line, or `<%-`/`-%>`".
Measured through the harness — a template under `Rails.root`, compiled by
ReActionView 0.4.1's handler and so by Herb 0.10.4, the engine every fixture
and every 2.0 sidecar compiles with (a `<div><span></div>` probe raised
`ActionView::SyntaxErrorInTemplate`, which Erubi would not) — trim mode does
the following. Each line is reproduced from a probe whose source and output
are in plan 2.0b's Appendix A.

- `-%>` on an output tag (`<%= … -%>`, `<%= … do -%>`) removes the newline
  after it. A statement tag (`<% … %>`) alone on its line loses the
  indentation before it and the newline after it whether or not it carries
  markers (`  <% if true %>\nA<% end %>\n` → `A\n`, exactly as with
  `<%- … -%>`); mid-line, its `-%>` is ignored — `apply_trim` consults only
  `left_trim?` and `at_line_start?`.
- The `end` that closes a `<%= … do %>` block ignores its own `-%>` and `<%-`
  for the newline after it (`Body<% end -%>\nAfter` → `Body</div>\nAfter`):
  `visit_erb_block_end_node` in `herb/engine/compiler.rb` never reads the
  end tag's `-%>`, and its `<%-` changes nothing the line-start rule does not
  already do. It trims Erubi-style — the indentation before it
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

**Cost if wrong:** six composite fixtures between 700 and 1,726 characters
on one line (`data_table/full_frame` is the longest). **What would reverse
it:** Herb honouring `-%>` on a block-closing `end` *and* dropping the
indentation before an output tag — both, since either alone still leaks
whitespace — at which point trim mode is enough and decision 8 stands as
written.
