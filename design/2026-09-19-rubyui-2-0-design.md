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
256 component classes. The 52 doc-page classes the gem ships (`*_docs.rb`)
and the `DocsGenerator` that copies them, migrated in Phase 2 (decision 11,
Phase 2.3). The generators and installer. The documentation site.

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
- **Phlex's attribute guards are ported.** Phlex 2.4.1 raises on an unsafe
  attribute name (`onclick`, `srcdoc`, any `on*`) and drops a `javascript:`
  href; the gate's `Attributes` did neither, and review showed
  `href="javascript:alert(1)" onclick="alert(1)"` reaching the page through
  `tag.attributes`. An application passing untrusted values to a component
  would lose a protection it has today. The guards get their own unit tests
  in `Attributes`; the golden suite cannot see them and is not evidence about
  them. The `:id` key check is not ported — it guards a Phlex-specific
  convention with no equivalent here.
- `render_in` assigns `content` on every call — `nil` when there is no block.
  The gate's version assigned it only with a block, so an instance rendered
  twice repeated its first content.
- The sidecar is found through a lookup **scoped to the directory that holds
  `ruby_ui/`**, not through the application's view-path chain, and two
  candidates for one component is an error. Review showed that with the
  chain, `append` lets a host `ruby_ui/…` template silently replace the
  sidecar and `prepend` lets the sidecar silently shadow the host — the
  ordering only picks which side loses quietly.
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

RubyUI.component_root = Rails.root.join("app/components")

ReActionView.config.intercept_erb = true
ReActionView.config.validation_mode = :raise
```

`extend Phlex::Kit` is removed. Zeitwerk ignores `.html.erb`, so the sidecar
living in an autoloaded directory is inert. `component_root` is the one
directory the sidecar lookup searches (§4.3); `app/components` is **not**
added to the application's view paths, so nothing about how the host resolves
its own templates changes, and ViewComponent — whose home directory this is —
is untouched.

**Installing is not the same as enabling.** `intercept_erb = true` routes
every ERB template in the host application through Herb, and a template Herb
rejects does not degrade to its old output: with `validation_mode: :raise` it
raises, with `:none` its output is **empty**, with `:overlay` it is replaced by
the error overlay (verified against herb 0.10.4, §8). The installer therefore
runs a preflight — compile every template under `app/views` through
`Herb::Engine` and list the rejections — before it writes the interception
line, and the install guide says what to do with the list. The only opt-out is
`intercept_erb = false`, which also turns off the tag syntax; `validation_mode`
is not an escape hatch.

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
| 9 | **C.** Sidecar next to the class, found by a lookup scoped to the component root | Keeps class, template and Stimulus controller in one directory, as 1.6 already keeps class and controller. The gate proved the sidecar-next-to-class shape in development with reloading and in production with eager loading, but resolved it through the application's view-path chain; review showed that both `prepend` and `append` merely choose which side of a name collision loses silently. A lookup scoped to one root has no other side: a collision with the host is impossible, and two sidecars for one class is an error. |
| 10 | **D.** Herb is required from 2.0.0, through ReActionView | Verified on released Rails (§8): `rails 8.1.3.1 + reactionview 0.4.1 + herb 0.10.4` resolves, boots, renders, runs custom transform visitors, and rejects malformed HTML at compile time. Every user gets validation from day one, and when herb ships component tags every user gets the tag syntax through `bundle update` — no reinstall, no migration. The accepted cost: two pre-1.0 gems become required, and `intercept_erb` compiles the whole host app through Herb, so a user with malformed HTML anywhere sees it on install day. `validation_mode` does not soften this — `:none` empties the template and `:overlay` replaces it — so the installer preflights the host's templates (§4.4), and the only opt-out is `intercept_erb = false`, which also disables the tag syntax. |

## 6. Phases

### Phase 1 — The ruler

**Goal.** A golden suite green on `main`, covering all 54 component
directories, validated against today's code.

The suite renders every component in the 1.6 catalog, reduces each render to a
canonical form and compares it to a committed snapshot. Its output is the thing
everything else depends on: **once recorded, the 188 snapshots are the frozen
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
4. Harden the canonical form (§9.1): refuse a wrapper escape, distinguish an
   empty element from a whitespace-only one, use HTML's whitespace — each
   with a test that fails first — and move the coverage guard from
   instantiation to render. No recorded snapshot changes.
5. Inventory what the canonical form still cannot see, and record the
   decision in `design/v2/decisions.md`.
6. PR to `main`.

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
- Add the **ERB lane** to the golden suite: the 188 scenarios become
  `.html.erb` fixtures under `gem/test/golden/views/`, rendered through the 2.0
  component and compared against the frozen snapshot.
- Implement the `enum` coercion helper in `Base`.
- Port Phlex's attribute guards into `Attributes` (§4.3), with unit tests
  that assert an unsafe name raises and a `javascript:` reference is dropped.
- `render_in` assigns `content` on every call; test that an instance rendered
  twice, the second time without a block, renders empty content.
- Implement the scoped sidecar lookup (§4.3, §4.4) and test it against a
  host template at the same virtual path, against two overlapping roots, and
  across two view contexts. The gate's `@template_path ||=` cache is keyed per
  class and ignored the view context; the scoped lookup must not.
- Define the **strict lane**. The canonical form is, by design, blind to
  whitespace at a text–element boundary and between inline siblings (§9.1).
  Sidecars are therefore written in ERB trim mode (`<%-` / `-%>`) so they emit
  no whitespace Phlex did not, and the components that carry text —
  Typography, InlineCode, InlineLink, ShortcutKey, Badge, FormFieldError and
  the others the Phase 1 inventory names — are additionally compared **raw**,
  with only attribute order normalized. A strict-lane failure is a real
  difference, not noise.
- **MCP.** `mcp/data/registry.json` embeds the source of every component file
  and CI rebuilds it and fails on any diff. Every Phase 2 PR that touches
  `gem/lib/ruby_ui` rebuilds it (`cd mcp && bundle exec exe/ruby-ui-mcp-build`)
  and commits the result. `RegistryBuilder` also extracts examples from
  `*_docs.rb`; decision 11 (Phase 2.3) says what happens to those.
- **Fresh-app install test.** A script, run in CI, that does `rails new`, adds
  the gem, runs the installer and the preflight, generates one component and
  renders it through a request. The golden suite renders without Rails and
  cannot see installation, reloading, CSRF (`DataTableForm` falls back to a
  placeholder outside a request) or assets.
- Point `docs/Gemfile` at the published `ruby_ui` 1.6 instead of
  `path: "../gem"`, so the site keeps building and the CI Docs job stays green
  while the gem is mid-migration. Phase 3 reverts it.

**Acceptance.** The layer is in the gem with its own tests, guards included.
The ERB lane runs with at least one component at parity, and the strict lane
with at least one text-bearing component. The fresh-app script passes. All
three CI jobs are green with the registry rebuilt.

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
sidecar in trim mode; the snapshot matching; the strict lane matching if the
component carries text; a scenario passing the String form of every enum
attribute; **its existing unit tests in `gem/test/ruby_ui/` ported to the new
harness, none deleted** — they are the inventory of what the component promises
beyond its markup; the Stimulus controller untouched; the MCP registry rebuilt.

#### 2.3 Packaged documentation

**Decision 11 — `ruby_ui:install:docs` stays, and the pages it ships migrate
in Phase 2.** (Reversed on 2026-09-19 from "remove in 2.0"; see
`design/v2/decisions.md` entry 4.) `DocsGenerator` copies the gem's 52
`*_docs.rb` pages into a host application's `app/views/docs/`; the maintainer
wants that to keep working in 2.0.0, so the pages cannot still be Phlex when
2.5 ships.

What that pulls into Phase 2:

- **The docs primitives in `gem/lib/ruby_ui/docs/`** — six Phlex classes
  (`visual_code_example`, `header`, `components_table`,
  `component_setup_tabs`, `sidebar_examples`, `base`) — become 2.0 components
  like any other: class plus sidecar, in the gem, installable.
- **The `VisualCodeExample` redesign**, originally Phase 3.0. Today a page
  passes a heredoc of Phlex source that the primitive `eval`s for the live
  preview and prints as the code sample. In 2.0 an example is ERB, not Ruby,
  so the primitive renders a real `.html.erb` file for the preview and reads
  the same file for the code block. Each example becomes a file next to its
  page — roughly 450 files of one to five lines — and the tag syntax works in
  examples because they are genuinely compiled.
- **The 52 pages themselves**, from Phlex classes to ERB templates with their
  example files, shipped in the gem and copied by `DocsGenerator`, which
  learns to copy the example files alongside each page. The drift between a
  gem page and its copy in `docs/app` (10 of 52 today) is reconciled here,
  page by page, with the reason recorded.
- **`DocsGenerator` itself.** It discovers pages with the glob `*/*_docs.rb`
  (`gem/lib/generators/ruby_ui/install/docs_generator.rb`); once no
  `*_docs.rb` remains it finds nothing. It is rewritten in this sub-phase to
  discover the migrated pages and their example files and copy them together,
  keeping the paths a host application already has under `app/views/docs/`.
- **`RegistryBuilder`** (`mcp/`) extracts MCP examples from `*_docs.rb`
  today; it is pointed at the ERB example files in the same change.

The doc pages are not components and the golden suite does not cover them;
Phase 3 is where they are first looked at on screen, in the site.

**Acceptance.** In the fresh-app install script (Phase 2.0),
`rails g ruby_ui:install:docs` copies pages and example files that render
through a request; every example file compiles through Herb; the golden suite
is unaffected; no `*_docs.rb` remains in the gem.

#### 2.4 Generators and installer

`component_generator.rb` copies `.rb` and `.html.erb`. `install_generator.rb`
writes the initializer of §4.4, runs the Herb preflight, and copies `base.rb`
and `attributes.rb`. `dependencies.yml` is unchanged — it describes JS
packages. The gemspec drops `phlex` and gains `tailwind_merge` and
`reactionview` as runtime dependencies.

#### 2.5 Release

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
library surface — and decision 11 keeps them there. By the time this phase
starts, Phase 2.3 has migrated the 52 pages, their example files and the six
docs primitives to 2.0, and the site's copies are simply stale Phlex. Phase 3
is therefore the site's own code: its chrome, its 16 pages that come from
nowhere else, and the switch from its copies to the gem's pages.

#### 3.0 Chrome and layout

`docs/app/views/base.rb` — the site's own `Views::Base`; the gem's
`docs/base.rb`, which also defines one, is among the six primitives Phase 2.3
migrates — plus layouts, navigation and marketing pages: the ~86 Ruby files
that are not component pages. Phlex to ERB, page by page.

#### 3.1 The site's own pages

The 16 pages under `app/views/docs` that have no `*_docs.rb` source
(installation, theming and the rest). They use the docs primitives, which by
now are 2.0 components in the gem.

#### 3.2 Replace the copies with the gem's pages

The 52 Phlex copies under `docs/app/views/docs` are deleted and the site
renders the gem's migrated pages — either by running `ruby_ui:install:docs`
as any host app would, or by pointing a view path at the gem, decided when
this sub-phase starts and recorded in `design/v2/decisions.md`. Either way
the site stops carrying a second copy that can drift.

#### 3.3 Close-out

`docs/Gemfile` points back at `path: "../gem"`; `phlex` and `phlex-rails` come
out; `mcp/data/registry.json` is rebuilt; the CI Docs job is green without the
pin.

**Acceptance.** No view `.rb` under `docs/app/views`; no `*_docs.rb` left in
the gem (already true after 2.3); no mention of phlex in `docs/Gemfile.lock`;
all 68 pages rendering; no second copy of a doc page anywhere in `docs/app`.

## 7. Testing strategy

| Question | Answer |
| --- | --- |
| Does a component render the same HTML as 1.6? | The golden suite's ERB lane, against the frozen snapshot |
| Is an element that was empty still empty, not whitespace-only? | The canonical form, after Phase 1 hardens it (§9.1) |
| Did whitespace at a text boundary change? | The strict lane, raw output, for text-bearing components (Phase 2.0) |
| Does an attribute reach the element correctly? | The differential test against Phlex 2.4.1 in `Attributes` |
| Is an unsafe attribute still refused? | Unit tests on `Attributes`' guards, not the golden suite |
| Is a sidecar valid HTML? | Herb's validators, over every sidecar, on every CI run |
| Does the component keep its non-markup promises (lifecycle, caller API, CSRF)? | The ported unit tests, and the fresh-app install script |
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

**Review findings, verified 2026-09-19.** With herb 0.10.4,
`Herb::Engine.new("<div><span></div>", validation_mode: mode)` gives:
`:raise` → `Herb::Engine::CompilationError`; `:none` → 31 bytes of source with
no `<div>`; `:overlay` → the error overlay. `Golden::CanonicalHtml` on
`v2-herb` returns equal canonical forms for `<div>safe</div>` and
`<div>safe</div></template><button>lost</button>`; for `<div></div>` and
`<div>\n</div>`; for `<p>Hello <em>w</em></p>` and `<p>Hello<em>w</em></p>`;
and for `class="a\vb"` and `class="a b"`. Phlex 2.4.1 raises
`Phlex::ArgumentError` on an `onclick` attribute and drops a `javascript:`
href; the gate's `Attributes` passes both through. The gate's `render_in`
assigns `@content` only when a block is given. `Golden::Harness` records a
class on `initialize`, not on render. Raw Phlex output of all 188 scenarios
contains zero elements with whitespace-only content and zero text–element
boundaries carrying a space. `mcp/lib/ruby_ui/mcp/builders/registry_builder.rb`
embeds each component file's content, and `.github/workflows/ci.yml` rebuilds
the registry and fails on a diff. `ruby_ui:install:docs` is referenced nowhere
in `docs/app`, `gem/README.md` or the generators other than its own file. The
Task 1 outputs also reproduce on Ruby 3.3.5.

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

**Measured 2026-09-19, then reviewed.** A heuristic inventory
(`gem/test/golden/tools/inline_adjacency.rb`) reported 8 components and 50
adjacent inline pairs. Review of the pairs showed the count is neither
accurate nor an upper bound: Carousel's are absolutely positioned buttons,
Command's and ContextMenu's anchors are `flex` and so block-level, Dialog's,
Sheet's and Sidebar's are `sr-only` labels, Codeblock's sit inside `pre`, which
the normalizer already preserves — leaving Badge's 27, an artefact of one
scenario. The script also misclassifies `span.block`, `span.hidden` and
`span.absolute` as inline, misses `inline-grid` and responsive variants, and
does not look at text–element boundaries at all.

The text–element case is the one that matters, and it is not cosmetic.
`FormField`'s controller enables validation when `errorTarget.textContent` is
truthy and hides the target otherwise; `FormFieldError` styles itself with
`empty:hidden`. Phlex emits `<div …></div>`; an ERB sidecar naturally emits
`<div …>\n</div>`. The canonical form on `v2-herb` called those identical.
They are not: `""` is falsy and `"\n"` is truthy, and `:empty` matches only the
first. Behaviour flips on whitespace alone, in a component the inline-pair
count never named.

**Resolution, in three parts, none of which is the count.**

1. **Phase 1 hardens the canonical form** so that an empty element and a
   whitespace-only element canonicalize differently, a fragment that escapes
   the `<template>` wrapper is refused instead of truncated, and class tokens
   and text collapse on HTML's ASCII whitespace rather than Ruby's `\s`
   (U+000B is one and not the other). Measured against the raw Phlex output of
   all 188 scenarios: **zero** elements with whitespace-only content and
   **zero** text–element boundaries carrying a space, so the hardening changes
   no recorded snapshot. It changes what Phase 2 is allowed to emit.
2. **Phase 2 sidecars use ERB trim mode**, so they emit no whitespace Phlex
   did not.
3. **Phase 2.0 defines a strict lane** — raw output, attribute order
   normalized, nothing else — for components that carry text.

What the canonical form still does not see, stated as the contract's
exclusion: whitespace between two element siblings, and whitespace at a
text–element boundary, in `:normal` mode. The inventory script stays in the
tree as a way to find candidates, not as a criterion.

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

Review showed the gap is wider than an inline-pair count: `FormField` flips
behaviour on an empty-versus-whitespace-only element (§9.1), which no
inline-adjacency measure names. What bounds it now is §9.1's three-part
resolution — the hardened canonical form catches the empty/whitespace-only
case for every component, trim mode stops the ERB lane emitting what Phlex did
not, and the strict lane compares text-bearing components raw. Accepted
knowingly, with that shape: what remains unseen is whitespace between element
siblings and at text boundaries in components the strict lane does not cover,
and Phase 3 is where a browser first looks.

## 10. Risks

| Risk | Exposure | Mitigation |
| --- | --- | --- |
| Two pre-1.0 gems become required for every user | Decision D | Verified working on released Rails (§8). ReActionView is a handler over ActionView, not a framework. |
| `intercept_erb` validates the host app's own templates | A user with malformed HTML anywhere sees errors on install day — and `validation_mode` does not soften it: `:none` empties the template, `:overlay` replaces it (§8) | The installer preflights every host template through `Herb::Engine` before enabling interception and lists what would break; the only opt-out is `intercept_erb = false`, documented as also disabling the tag syntax |
| herb 0.11 requires a new ReActionView release too | The tag syntax waits on two projects, not one | Decision D ships 2.0.0 without depending on either date |
| The documentation site runs Phlex while the library no longer does | Between 2.5 and Phase 3 | Acknowledged in the release announcement rather than discovered by readers |
| `app/components` is also ViewComponent's directory | ViewComponent users | `app/components` is not added to the view paths; the sidecar lookup is scoped to `component_root` (§4.4) |
| Sidecar name collision with a host template | Silent replacement in either direction with a view-path lookup | Lookup scoped to the component root; collision is an error (§4.3) |
| Removing Phlex's attribute guards | Untrusted attribute values reach the page as `javascript:` URLs or `on*` handlers | Guards ported into `Attributes` with their own tests (§4.3) |
| `mcp/data/registry.json` embeds component source | Every gem change; CI fails on a stale registry | Rebuilt and committed in every PR that touches `gem/lib/ruby_ui` (Phase 2.0) |
| Single-maintainer upstream | Herb and ReActionView | With `intercept_erb = false` the components render through Erubi unchanged — the gate proved byte parity on both lanes — so the library still functions if upstream stalls, minus validation and the tag syntax |

## 11. What this document replaces

`design/v2/00-charter.md` and `design/v2/03-plan-fase1.md` on `v2-herb` are
superseded. Their premises that no longer hold: ReActionView as an open
question, a pinned unreleased Rails commit as the baseline, and the authoring
syntax left undecided.

Still true and worth reading from that branch:
`experiments/v2-gate/HERB_FINDINGS.md` (23 classified findings) and
`experiments/v2-gate/LAYER.md` (what the layer does, with line counts). Both
are promoted into `design/v2/` when the 2.0 branch is cut.
