---
name: ruby-ui-stimulus
description: >-
  Use when writing, reviewing, or debugging a Stimulus controller for a ruby_ui
  Phlex component — controller lifecycle, state via values, DOM via targets,
  inter-controller communication via outlets, and the ruby_ui-specific
  data-attribute / naming / registration conventions. Covers how a Phlex
  component wires Stimulus through `data:` in `default_attrs`. Adapted from
  The Hotwire Club skills (MIT); see NOTICE.md.
---

# RubyUI Stimulus conventions

RubyUI adds interactivity with Stimulus controllers colocated with each Phlex
component: `gem/lib/ruby_ui/<component>/<component>_controller.js`. The component
class wires the controller through the `data:` hash returned by `default_attrs`.
There is **no custom helper/DSL** — everything is plain Phlex attributes plus
Stimulus conventions.

This skill covers **client-side interactivity via Stimulus**, which is the norm
for RubyUI components. Turbo (Frames/Streams) is out of scope here — it is only
used server-driven, and today the sole case is `DataTable`.

## Core workflow

Building or changing a Stimulus-backed component:

1. **Write the controller** at `gem/lib/ruby_ui/<component>/<component>_controller.js`,
   extending `Controller` from `@hotwired/stimulus`. Keep a clean lifecycle
   (`connect`/`disconnect`) — see the guardrails below.
2. **Model the contract with statics, not ad-hoc DOM reads:**
   - `static values` for reactive state (`openValue`, `optionsValue`, …).
   - `static targets` for the DOM nodes the controller touches.
   - `static outlets` for talking to sibling/child controllers.
   Prefer these over reading `this.element.dataset` or querying the DOM by hand.
3. **Wire from the Phlex component** in `default_attrs`: set
   `data: { controller: "ruby-ui--<component>", … }`, plus targets, actions, and
   values using the underscore keys Phlex converts to `data-*` attributes. Exact
   naming table and worked examples: `references/phlex-stimulus-conventions.md`.
4. **Register & declare deps:**
   - Importmap apps eager-load `controllers/` — no manifest edit needed.
   - esbuild/webpack apps regenerate the manifest with
     `rake stimulus:manifest:update` (`docs/app/javascript/controllers/index.js`).
   - New JS packages go in `gem/package.json` **and** per-component in
     `gem/lib/generators/ruby_ui/dependencies.yml`.
5. **Update docs & tests** in the same PR: `<component>_docs.rb` and
   `test/ruby_ui/<component>_test.rb` (see `gem/AGENTS.md`).

## Guardrails

- **Symmetric setup/teardown.** Every listener, timer, `MutationObserver`, or
  Floating UI `autoUpdate` added in `connect()` must be removed/cleaned in
  `disconnect()`. `popover_controller.js` is the canonical example
  (`addEventListeners`/`removeEventListeners` + `this.cleanup()`).
- **Idempotent `connect()`.** Controllers reconnect on Turbo navigation and DOM
  changes; connecting twice must not double-bind or leak.
- **Declarative over imperative.** Reach for `static values` + action parameters
  before parsing `dataset` or hand-wiring `addEventListener`. Use `<name>Changed`
  value callbacks to react to state instead of scattering conditionals.
- **Feature-detect** browser APIs (Clipboard, Web Share, View Transitions, …)
  before exposing UI that depends on them.
- **No fixed timeouts as a proxy for completion.** Drive UI off real signals
  (value-changed callbacks, native/Turbo events), not a guessed `setTimeout`.
- **Always namespace `ruby-ui--`.** Controller identifiers, target/value/outlet
  keys all carry the `ruby-ui--<component>` prefix. Never register a bare
  identifier — it would collide with a consumer app's own controllers.
- **Don't invent a Ruby DSL** for data attributes. Follow the existing
  `data:` / `default_attrs` pattern documented in the references.

## Load references selectively

- `references/phlex-stimulus-conventions.md` — the ruby_ui-specific mechanics:
  naming table (folder → identifier → HTML attribute), how `default_attrs`
  wires `data:` (both nested-hash and flattened-key styles), outlets, manifest
  registration, and `dependencies.yml`. Read this to wire the Phlex side.
- `references/stimulus-fundamentals.md` — controller-quality patterns (lifecycle,
  values, targets, outlets, action parameters, guardrail rationale) adapted to
  Phlex/ruby_ui. Read this to write a well-behaved controller.

## Attribution

Controller-quality patterns and guardrails are adapted from
[The Hotwire Club skills](https://github.com/TheHotwireClub/hotwire_club-skills)
(`hwc-stimulus-fundamentals`), used under the MIT License. Full notice in
`NOTICE.md`.
