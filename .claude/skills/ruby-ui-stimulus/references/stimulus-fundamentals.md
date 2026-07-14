# Stimulus controller fundamentals (ruby_ui flavour)

Controller-quality patterns adapted from The Hotwire Club's
`hwc-stimulus-fundamentals` (MIT — see `NOTICE.md`), with ruby_ui examples.
Use this when writing the JS controller; use `phlex-stimulus-conventions.md` for
the Ruby/Phlex side.

## The controller as a contract

A controller's public surface is its statics. Declare them; don't reach around
them.

- `static targets = [...]` — DOM nodes the controller reads/writes. Access via
  `this.<name>Target` / `this.<name>Targets`, guard with `this.has<Name>Target`.
- `static values = {...}` — reactive state, typed and defaulted. Reading/writing
  `this.<name>Value` syncs to the `data-*-value` attribute. A `<name>Changed`
  method is called automatically on change (and once on connect).
- `static outlets = [...]` — other controllers this one collaborates with.
- `static classes = [...]` — CSS class names supplied via `data-*-class`, instead
  of hardcoding class strings in JS.

```js
// popover_controller.js
export default class extends Controller {
  static targets = ["trigger", "content"];
  static values = {
    open: { type: Boolean, default: false },
    options: { type: Object, default: {} },
    trigger: { type: String, default: "hover" },
  };
}
```

## Lifecycle: symmetric setup and teardown

This is the rule that breaks most often under Turbo navigation. Whatever
`connect()` allocates, `disconnect()` must release. `popover_controller.js` is
the canonical example:

```js
connect() {
  this.closeTimeout = null;
  this.cleanup = null;          // Floating UI autoUpdate handle
  this.addEventListeners();
}

disconnect() {
  this.removeEventListeners();  // every listener added in connect()
  if (this.cleanup) this.cleanup();   // stop autoUpdate
}
```

Checklist for `disconnect()`:
- Remove every `addEventListener` (including `document`/`window` ones).
- `clearTimeout`/`clearInterval` any pending timers.
- Disconnect any `MutationObserver`/`ResizeObserver`/`IntersectionObserver`.
- Call cleanup handles from libraries (Floating UI `autoUpdate`, Embla, charts).

Bind handlers as class fields (`handleClick = (e) => {...}`) so the same
reference can be added and removed — see popover's `handleMouseEnter` etc.

## Idempotency

Controllers can connect more than once (Turbo restores, DOM re-inserts). `connect()`
must be safe to run repeatedly: null-out state up front, and never assume a fresh
element.

## React to state via value callbacks

Prefer `<name>Changed` over branching everywhere the state is used:

```js
openValueChanged(isOpen) {
  isOpen ? this.showPopover() : this.hidePopover();
}
```

Set `this.openValue = true` and let the callback drive the DOM.

## Prefer declarative wiring

- Pass data through **action parameters** and **values**, not by parsing
  `this.element.dataset` by hand.
- Multiple actions belong in one space-separated `data-action` string
  (see `select_item.rb`), including keyboard actions like
  `keydown.enter->…#selectItem keydown.esc->…#handleEsc`.
- Use `@window`/`@document` action scopes for outside-click and global keys
  instead of manually attaching to `document` where you can.

## Cross-controller communication via outlets

When a parent controller must coordinate children (e.g. `ruby-ui--select`
managing `ruby-ui--select-item`s), declare an outlet rather than querying the DOM
or dispatching brittle custom events. The parent gets typed access to each outlet
controller instance. Wiring shown in `phlex-stimulus-conventions.md` → Outlets.

## Feature detection

Guard optional browser APIs before exposing UI that needs them
(Clipboard, Web Share, View Transitions). Fall back gracefully; never assume
support.

## Avoid timing hacks

Don't use a fixed `setTimeout` as a stand-in for "the thing finished". Drive UI
off real signals: value-changed callbacks, `transitionend`, native events, or
(for server-driven flows) Turbo events like `turbo:submit-end`. The one legitimate
timer in popover is a short *debounce* on mouse-leave — and it is cleared on the
next mouse-enter and on disconnect, not used to detect completion.

## Escalation

If a component genuinely needs server-driven updates (partial re-render, live
push), that is Turbo Frames/Streams territory — out of scope for this skill.
Today the only server-driven case in the gem is `DataTable` (Turbo Frame). Most
components should stay client-side Stimulus.
