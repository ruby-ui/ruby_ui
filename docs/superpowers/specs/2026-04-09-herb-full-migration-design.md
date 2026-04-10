# RubyUI: Full Herb Migration Design

**Date:** 2026-04-09
**Branch:** da/herb-experiment
**Status:** Approved

---

## Summary

Migrate all 44 RubyUI components from Phlex source to Herb (HTML+ERB) as the sole source of truth. Phlex is no longer authored by hand — it is generated on demand by `HerbToPhlexVisitor` when a consumer runs `rails g ruby_ui:component Name --engine=phlex`.

---

## Source Structure (per component)

```
lib/ruby_ui/<component>/
  <component>.rb             ← plain Ruby class (no Phlex, uses TailwindMerge)
  <component>.html.erb       ← Herb template (source of truth)
  <component>_docs.html.erb  ← ERB usage examples (replaces _docs.rb)
  <component>_controller.js  ← Stimulus controller (unchanged)
```

**What is deleted:** all hand-written Phlex `<component>.rb` files. `base.rb` stays — it is the Phlex base class generated into consumer apps that choose `--engine=phlex`.

---

## Plain Ruby Class (`<component>.rb`)

No Phlex inheritance. Owns all logic:

- Accepts `**attrs` for arbitrary HTML attributes
- Runs TailwindMerge to compute final `class` string
- Exposes `attrs` hash (type, class, data-*, id, disabled, etc.)
- Contains all variant/size/state computation as private methods

```ruby
# frozen_string_literal: true

require 'tailwind_merge'

module RubyUI
  class Button
    TAILWIND_MERGER = ::TailwindMerge::Merger.new.freeze

    def initialize(type: :button, variant: :primary, size: :md, **attrs)
      @type    = type
      @variant = variant.to_sym
      user_class = attrs.delete(:class)
      @attrs = { type: @type, class: merge_classes(user_class), **attrs }
    end

    def attrs = @attrs

    private

    def merge_classes(user_class)
      TAILWIND_MERGER.merge([base_classes, variant_classes, user_class].flatten.compact)
    end

    # ... variant_classes, base_classes, size_classes ...
  end
end
```

---

## Template (`<component>.html.erb`)

Uses `tag_attributes` helper to spread the full attrs hash safely:

```erb
<button <%= tag_attributes(attrs) %>>
  <%= yield %>
</button>
```

For nested structures (Progress, Table, AspectRatio):

```erb
<div class="relative w-full overflow-auto">
  <table <%= tag_attributes(attrs) %>>
    <%= yield %>
  </table>
</div>
```

---

## `tag_attributes` Helper

Shared helper at `lib/ruby_ui/helpers/tag_attributes.rb`. Converts a Ruby hash to an HTML-safe attributes string, handling nested hashes (`data: { controller: 'foo' }` → `data-controller="foo"`).

Available in all ERB templates and in the plain Ruby class tests.

---

## Generator: `--engine` Flag

| Engine | Consumer receives |
|--------|-------------------|
| `--engine=phlex` (default) | `HerbToPhlexVisitor` runs on `<component>.html.erb` → writes generated `<component>.rb` Phlex class to `app/components/ruby_ui/` |
| `--engine=erb` | Copies `<component>.rb` + `<component>.html.erb` to `app/components/ruby_ui/` |
| `--engine=herb` | Same files as `--engine=erb` + runs `bundle add herb` in consumer app |

`--engine=herb` vs `--engine=erb`: identical files, identical content. The only difference is the herb gem install step and the signal to the consumer that Herb::Engine should process the templates.

**Dependency propagation:** `--engine` flag is passed through to all component dependencies (e.g., AlertDialog depends on Button → both get the same engine).

---

## Docs: `_docs.html.erb`

Replaces `_docs.rb`. Written in ERB, showing consumer usage:

```erb
<%= render Button.new(variant: :primary) { 'Primary' } %>
<%= render Button.new(variant: :secondary) { 'Secondary' } %>
<%= render Button.new(variant: :destructive) { 'Destructive' } %>
```

The web docs site (`web/`) auto-generates the Phlex tab by running `HerbToPhlexVisitor` on the docs ERB, converting:
- `<%= render Button.new(variant: :primary) { 'Primary' } %>` → `RubyUI.Button(variant: :primary) { 'Primary' }`

**Web docs tab layout:**
```
[ Preview ] [ ERB ] [ Phlex ]
```

- **Preview** — Rails renders `_docs.html.erb` normally via ActionView
- **ERB** — raw `_docs.html.erb` file content read as a string and displayed as code
- **Phlex** — `HerbToPhlexVisitor` runs on that same raw string → displayed as generated Phlex code

The `_docs.html.erb` is one file that serves all three purposes:
1. Renderable ERB template (Preview tab)
2. Raw string source (ERB tab)
3. Visitor input (Phlex tab)

```ruby
# web/ docs controller/helper
erb_source = File.read(component_docs_path)               # raw → ERB tab
phlex_code = RubyUI::Herb::PhlexGenerator                 # → Phlex tab
               .generate_view_template(erb_source)
# Rails renders template normally for Preview
```

No markdown files, no separate string constants. One file, three uses.

No manual Phlex docs to maintain. Single source of truth for docs.

---

## HerbToPhlexVisitor Extensions Needed

The existing visitor handles HTML elements, ERB output tags, yield, conditionals, blocks. New patterns needed for full migration:

1. **`render Component.new(...)` → `RubyUI.ComponentName(...)`** — for docs conversion and nested component templates
2. **Nested attrs spreading** — `tag_attributes(hash)` in template → Phlex `**attrs` in output
3. **Inline conditionals in attrs** — `class: [@class, condition ? 'a' : 'b']` patterns

---

## Tests

### Component tests
Convert existing Phlex component tests to test via visitor:
```ruby
def test_button_renders_correct_html
  template = File.read('lib/ruby_ui/button/button.html.erb')
  phlex_code = PhlexGenerator.generate_view_template(template)
  # Eval + render and assert HTML output
end
```

### Plain Ruby class tests
Keep `button_herb_test.rb` pattern — test attrs computation, TailwindMerge, variants, sizes directly on the `.rb` class.

### Generator tests
Keep existing engine tests. Add `--engine=herb` coverage.

### All tests must pass: `bundle exec rake` green after every batch.

---

## RuboCop / StandardRB

The gem uses **StandardRB** (double-quoted strings, specific style rules). All new `.rb` files must pass `bundle exec rake standard` before commit.

---

## Component Tiers

### Tier 1 — Trivial (~32 components)
Single tag + yield. Template is one line.

Components: Accordion, AccordionContent, AccordionIcon, AccordionItem, AccordionTrigger, Alert, AlertDescription, AlertTitle, AlertDialog (all sub-components), Avatar, AvatarFallback, AvatarImage, Badge, BreadcrumbItem, BreadcrumbLink, BreadcrumbList, BreadcrumbPage, BreadcrumbSeparator, BreadcrumbEllipsis, Card (all sub-components), Carousel (all sub-components), Collapsible, CollapsibleContent, CollapsibleTrigger, Command (all sub-components), ContextMenu (all sub-components), Dialog (all sub-components), DropdownMenu (all sub-components), Form (all sub-components), HoverCard (all sub-components), Pagination (all sub-components), Popover (all sub-components), Select (all sub-components), Sheet (all sub-components), ShortcutKey, Skeleton, Tabs (all sub-components), ThemeToggle, Tooltip (all sub-components)

### Tier 2 — Medium (~8 components)
Multiple elements, computed styles/attrs.

- **Input** — `<input type="<%= attrs[:type] %>" ...>`
- **Textarea** — `<textarea rows="<%= rows %>" ...>`
- **Link** — `<a href="<%= href %>" ...>` with variants
- **Separator** — dynamic tag (`div`/`hr`), orientation classes
- **Progress** — wrapping div + indicator div with inline style
- **Table** — wrapping div + table element
- **AspectRatio** — outer div with computed `padding-bottom` style + inner div
- **NativeSelect** — wrapper div + select + icon component
- **Checkbox** / **RadioButton** — void input elements

### Tier 3 — Complex (~4 components)
Multi-element, inline logic, sub-component composition.

- **Switch** — label + hidden input + checkbox + span, conditional hidden field
- **Calendar** — renders CalendarHeader, CalendarBody, CalendarWeekdays, CalendarDays sub-components
- **Clipboard** — success/error popover helpers, nested sub-component composition
- **Codeblock** — Rouge integration, SVG icons inline, conditional clipboard wrapping
- **Sidebar** — delegates to CollapsibleSidebar or NonCollapsibleSidebar based on props

Complex components: the `.rb` class exposes all computed values as methods; the template calls those methods. The visitor generates correct Phlex from the resulting templates.

---

## Execution Plan

### Phase 0 — Infrastructure
- Rename `button_herb.rb` → `button.rb`, delete old Phlex `button.rb`
- Rename `button.html.herb` → `button.html.erb` (already created in Phase 1)
- Create `lib/ruby_ui/helpers/tag_attributes.rb`
- Update `EngineUtils` to detect `.html.erb` templates (already done)
- Update visitor to handle `render Component.new(...)` → Phlex Kit calls

### Phase 1 — Parallel batches (subagents)
Run 4 subagents in parallel, one per tier group:
- **Batch A** (11 components): Accordion, Alert, AlertDialog, Avatar, Badge, Breadcrumb, Card, Carousel, Collapsible, Combobox, Command
- **Batch B** (11 components): ContextMenu, Dialog, DropdownMenu, Form, HoverCard, Pagination, Popover, Select, Sheet, ShortcutKey, Sidebar
- **Batch C** (10 components): Skeleton, Switch, Table, Tabs, Textarea, ThemeToggle, Tooltip, Chart, Checkbox, RadioButton
- **Batch D** (8 components): Input, Link, Separator, Progress, AspectRatio, NativeSelect, Calendar, Clipboard, Codeblock, MaskedInput

Each subagent:
1. Creates `<component>.rb` (plain Ruby) + `<component>.html.erb` (template)
2. Creates `<component>_docs.html.erb` (ERB docs)
3. Deletes old Phlex `<component>.rb`
4. Updates tests
5. Runs `bundle exec rake` — must be green

### Phase 2 — Verify and integrate
- Run full test suite across all components
- Run StandardRB: `bundle exec rake standard`
- Commit

### Phase 3 — Web app deployment
- Erase all existing components from `web/app/components/ruby_ui/`
- Run `rails g ruby_ui:component Name --force` for all 44 components
- Verify web app loads and renders all doc pages
- Check Preview / ERB / Phlex tabs on web docs

---

## Out of Scope

- Web app tab switcher UI (Phase 3 of web/ app work, separate PR)
- ReActionView integration (consumer concern, not gem)
- Level 4 Herb JSX syntax (`<Button variant="primary" />`) — future
- Migration of `base.rb` away from Phlex — stays as Phlex for `--engine=phlex` consumers

---

## Success Criteria

1. `bundle exec rake` passes: all tests green, lint clean
2. No hand-written Phlex `.rb` component files remain in `lib/ruby_ui/` (except `base.rb`)
3. `rails g ruby_ui:component Button --engine=phlex` generates working Phlex class
4. `rails g ruby_ui:component Button --engine=erb` generates plain Ruby + template
5. `rails g ruby_ui:component Button --engine=herb` same + recommends herb gem
6. All 44 components exported to `web/` and docs pages render correctly
7. `_docs.html.erb` exists for every component
