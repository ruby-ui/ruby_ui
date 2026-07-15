# Phlex ↔ Stimulus wiring conventions (ruby_ui)

How RubyUI components connect their Phlex markup to Stimulus controllers. All
examples are real code from `gem/lib/ruby_ui/`.

## Naming table

A component lives in a snake_case folder; its Stimulus identifier is the folder
path with `/` → `--` (so the `ruby_ui/` namespace becomes the `ruby-ui--`
prefix). Phlex converts each `_` in an attribute key to `-`, so `__` becomes
`--` in the emitted HTML.

| Thing | Folder / Ruby | Stimulus identifier | HTML attribute emitted |
| --- | --- | --- | --- |
| Controller | `popover/` → `popover_controller.js` | `ruby-ui--popover` | `data-controller="ruby-ui--popover"` |
| Target `trigger` | `ruby_ui__popover_target: "trigger"` | — | `data-ruby-ui--popover-target="trigger"` |
| Value `open` | `ruby_ui__popover_open_value: "false"` | `openValue` | `data-ruby-ui--popover-open-value="false"` |
| Action | `action: "click->ruby-ui--popover#toggle"` | — | `data-action="click->ruby-ui--popover#toggle"` |
| Outlet | `ruby_ui__select_ruby_ui__select_item_outlet: ".item"` | — | `data-ruby-ui--select-ruby-ui--select-item-outlet=".item"` |

The controller file itself is anonymous (`export default class extends
Controller`); the identifier comes from **where it is registered**, not from the
file. See "Registration" below.

## Two ways to write `data:` in `default_attrs`

Both are valid Phlex and both appear in the codebase. Pick one per component and
be consistent.

**Nested hash** (most common — `popover.rb`, `clipboard.rb`, `select.rb`):

```ruby
# gem/lib/ruby_ui/clipboard/clipboard.rb
def default_attrs
  {
    data: {
      controller: "ruby-ui--clipboard",
      action: "click@window->ruby-ui--clipboard#onClickOutside",
      ruby_ui__clipboard_success_value: @success,
      ruby_ui__clipboard_error_value: @error,
      ruby_ui__clipboard_options_value: @options.to_json
    }
  }
end
```

**Flattened keys** (`dialog_content.rb`) — the whole `data-...` name is one key:

```ruby
# gem/lib/ruby_ui/dialog/dialog_content.rb
def default_attrs
  {
    data_ruby_ui__dialog_target: "dialog",
    data_action: "click->ruby-ui--dialog#backdropClick",
    class: [...]
  }
end
```

`default_attrs` is merged with the caller's attributes by `Base#initialize`
(`gem/lib/ruby_ui/base.rb`) via Phlex `mix`, with Tailwind classes deduped by
`TailwindMerge`. So callers can add/override `data-*` and classes without
clobbering the component's wiring.

## Values

Pass values as strings/JSON from Ruby; declare their type in the controller:

```ruby
# popover.rb
ruby_ui__popover_options_value: @options.to_json      # Object value → JSON string
ruby_ui__popover_trigger_value: @options[:trigger] || "hover"
```

```js
// popover_controller.js
static values = {
  open: { type: Boolean, default: false },
  options: { type: Object, default: {} },   // parsed from the JSON string
  trigger: { type: String, default: "hover" },
};
```

React to changes with the auto-called `<name>Changed(newVal, oldVal)` callback
rather than polling.

## Targets

Child/sub-components mark themselves as targets of the parent controller:

```ruby
# select_item.rb — an item is a target of the ruby-ui--select controller
data: {
  controller: "ruby-ui--select-item",
  action: "click->ruby-ui--select#selectItem keydown.enter->ruby-ui--select#selectItem ...",
  ruby_ui__select_target: "item"
}
```

Multiple actions go in a single space-separated string, as above.

## Actions on non-element scopes

Use `@window` / `@document` scope for outside-click and global handlers:

```ruby
# clipboard.rb
action: "click@window->ruby-ui--clipboard#onClickOutside"
# select.rb
action: "click@window->ruby-ui--select#clickOutside"
```

A trigger sub-component can dispatch to an ancestor controller without declaring
its own `controller:` — it relies on the parent controller being on an ancestor
element:

```ruby
# dialog_trigger.rb
data: { action: "click->ruby-ui--dialog#open" }
```

## Outlets (parent ↔ child controllers)

The parent declares the outlet selector; the child is a separate controller the
parent can call into:

```ruby
# select.rb — parent declares the outlet to select-item
data: {
  controller: "ruby-ui--select",
  ruby_ui__select_ruby_ui__select_item_outlet: ".item"
}
```

Outlet attribute shape: `data-<controller>-<outlet-identifier>-outlet`, hence the
doubled `ruby_ui__…_ruby_ui__…_outlet` key in Ruby.

## Registration

- **Importmap** apps (Rails default): controllers are eager-loaded from
  `controllers/` — nothing to register manually.
- **esbuild/webpack** apps: the manifest `docs/app/javascript/controllers/index.js`
  is auto-generated; regenerate with `rake stimulus:manifest:update`. Each entry is:

  ```js
  import RubyUi__PopoverController from "./ruby_ui/popover_controller"
  application.register("ruby-ui--popover", RubyUi__PopoverController)
  ```

  Note the file path segment `ruby_ui/` + `popover_controller` maps to identifier
  `ruby-ui--popover`.

## Dependencies

Declare any JS package the controller imports (e.g. `@floating-ui/dom`,
`fuse.js`, `embla-carousel`) in two places:

- `gem/package.json` — for the gem's own dev/test.
- `gem/lib/generators/ruby_ui/dependencies.yml` — per-component map so the
  generator installs it into consumer apps (also lists required gems and other
  components a component depends on).
