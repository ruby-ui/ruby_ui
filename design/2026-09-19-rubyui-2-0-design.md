# RubyUI 2.0 — design

Date: 2026-09-19
Status: draft

RubyUI 2.0 replaces Phlex with plain Ruby classes and ERB sidecar templates,
compiled by Herb. This document is the design and the execution plan. It
supersedes `design/v2/00-charter.md` and `design/v2/03-plan-fase1.md` on the
`v2-herb` branch, which stay as reference.

---

## 1. Summary

A 2.0 component is a plain Ruby class next to a `.html.erb` template. The class
owns the Ruby — variants, sizes, attribute merging; the template owns the
markup. Nothing inherits from Phlex.

Callers write either form:

```erb
<%= render RubyUI::Dialog.new do %>…<% end %>   <!-- always available -->
<RubyUI::Dialog>…</RubyUI::Dialog>              <!-- when herb ships component tags -->
```

The second compiles to the first. They are the same thing, so the tag syntax is
a documentation and packaging decision, not an architectural one.

Distribution is unchanged in spirit: `rails g ruby_ui:component Dialog` copies
the class and the template into the host app, and the user owns and edits them.
What changes is that `ruby_ui` becomes a small runtime dependency instead of a
pure installer.

The work is sequenced in three phases: freeze 1.6's rendered HTML as an
executable contract, migrate the gem against that contract, then migrate the
documentation site.

## 2. Why 2.0

Phlex writes HTML in Ruby. For a component library whose value proposition is
"compose freely, restyle any part with Tailwind, you own the code", the markup
is the artifact users came for — and they read and edit it in Ruby method calls
rather than in HTML.

ERB puts the markup back in HTML, and Herb makes that HTML checkable: a
malformed sidecar fails at compile time with the tag, the line and a
suggestion, rather than silently rendering wrong. That matters most for exactly
the code we ask users to edit.

## 3. Scope

**In scope.** The 1.6 component surface, ported — 54 component directories,
256 component classes. The 52 doc-page classes the gem ships (`*_docs.rb`).
The generators and installer. The documentation site.

**Out of scope.** New components. Visual redesign. API redesign without a
written reason. A Phlex compatibility layer. A Phlex-to-ERB codemod (see
§9.3).

## 4. Architecture

### 4.1 Anatomy of a component

```
app/components/ruby_ui/dialog/
  dialog.rb             # plain Ruby: constructor, default_attrs, class tables
  dialog.html.erb       # one element, rendered with the computed attributes
  dialog_controller.js  # unchanged from 1.6
```

```ruby
module RubyUI
  class DialogContent < Base
    SIZES = { xs: "max-w-sm", sm: "max-w-md", md: "max-w-lg", lg: "max-w-2xl" }

    def initialize(size: :md, **attrs)
      @size = enum(size, SIZES, default: :md)
      super(**attrs)
    end

    private

    def default_attrs
      { data_ruby_ui__dialog_target: "dialog", class: [BASE, SIZES[@size]] }
    end
  end
end
```

```erb
<div <%= tag.attributes(component.attrs) %>><%= component.content %></div>
```

The Ruby from 1.6 carries over unchanged except for the `enum` coercion
(§5, decision B); `view_template` is deleted and its markup becomes the
sidecar.

### 4.2 Render path

```
app/views/pages/home.html.erb
  <%= render RubyUI::Dialog.new do %>…<% end %>
        │
        │ ① constant RubyUI::Dialog          → Zeitwerk (push_dir + collapse)
        │ ② render of an object              → ActionView calls #render_in
        ▼
RubyUI::Base#render_in(view_context, **, &block)
        │ ③ content = view_context.capture(self, &block)
        │ ④ view_context.render(template: …, locals: { component: self })
        ▼
app/components/ruby_ui/dialog/dialog.html.erb
        │ ⑤ compiled by the registered :erb handler
        ▼
      Herb (via ReActionView)
```

Herb participates only in ⑤, and only to validate: Erubi and Herb produce the
same HTML. The gate proved this — six Dialog snapshots byte-identical on both
lanes (`experiments/v2-gate/HERB_FINDINGS.md` on `v2-herb`).

Component tags are sugar over ②. `<RubyUI::Dialog>` is rewritten at compile
time into `render RubyUI::Dialog.new`, so nothing below ② changes.

### 4.3 The layer

Two files, promoted from `experiments/v2-gate/app/components/ruby_ui/` where
they were written and proved:

| File | Responsibility |
| --- | --- |
| `base.rb` | `initialize(**attrs)` → `attrs`; `render_in(view_context, **, &block)` → capture into `content`, render the sidecar; `template_path` derived from the class file; `helpers` (view context, render-time only) |
| `attributes.rb` | `mix` (Phlex `Helpers#mix` semantics), `merge_classes` (tailwind_merge), `flat` (Phlex 2.4.1 serialization → flat string-keyed hash for `tag.attributes`) |

226 lines at the end of the gate, against a 500-line ceiling. The ceiling
stands for 2.0. `base.rb` and `attributes.rb` are copied into the host app by
the installer, so every line is a line the user reads.

Differences from 1.6's `Base` to carry into the documentation:

- `attrs` keys are Strings (`attrs["class"]`), the flat form `tag.attributes`
  consumes. 1.6 code reading `attrs[:class]` — `PaginationItem` — changes one
  character.
- `true` serializes as `""`; Rails then emits `disabled="disabled"` for HTML
  boolean attributes and `aria-x=""` for the rest. Both canonicalize like
  Phlex's bare attribute.
- Phlex's attribute guards are not ported (unsafe `on*` names, `srcdoc`,
  `javascript:` refs, the `:id` key check). Nothing in the snapshots depends on
  them. Ported or not is a 2.0 decision, recorded here as *not ported*.
- The development-only `<!-- Before RubyUI::X -->` comment is dropped.

### 4.4 Distribution and install

`rails g ruby_ui:component Dialog` copies `dialog.rb` and `dialog.html.erb`
into `app/components/ruby_ui/dialog/`, and the Stimulus controller into
`app/javascript/controllers/ruby_ui/`, as in 1.6. `ruby_ui.gemspec` already
packages `lib/**/*`, so `.erb` ships without a change.

The initializer the installer writes:

```ruby
Rails.autoloaders.main.inflector.inflect("ruby_ui" => "RubyUI")
Rails.autoloaders.main.push_dir(Rails.root.join("app/components/ruby_ui"), namespace: RubyUI)
Rails.autoloaders.main.collapse(Rails.root.join("app/components/ruby_ui/*"))

ActiveSupport.on_load(:action_controller) do
  append_view_path Rails.root.join("app/components")
end

ReActionView.config.intercept_erb = true
ReActionView.config.validation_mode = :raise
```

`extend Phlex::Kit` is removed. Zeitwerk ignores `.html.erb`, so the sidecar
living in an autoloaded directory is inert.

**Known side effect, to be documented.** `app/components` is ViewComponent's
home directory. Making it a view path does not break ViewComponent — it
resolves its own sidecars by compiled method, not by virtual path — but it does
make templates under `app/components` resolvable by `render template:`.
`append_view_path`, not `prepend`, so RubyUI never shadows the host app's own
views.

**Runtime dependencies.** `ruby_ui` goes from zero runtime dependencies to
`tailwind_merge` and `reactionview` (which brings `herb`). The constraint on
`reactionview` must have no upper bound: 0.4.1 pins `herb >= 0.10.4, < 0.11.0`,
and an upper bound here would block users when herb 0.11 lands.

## 5. Decisions

Ten decisions, with the reason each was taken. Deviations from these during
execution go in `design/v2/decisions.md`, one line each, with the reason.

| # | Decision | Reason |
| --- | --- | --- |
| 1 | Start fresh from `main`; `v2-herb` is reference only | Its three commits have three destinations: the golden suite belongs on `main`, the research is reference, and `experiments/v2-gate` is throwaway by its own design (182 files, a second Rails app). Carrying all three forward means the 2.0 line hauls a throwaway app forever and keeps a charter whose premises this document overrides. |
| 2 | Authoring syntax is `<RubyUI::Dialog>` | Herb's design resolves a tag statically from its name, with no lookup and no registry, and its own docs state that dashed names like `<My-Component />` are left alone. A `rui-` prefix is reachable through a custom resolver, but it would make RubyUI the library that invented its own dialect. Going with the ecosystem costs verbosity and buys the formatter, the linter and the LSP for free. |
| 3 | `ruby_ui` becomes a small runtime dependency; components stay copied | The tag rewriter and the layer run inside the host app at template compile time, so something must load them there. Shipping a compiler as code the user "owns" means nobody updates it and every bug becomes a silent fork. Markup stays copied and editable, which is the product. |
| 4 | Migrate the gem entirely before the site | Maintainer decision. The cost is accepted and mitigated in §6.2: hard components first, so a design error surfaces in the first weeks rather than at component 55. |
| 5 | No codemod in 2.0 | Deferred, not rejected. Revisit once the gem migration has shown how mechanical the transformation actually is. |
| 6 | The golden suite lands on `main` in its own PR, before any 2.0 work | It protects 1.6 today — it catches regressions in ordinary bug-fix PRs. On a v2 branch it would protect nothing, and `main` and the branch would diverge in exactly the file that defines what "identical" means. `f7cbeda` is self-contained and cherry-picks cleanly. |
| 7 | **A.** Test harness is `actionview` + `reactionview`, no controller, no dummy app | Exactly one component touches the view context — `DataTableForm`, for CSRF — and it already falls back to the literal `"csrf-token-placeholder"` that the snapshots recorded. `DataTableSortHead`, the obvious candidate for needing routes, builds its URL with `CGI` from an explicit `path:`. `reactionview` is included because decision D makes Herb what users compile with; testing on Erubi would test something we do not ship, and it puts the Herb validators over every sidecar on every CI run. |
| 8 | **B.** A coercion helper in `Base`; not the `literal` gem | ~14 components index Symbol-keyed hashes with a user-supplied value and 11 already call `.to_sym`. `DialogContent` and `Badge` do not: `SIZES["lg"]` is `nil`, the class is dropped, nothing is raised. This is a 1.6 bug reachable from `params`, independent of any tag syntax. `Literal::Enum#coerce` looks up by member value and never treats `"lg"` and `:lg` as equivalent, so it does not remove the coercion — it would earn its place only as a full object model (`Base < Literal::Object`, `prop` replacing every constructor), which is a second large migration stacked on the first. Recorded as a legitimate 3.0 direction. |
| 9 | **C.** Sidecar next to the class, reached through `append_view_path` | Keeps class, template and Stimulus controller in one directory, as 1.6 already keeps class and controller. Proved in the gate in development with reloading and in production with eager loading. `append` rather than `prepend` so the library never shadows the host app. |
| 10 | **D.** Herb is required from 2.0.0, through ReActionView | Verified on released Rails (§8): `rails 8.1.3.1 + reactionview 0.4.1 + herb 0.10.4` resolves, boots, renders, runs custom transform visitors, and rejects malformed HTML at compile time. Every user gets validation from day one, and when herb ships component tags every user gets the tag syntax through `bundle update` — no reinstall, no migration. The accepted cost: two pre-1.0 gems become required, and `intercept_erb` compiles the whole host app through Herb, so a user with malformed HTML anywhere sees it on install day. |

## 6. Phases

### Phase 1 — The ruler

**Goal.** A golden suite green on `main`, covering all 54 component
directories, validated against today's code.

The suite renders every component in the 1.6 catalog, reduces each render to a
canonical form and compares it to a committed snapshot. Its output is the thing
everything else depends on: **once recorded, the 186 snapshots are the frozen
contract of 1.6's rendered HTML, and the Phlex source can be deleted.** Phase 2
compares against the snapshot, not against a running Phlex component.

**Steps.**

1. Branch from `main`. Cherry-pick `f7cbeda`: `canonical_html.rb` (the
   executable definition of "acceptable difference"), `catalog.rb` (the
   `component`/`scenario` DSL), `harness.rb` (pins the two sources of
   randomness), `scenarios.rb` (the catalog), `golden_test.rb` (the runner),
   the rake task, and `nokogiri` as a development dependency.
2. Record the snapshots **fresh** against current `main`. Do not copy the 186
   from `v2-herb`.
3. Diff the fresh recording against `v2-herb`'s. `main` has moved nine commits
   since the branch point and exactly one touches a component —
   `10c01f0 [Bug Fix] HoverCard: let the card escape a clipping ancestor (#530)`.
   **Acceptance: only HoverCard differs, and every diff is explained by #530.**
   Any other diff is investigated before proceeding.
4. Resolve the whitespace question (§9.1) with a measurement, not a guess.
5. PR to `main`.

**Acceptance.** `cd gem && bundle exec rake` green on Ruby 3.3 and 3.4. Every
directory under `lib/ruby_ui/` has at least one scenario; every `RubyUI::Base`
subclass is reached; no snapshot file is orphaned; the normalizer is idempotent
over all snapshots; every scenario renders identically twice.

**No decision in this phase depends on anything else in this document.** The
ruler is pure 1.6 — it does not know what the layer, the syntax or Herb are.
That is why it goes first, and it means Phase 1 can start before the Herb
conversation happens.

### Phase 2 — The gem

#### 2.0 Foundation

No component work. Builds the apparatus and closes the four decisions above in
code.

- Promote `Base` and `Attributes` into `gem/lib/ruby_ui/`, with tests of their
  own and the differential test against Phlex 2.4.1 kept.
- Replace the test harness: `actionview` as a development dependency
  (`reactionview` is already a runtime one, §4.4); a minimal `ActionView::Base`
  with a view path into `gem/lib/ruby_ui`, with ReActionView's handler
  registered so tests compile exactly as users will.
  `ComponentTest#phlex { }` is replaced by rendering an ERB fixture.
- Add the **ERB lane** to the golden suite: the 186 scenarios become
  `.html.erb` fixtures under `gem/test/golden/views/`, rendered through the 2.0
  component and compared against the frozen snapshot.
- Implement the `enum` coercion helper in `Base`.
- Point `docs/Gemfile` at the published `ruby_ui` 1.6 instead of
  `path: "../gem"`, so the site keeps building and the CI Docs job stays green
  while the gem is mid-migration. Phase 3 reverts it.

**Acceptance.** The layer is in the gem with its own tests. The ERB lane runs
with at least one component at parity. A component renders in a real Rails 8.1
application. All three CI jobs are green.

#### 2.1 The hard components first

Dialog (9 classes), Select (8), ToggleGroup and Toggle (3), Data Table (32).
About 52 classes, and they are the ones that exercise everything that can go
wrong: a block that receives the component, a generated id, a component that
renders no root element, a `<turbo-frame>` root, one component reading
another's computed `attrs`, a `style:` hash, merged `data-action` ordering.

Dialog is already proved. The other three are not.

**Known limitation.** `ToggleGroup` and `ToastRegion` call `yield(self)`, and
Herb's component-tag visitor emits a bare `do` with no block parameter, so they
cannot be written as tags. They keep the `render X.new do |group|` form, which
stays available and documented. This is item 2 of §9.2.

**Acceptance.** The 18 snapshots of these four components identical to the
frozen contract; the 1.6 Stimulus controllers unedited.

#### 2.2 The bulk

The remaining ~50 components, in batches.

**Definition of done, per component.** A plain Ruby class with no Phlex; a
sidecar; the snapshot matching; a scenario passing the String form of every
enum attribute; the Stimulus controller untouched.

#### 2.3 Generators and installer

`component_generator.rb` copies `.rb` and `.html.erb`. `install_generator.rb`
writes the initializer of §4.4 and copies `base.rb` and `attributes.rb`.
`dependencies.yml` is unchanged — it describes JS packages. The gemspec drops
`phlex` and gains `tailwind_merge` and `reactionview` as runtime dependencies.

#### 2.4 Release

Version, CHANGELOG, and the manual migration guide. At this point the
documentation site is still Phlex; the announcement has to say so.

### Phase 3 — The site

144 Ruby files under `docs/app`, 10,383 lines in `app/views`, 68 page files
under `app/views/docs` (58 at the top level, 10 in subdirectories), and not one
`.erb`.

**The component doc pages are a gem artifact, not a site artifact.** This is
easy to miss and it moves work across the phase boundary:

```
gem/lib/ruby_ui/button/button_docs.rb     52 files, the source
      │  rails g ruby_ui:install:docs  (strips _docs, copies)
      ▼
docs/app/views/docs/button.rb             the installed copy
```

`DocsGenerator` ships the doc pages to any host app, so they are part of the
library surface. The site's copies are copies, not symlinks — unlike the
Stimulus controllers — and **10 of the 52 have already drifted from their
source**. Migrating a doc page is therefore gem work with a site consumer, and
the drift should be resolved in the same pass rather than carried into 2.0.

Whether the doc pages should keep shipping in the gem at all is an open
question for this phase: they are the only part of the gem that is neither a
component nor a generator.

#### 3.0 Redesign `VisualCodeExample`

Today a doc page passes a heredoc of Phlex source to
`Docs::VisualCodeExample`, which `eval`s it in the page's context to render the
live preview and prints the same string as the code sample. In 2.0 the example
is ERB, not Ruby, so `eval` cannot survive.

**Each example becomes a real `.html.erb` file.** The page renders the file for
the preview and reads the same file from disk for the code block. The `eval`
goes away, the example is genuinely compiled — so the tag syntax works in
examples — and what is on screen is literally what is in the file. Roughly 450
files of one to five lines each.

#### 3.1 Move the documentation primitives out of the gem

`gem/lib/ruby_ui/docs/` holds six Phlex classes — `visual_code_example`,
`header`, `components_table`, `component_setup_tabs`, `sidebar_examples`,
`base`. They are site infrastructure, not library surface, and they are already
excluded from the gem's test autoload. They move to `docs/app/`. Check
`mcp:build` for a dependency on them first.

#### 3.2 Chrome and layout

`Views::Base`, layouts, navigation, marketing pages — the ~86 Ruby files that
are not component pages.

#### 3.3 The pages

The 52 `_docs.rb` sources in the gem, plus the 16 site-only pages
(installation, theming and the rest). Depends on 3.0 and 3.2. Mechanical and
large. Each of the 10 drifted pages is reconciled against its source as it is
migrated, with the reason for the drift recorded.

#### 3.4 Close-out

`docs/Gemfile` points back at `path: "../gem"`; `phlex` and `phlex-rails` come
out; `mcp/data/registry.json` is rebuilt; the CI Docs job is green without the
pin.

**Acceptance.** No view `.rb` under `docs/app/views`; no `_docs.rb` left in the
gem; no mention of phlex in `docs/Gemfile.lock`; all 68 pages rendering; no
drift between a doc page in the gem and its copy in the site.

## 7. Testing strategy

| Question | Answer |
| --- | --- |
| Does a component render the same HTML as 1.6? | The golden suite's ERB lane, against the frozen snapshot |
| Does an attribute reach the element correctly? | The differential test against Phlex 2.4.1 in `Attributes` |
| Is a sidecar valid HTML? | Herb's validators, over every sidecar, on every CI run |
| Does a component behave in a browser? | Not covered during Phase 2 — see §9.4 |

## 8. Evidence

Everything below was verified on 2026-09-19 unless stated.

**Herb's release state.** The latest release of the `herb` gem is v0.10.4
(2026-09-10). It is **not** an ancestor of `main`: it was cut from a release
branch that forked at v0.10.3 (2026-08-01), and it changes `Gemfile.lock`, docs
and JS package versions only. `main` is **653 commits ahead of v0.10.4**.
PR [#2032](https://github.com/marcoroth/herb/pull/2032), "Engine: Implement
`ComponentVisitor`" (merged 2026-08-06, `66e4d1a50`), is in `main` and **not**
in v0.10.4. Its supporting PRs are
[#2055](https://github.com/marcoroth/herb/pull/2055) (`build` factories for AST
nodes), [#2317](https://github.com/marcoroth/herb/pull/2317)
(`track_locations`) and [#1436](https://github.com/marcoroth/herb/pull/1436)
(`dot_notation_tags`). The slot system —
[#2564](https://github.com/marcoroth/herb/pull/2564),
[#2577](https://github.com/marcoroth/herb/pull/2577),
[#2578](https://github.com/marcoroth/herb/pull/2578),
[#2651](https://github.com/marcoroth/herb/pull/2651) — is also unreleased.

**Herb 0.10.4, probed directly.** `Herb::AST::ERBContentNode.build` and
`Herb::Token.from` do not exist, so the AST cannot be rewritten with the
released API. `Herb.parse("<rui-dialog open>hi</rui-dialog>")` parses cleanly.
`Herb::Engine.new(source, visitors: [...])` is available.

**Herb's component-tag design.** From `docs/docs/projects/engine.md` on `main`:
a tag is transformed only when its name is CamelCase in every segment;
`<My-Component />` is left alone; resolution is decided entirely from the tag
name with no lookup at compile time or render time. The built-in components
generated from `config/slots/components.yml` are `Fragment`, `Fallback`,
`Async`, `Lazy`. `ComponentTags::Visitor` carries an explicit experimental
warning. Attribute values are String literals unless written with the `:attr`
directive, and block parameters are not expressible.

**ReActionView 0.4.1.** Depends on `actionview >= 7.0` and
`herb >= 0.10.4, < 0.11.0`. `ReActionView.config.transform_visitors` is public
configuration and the handler passes it through to `Herb::Engine`.

**Boot test on released Rails.** `rails 8.1.3.1` + `reactionview 0.4.1` +
`herb 0.10.4` resolves without conflict. A minimal Rails application with
`intercept_erb = true` and `validation_mode = :raise` boots and renders; a
custom `Herb::Visitor` registered through `transform_visitors` is invoked
during compilation; `<div><span></div>` is rejected at compile time and
surfaces as `ActionView::SyntaxErrorInTemplate` carrying Herb's annotated
message (missing closing tag, line, suggestion). This is the `Gemfile.stable`
lane the gate planned and never ran.

**RubyUI 1.6.** `ruby_ui.gemspec` declares **no** runtime dependencies; `phlex`
and `tailwind_merge` are development dependencies. `s.files` is
`Dir["README.md", "LICENSE.txt", "lib/**/*"]`, which already packages `.erb`.
Exactly one component reaches for the view context: `DataTableForm`, for the
CSRF token, with a fallback to `"csrf-token-placeholder"`. Eleven components
call `.to_sym`; `DialogContent` and `Badge` index Symbol-keyed hashes without
coercing.

**Counts.** 54 component directories under `gem/lib/ruby_ui`, 256 component
classes (excluding `docs/` and `*_docs.rb`), 52 `*_docs.rb` doc-page classes,
186 golden snapshots. `docs/app` holds 144 Ruby files and 10,383 lines under
`app/views`, with 68 page files under `app/views/docs` and no `.erb` anywhere.
42 of the 52 doc pages are byte-identical to their copy in the site; 10 have
drifted.

**`main` versus `v2-herb`.** `main` is nine commits ahead of the branch point
and exactly one touches a component: `10c01f0`, the HoverCard fix (#530). The
branch's three commits are `f7cbeda` (the golden suite, 196 files, self
contained), `67231db` (three markdown documents) and `96aa866` (182 files, all
under `experiments/v2-gate`).

**The gate (2026-09-07, `v2-herb`).** Dialog's six snapshots byte-identical on
the herb and erubi lanes. The layer at 226 lines against a 500-line ceiling.
No template adjustment needed — every markup shape Dialog and Button use
compiled unchanged. Twenty-three classified findings in
`experiments/v2-gate/HERB_FINDINGS.md`.

## 9. Open questions

### 9.1 The ruler's whitespace blind spot — resolve in Phase 1

`CanonicalHtml` collapses runs of whitespace to a single space and drops text
nodes that collapse to empty, preserving whitespace only inside `pre` and
`textarea`. So it treats `<span>a</span><span>b</span>` and
`<span>a</span>\n<span>b</span>` as identical — and a browser does not, in an
inline formatting context.

ERB emits newlines where Phlex emitted nothing. Most of RubyUI lays out with
flex and `gap-*` and is immune; `Typography`, `InlineCode`, `InlineLink`,
`ShortcutKey` and inline badges are not.

**Measured 2026-09-19, while planning Phase 1: 8 components, 50 adjacent inline
pairs** — `badge` (27, an artefact of the `all_variants` scenario), `dialog`
(6), `codeblock` (5), `sheet` (5), `sidebar` (3), `carousel` (2), `command` (1),
`context_menu` (1). The count excludes pairs whose parent is a flex or grid
container, which ignores the whitespace; including them inflates it to 21
components and 86 pairs.

**Resolution:** leave the normalizer alone and write those eight components'
sidecars whitespace-tight in Phase 2, named explicitly in each component's
task. A second comparison mode would have to be threaded through the canonical
form, the fixed-point assertion and all 186 snapshots for eight components,
most of them benign — the `sr-only` label beside a close icon renders the same
either way, and `codeblock`'s tokens sit inside `pre`, which the normalizer
already preserves.

Phase 1 reproduces the measurement and records it in `design/v2/decisions.md`;
the script is `gem/test/golden/tools/inline_adjacency.rb`.

### 9.2 Three questions for upstream

To settle with Herb's maintainer:

1. **Attribute typing.** A plain tag attribute is a String. Can a component
   declare an attribute's type so `size="lg"` arrives as `:lg`, rather than
   users writing `:size=":lg"`? Decision B works around this in RubyUI; an
   upstream answer would remove the workaround.
2. **Block parameters.** `<Card as |c|>` does not exist, so `ToggleGroup` and
   `ToastRegion` have no tag form. Is one planned?
3. **Release timing.** herb 0.11 with component tags, and the ReActionView
   release that accepts it — 0.4.1 pins `herb < 0.11.0`, so both are needed.
   Decision D is designed so the answer changes the announcement, not the
   architecture.

### 9.3 Codemod — revisit after Phase 2

Users of 1.6 have Phlex components copied into their apps. 2.0 ships a manual
migration guide. Whether a Phlex-to-ERB codemod is worth building should be
decided once the gem migration has shown how mechanical the transformation is —
the gem's own 256 classes are the sample.

### 9.4 No browser coverage during Phase 2

System tests live in `docs/`, and `docs/` is pinned to 1.6 for the duration of
Phase 2, so no 2.0 component is exercised in a browser until Phase 3.

The mitigation is the argument that byte-identical HTML plus unchanged
JavaScript implies unchanged behaviour: the Stimulus controllers see the same
DOM and the same `data-*` attributes. That argument is strong but not total,
and its gap is precisely §9.1 — the canonical form cannot see the whitespace a
browser renders.

With §9.1 now measured at eight components, the gap is bounded and named rather
than unknown. Accepted knowingly: those eight are the only places where Phase 2
could ship a visible difference the suite reports as parity, and their tasks
carry the instruction that closes it.

## 10. Risks

| Risk | Exposure | Mitigation |
| --- | --- | --- |
| Two pre-1.0 gems become required for every user | Decision D | Verified working on released Rails (§8). ReActionView is a handler over ActionView, not a framework. |
| `intercept_erb` validates the host app's own templates | A user with malformed HTML anywhere sees errors on install day | Documented prominently in the install guide, with `validation_mode` as the escape hatch |
| herb 0.11 requires a new ReActionView release too | The tag syntax waits on two projects, not one | Decision D ships 2.0.0 without depending on either date |
| The documentation site runs Phlex while the library no longer does | Between 2.4 and Phase 3 | Acknowledged in the release announcement rather than discovered by readers |
| `app/components` becomes a view path | ViewComponent users | `append_view_path`, and documented |
| Single-maintainer upstream | Herb and ReActionView | The `render X.new` form has no Herb dependency at all, so the library still functions if upstream stalls |

## 11. What this document replaces

`design/v2/00-charter.md` and `design/v2/03-plan-fase1.md` on `v2-herb` are
superseded. Their premises that no longer hold: ReActionView as an open
question, a pinned unreleased Rails commit as the baseline, and the authoring
syntax left undecided.

Still true and worth reading from that branch:
`experiments/v2-gate/HERB_FINDINGS.md` (23 classified findings) and
`experiments/v2-gate/LAYER.md` (what the layer does, with line counts). Both
are promoted into `design/v2/` when the 2.0 branch is cut.
