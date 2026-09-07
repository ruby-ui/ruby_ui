# The layer — Phase 1

Date: 2026-09-07

## What it is

Two files under `app/components/ruby_ui/`, plain Ruby, no monkey patch of ActionView or Herb:

| File | Lines (`wc -l`, comments included) | Responsibility |
| --- | --- | --- |
| `base.rb` | 79 | `RubyUI::Base`: `initialize(**attrs)` → `attrs` (mix + Tailwind merge + flat serialization, no view context); `render_in(view_context, **, &block)` → `capture(self, &block)` into `content`, then `render template:` the sidecar with `component: self` as the only local; `helpers` (the view context, render-time only); `template_path` derived from the class file and the configured view paths. |
| `attributes.rb` | 147 | `RubyUI::Attributes`: `mix` (Phlex::Helpers#mix semantics), `merge_classes` (tailwind_merge 1.5.5, as 1.6 Base), `flat` (Phlex 2.4.1 serialization semantics → flat string-keyed hash for `tag.attributes`). |
| **Total** | **226 / 500** | Budget from plan §3. |

Everything else in `app/components/ruby_ui/` is a component: a class that declares `default_attrs` (and constructor keywords), plus a sidecar `<name>.html.erb` next to it that renders one element with `<tag <%= tag.attributes(component.attrs) %>>` and `<%= component.content %>`. Dialog's 8 classes and Button are ports of the 1.6 classes with `view_template` removed and the markup moved to the sidecar; the Ruby (SIZES, variant/size class tables, `default_attrs`) is unchanged.

## Install step

`config/initializers/ruby_ui.rb`, three lines. Two already exist in the 1.6 installer template (`gem/lib/generators/ruby_ui/install/templates/ruby_ui.rb.erb`): the `RubyUI` inflection and the Zeitwerk collapse of `app/components/ruby_ui/*`. The one line 2.0 adds:

```ruby
ActiveSupport.on_load(:action_controller) do
  prepend_view_path Rails.root.join("app/components") if respond_to?(:prepend_view_path)
end
```

The sidecar of `app/components/ruby_ui/dialog/dialog_content.rb` resolves as the template `ruby_ui/dialog/dialog_content` because `app/components` is a view path. `Base.template_path` finds the view path that contains the class file (via `Object.const_source_location`) and strips it; a class outside every view path raises with that message.

## The `dialog/default` user view

`app/views/gate/dialog_default.html.erb`, byte-identical in canonical form to `gem/test/golden/snapshots/dialog/default.html` on both lanes:

```erb
<%= render RubyUI::Dialog.new do %>
  <%= render RubyUI::DialogTrigger.new do %>
    <%= render RubyUI::Button.new do %>Open Dialog<% end %>
  <% end %>
  <%= render RubyUI::DialogContent.new do %>
    <%= render RubyUI::DialogHeader.new do %>
      <%= render RubyUI::DialogTitle.new do %>RubyUI to the rescue<% end %>
      <%= render RubyUI::DialogDescription.new do %>Build accessible apps with ease.<% end %>
    <% end %>
    <%= render RubyUI::DialogMiddle.new do %>Body<% end %>
    <%= render RubyUI::DialogFooter.new do %>
      <%= render RubyUI::Button.new(variant: :outline) do %>Cancel<% end %>
      <%= render RubyUI::Button.new do %>Save<% end %>
    <% end %>
  <% end %>
<% end %>
```

1.6 wrote `RubyUI.Dialog { RubyUI.DialogTrigger { RubyUI.Button { "Open Dialog" } } … }`. The invocation change is the first written deviation from 1.6 (plan §2 item 9).

## Unit rendering without a request

`GateController.render(template: "gate/dialog_default", layout: false)` is the 2.0 equivalent of the gem's `phlex { … }` helper (`Gate.render` in `test/test_helper.rb`, with generated ids pinned). A bare component also renders from Ruby through ActionView's renderable path: `GateController.render(RubyUI::Button.new, layout: false)`. Content blocks are ERB, so a scenario is always a view file.

## What the layer has, verified

Attribute pass-through and Tailwind override (`class:` over defaults, `nil` keeps the default, `key!` replaces); Phlex serialization semantics against Phlex 2.4.1 (15 hash shapes + 8 mix shapes, `test/attributes_differential_test.rb`); block with the component as argument; nested renders in a block; a component that renders nothing; a computed attribute read with no view context (`Button.new(variant: :outline).attrs["class"]`); `content.presence || placeholder` for empty and whitespace-only blocks; a generated id pinned and cross-referenced; a `<turbo-frame>` root; development boot with reloading.

## What it lacks, by design or not yet

- **No named slots, no DSL, no kit-style sugar** (`RubyUI.Dialog { }`). Plan §4: nothing else.
- **`attrs` keys are Strings** (`attrs["class"]`), the flat form `tag.attributes` consumes. 1.6 code that reads `attrs[:class]` (PaginationItem) changes one character when ported.
- **`true` serializes as `""`.** Rails then emits `disabled="disabled"` for HTML boolean attributes and `aria-x=""` for the rest; both canonicalize like Phlex's bare attribute. A boolean attribute given a *String* value (`hidden: "until-found"`) is rendered by Rails as `hidden="hidden"`, unlike Phlex. No 1.6 component does this.
- **Phlex's guards are not ported**: unsafe attribute names (`on*`, `srcdoc`), `javascript:` refs dropped, the `:id` key check. Also not ported: the leading space Phlex leaves when the first `style:` value is nil. Nothing in the snapshots depends on them; a 2.0 decision.
- **The development-only `<!-- Before RubyUI::X -->` comment** of 1.6 `Base#before_template` is not ported (invisible to the canonical form).
- **Templates share the view-path namespace with regular views.** A component sidecar `ruby_ui/dialog/dialog` and a user template with the same virtual path would shadow each other (the probe suite hit exactly this and moved its views to a distinct prefix). The `ruby_ui/` prefix under `app/components` makes it unlikely in practice; still a property to state in the decision document.
- **`helpers`** is the name for the view context; `ToggleGroup#ToggleGroupItem` (Phase 3) will be the first component to use it.
