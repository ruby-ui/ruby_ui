# Dialog shadcn parity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close the Dialog findings from the PR #580 shadcn audit (Look, HTML, Props, ARIA, Animation, Spec) so a re-run of `/shadcn-audit` on Dialog has no ❌ and only registered or accepted ⚠️.

**Architecture:** Keep the native `<dialog>` + `showModal()` (registered divergence). Port vega classes onto the existing Phlex parts; wire ARIA (title/description ids, trigger state) and the exit animation in the existing Stimulus controller, because Phlex parts don't share state at render time. No new components.

**Tech Stack:** Ruby 3.3+/Phlex, Tailwind v4 + tw-animate-css, Stimulus, Minitest.

**Spec:** the audit run `/Users/cirdes/Workspaces/ruby_ui/.shadcn-audit/runs/20261029-094032-pr580/report.json` (Dialog lines), reference `apps/v4/registry/bases/base/ui/dialog.tsx` + `styles/style-vega.css:463-490` at shadcn `96da9cc7`.

## Global Constraints

- Reference is Base UI + vega + neutral (`gem/AGENTS.md#shadcn-reference`); never new-york-v4.
- Theme tokens (`--chart-*`) are already fixed on their own branch; out of scope here.
- Branch: `fix/dialog-shadcn-parity` (Herdr worktree `/Users/cirdes/.herdr/worktrees/ruby_ui/fix-dialog-shadcn-parity`), stacked on `fix/dialog-backdrop-click-570` (#580, still open); the PR targets that branch until #580 merges.
- `docs/app/views/docs/dialog.rb` and `gem/lib/ruby_ui/dialog/dialog_docs.rb` are identical copies today; keep them identical.
- The controller lives only in `gem/lib/ruby_ui/dialog/dialog_controller.js` (docs has a symlink).
- Out of scope: AlertDialog, Sheet, CommandDialog (same drift, separate PRs); `closedby="any"` (Safari ships it only in preview, MDN BCD); the env font diff.
- No push / PR / divergences.yml edits without Cirdes's ok.

## Decisions (made here, flagged for review)

1. **DialogTrigger keeps its `<div>` wrapper.** Phlex has no render prop, and callers pass non-button children (`docs/app/views/docs/dropdown_menu.rb:39` passes text + `class:`). The ARIA goes on the first interactive descendant instead. Suggest a divergences entry (Task 6) rather than changing HTML.
2. **Default `size` becomes `nil`**, which renders vega's `max-w-[calc(100%-2rem)] sm:max-w-md`. An explicit `size:` keeps today's `SIZES` value unchanged (`xs: "max-w-sm"` … `full: "max-w-full"`), so callers who pass a size see no change at any viewport. Visible change only for callers without `size:`: 512px → 448px at sm+, `100% - 2rem` below sm.
3. **Title becomes `<h2>`** (Base UI Title). Visible change for anyone styling `h3`.
4. **ARIA wiring is done by the controller at `connect()`**: ids are generated only when the element has none; `aria-labelledby` is added only when the dialog has neither `aria-labelledby` nor `aria-label`; `aria-describedby` only when absent.
5. **Exit animation**: controller sets `data-state` on the `<dialog>`; close waits only for the dialog's own animations and its `::backdrop` (`document.getAnimations().filter(a => a.effect?.target === dialog)`, never descendants), with `Promise.allSettled` so a cancelled animation still closes; none running → close immediately.
6. **Reduced motion**: add `motion-reduce:animate-none` (panel) and `motion-reduce:backdrop:animate-none`. Base UI doesn't do this, so it's an extra token: suggest a divergences entry (Task 6).

## Review Focus

- Long content: dropping `max-h-screen overflow-y-auto` must still scroll a dialog taller than the viewport (UA `dialog:modal` gives `max-height: calc(100% - 2em - 6px)` + `overflow: auto`; confirm in the browser, keep the classes if it doesn't).
- Esc pressed twice quickly / Esc during the exit animation: dialog must end closed, body scroll unlocked, `aria-expanded="false"`.
- `prefers-reduced-motion: reduce` (no animation runs): close must not hang waiting for `finished`.
- A child with an infinite animation (spinner, `animate-spin`) inside the dialog: close still completes.
- Trigger without an interactive child (dropdown_menu case): ARIA goes on the nearest `[role=menuitem]`/`[role=button]` ancestor, never on a role-less `<div>`; no JS error.
- Explicit `size: :xs` at a 600px viewport stays 384px (no width change for callers passing `size:`).
- Dialog opened with `open: true` at render: `data-state="open"` and `aria-expanded="true"` set on connect.

---

### Task 1: Content panel, overlay and text color (Look)

**Files:**
- Modify: `gem/lib/ruby_ui/dialog/dialog_content.rb`
- Test: `gem/test/ruby_ui/dialog_test.rb`

**Interfaces:**
- Produces: `DialogContent.new(size: nil, show_close_button: true, **attrs)` (show_close_button lands in Task 3). `DEFAULT_WIDTH = "max-w-[calc(100%-2rem)] sm:max-w-md"` used when `size` is nil; `SIZES` unchanged and used alone when `size` is given.

- [ ] **Step 1: Write failing tests**
  - `test_dialog_content_vega_classes`: classes include `open:grid gap-6 rounded-xl p-6 text-sm ring-1 ring-foreground/10 bg-popover text-popover-foreground outline-none`; exclude `border shadow-lg gap-4 sm:rounded-lg bg-background`.
  - `test_dialog_content_overlay_classes`: classes include `backdrop:bg-black/10` and `supports-backdrop-filter:backdrop:backdrop-blur-xs`; exclude `backdrop:bg-background/80`.
  - `test_dialog_content_default_width`: no `size:` → includes `max-w-[calc(100%-2rem)]` and `sm:max-w-md`.
  - `test_dialog_content_sizes` stays as is (explicit sizes unchanged) and also refutes `max-w-[calc(100%-2rem)]` for each explicit size; update `test_dialog_content_does_not_force_display_when_closed` to `open:grid` (still refute bare `grid`/`flex`).
- [ ] **Step 2:** `cd gem && bundle exec rake test TEST=test/ruby_ui/dialog_test.rb` → the new tests FAIL.
- [ ] **Step 3:** Replace the class string with vega's `effective` classes for `dialog-content` (minus `data-open/closed` animation tokens, Task 4) plus `fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-50 w-full`, the `backdrop:` overlay tokens and `@size ? SIZES[@size] : DEFAULT_WIDTH`. Drop `max-h-screen overflow-y-auto md:w-full pointer-events-auto` unless Review Focus #1 fails in the browser.
- [ ] **Step 4:** Same test command → PASS; `bundle exec standardrb`.
- [ ] **Step 5:** Commit `[Bug Fix] Dialog: vega panel, overlay and text color`.

### Task 2: Header, Title, Description, Footer (Look + HTML)

**Files:**
- Modify: `gem/lib/ruby_ui/dialog/dialog_header.rb`, `dialog_title.rb`, `dialog_description.rb`, `dialog_footer.rb`
- Test: `gem/test/ruby_ui/dialog_test.rb`

**Interfaces:**
- Produces: `DialogTitle` renders `<h2 data-ruby-ui--dialog-target="title">`; `DialogDescription` renders `<p data-ruby-ui--dialog-target="description">` (Task 5 consumes both targets).

- [ ] **Step 1: Write failing tests**
  - `test_dialog_title_is_h2_with_vega_classes`: `<h2`, classes `font-heading leading-none font-medium`, target `title`.
  - `test_dialog_description_link_classes`: includes `*:[a]:underline *:[a]:underline-offset-3 *:[a]:hover:text-foreground`, target `description`.
  - `test_dialog_header_classes`: exactly `flex flex-col gap-2`.
  - `test_dialog_footer_classes`: `flex flex-col-reverse gap-2 sm:flex-row sm:justify-end`.
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Port the classes from `style-vega.css:475-490`. `font-heading` exists (`--font-heading`, `docs/app/assets/stylesheets/application.tailwind.css:145`); check the install template defines it too and add it there if missing.
- [ ] **Step 4:** Run → PASS; standardrb.
- [ ] **Step 5:** Commit `[Bug Fix] Dialog: vega header, title (h2), description, footer`.

### Task 3: Close button look + `show_close_button` (Look + Props)

**Files:**
- Modify: `gem/lib/ruby_ui/dialog/dialog_content.rb`, `dialog_footer.rb`, `audit/component_map.yml` (dialog `props`), `gem/lib/generators/ruby_ui/dependencies.yml` (add `dialog: components: ["Button"]`, as `alert_dialog` does)
- Test: `gem/test/ruby_ui/dialog_test.rb`

**Interfaces:**
- Produces: `DialogContent(show_close_button: true)`, `DialogFooter(show_close_button: false)`. Footer's close is `RubyUI::Button(variant: :outline, data: {action: "click->ruby-ui--dialog#dismiss"}) { "Close" }` rendered after the children. Map: `DialogContent: {showCloseButton: show_close_button}`, same for `DialogFooter`.

- [ ] **Step 1: Write failing tests**
  - `test_content_hides_close_button`: `show_close_button: false` → no `sr-only">Close`.
  - `test_content_close_button_vega_classes`: `absolute top-4 right-4 size-8` and `hover:bg-muted`; no `opacity-70`.
  - `test_footer_close_button`: default renders no dismiss button; `show_close_button: true` renders a button with text `Close` and the dismiss action, after the children.
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Content close button classes from the sandbox DOM (`dialog-close:Close` in the run): ghost `icon-sm` → `size-8 rounded-[min(var(--radius-md),10px)] inline-flex items-center justify-center outline-none transition-all hover:bg-muted hover:text-foreground dark:hover:bg-muted/50 focus-visible:ring-3 focus-visible:ring-ring/50 [&_svg]:size-4 absolute top-4 right-4`. Swap the radix icon for the lucide X to match `XIcon`: `viewBox="0 0 24 24"`, `fill="none"`, `stroke="currentColor"`, `stroke-width="2"`, `stroke-linecap="round"`, `stroke-linejoin="round"`, two `path`s `M18 6 6 18` and `m6 6 12 12`.
- [ ] **Step 4:** Run → PASS; standardrb; `cd gem && bundle exec rake test TEST=test/generators/component_generator_test.rb` stays green with the new dependency. `cd audit && mise exec -- bundle exec rake test` (map loads).
- [ ] **Step 5:** Commit `[Feature] Dialog: show_close_button on content and footer`.

### Task 4: Enter/exit animation (Animation)

**Files:**
- Modify: `gem/lib/ruby_ui/dialog/dialog_content.rb`, `dialog_controller.js`
- Test: `gem/test/ruby_ui/dialog_test.rb` (markup); browser check in Task 7

**Interfaces:**
- Produces in the controller: `open(e)` sets `data-state="open"` before `showModal()`; `dismiss()` → `animateClose()`; `async animateClose(): void` returns if `this.closing`, sets `closing = true` and `data-state="closed"`, awaits `Promise.allSettled(this.ownAnimations().map(a => a.finished))` (empty → immediate), then `dialog.close()`; `ownAnimations()` = `document.getAnimations().filter(a => a.effect?.target === this.dialogTarget)` (panel + `::backdrop`, no descendants). A `cancel` listener calls `e.preventDefault()` + `animateClose()`. `handleClose` (existing) resets `closing = false`, removes `data-state`, sets trigger `aria-expanded="false"` (Task 5); `disconnect()` also resets `closing` and removes the `cancel` listener.

- [ ] **Step 1: Write failing test** `test_dialog_content_animation_classes`: includes `data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 duration-100 motion-reduce:animate-none` and backdrop `data-[state=open]:backdrop:animate-in data-[state=open]:backdrop:fade-in-0 data-[state=closed]:backdrop:animate-out data-[state=closed]:backdrop:fade-out-0 backdrop:duration-100 motion-reduce:backdrop:animate-none`; refutes `open:animate-in` and `duration-200`.
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Add classes; implement the controller methods above. `backdropClick` keeps calling `dismiss()`.
- [ ] **Step 4:** Run → PASS; standardrb. In the docs app (`cd docs && bin/dev`), with the browser: computed `animation-duration` is `0.1s` on the `<dialog>` and its `::backdrop`; open/close via Cancel, X, Esc, backdrop; with DevTools "prefers-reduced-motion: reduce" no animation runs and close is immediate; Esc twice fast; a temporary `animate-spin` child inside the dialog doesn't block close. Each ends closed, body unlocked, panel doesn't flash back before close.
- [ ] **Step 5:** Commit `[Bug Fix] Dialog: animate open and close`.

### Task 5: Accessible name and trigger state (ARIA + Spec)

**Files:**
- Modify: `gem/lib/ruby_ui/dialog/dialog_trigger.rb`, `dialog_controller.js`
- Test: `gem/test/ruby_ui/dialog_test.rb`

**Interfaces:**
- Consumes: targets `title`, `description` (Task 2).
- Produces: `DialogTrigger` adds `data-ruby-ui--dialog-target="trigger"`. Controller `static targets = ["dialog", "title", "description", "trigger"]`; `connect()` calls `wireAria()`: ensure the dialog has an id; for the first `title`/`description` target inside the dialog, ensure an id and set `aria-labelledby` on the dialog only if it has neither `aria-labelledby` nor `aria-label`, and `aria-describedby` only if absent; for each trigger target, `interactive = trigger.querySelector("button, a[href], [role=button]") || trigger.closest("[role=menuitem], [role=button]")`, and if found set `aria-haspopup="dialog"`, `aria-controls=<dialog id>`, `aria-expanded` = open state. `open()` sets `aria-expanded="true"`, `handleClose` `"false"`. Ids: `ruby-ui-dialog-${counter}-{title|description|content}` with a module-level counter.

- [ ] **Step 1: Write failing test** (markup only; `gem/` has no JS test runner, the controller is checked in Step 4 and Task 7): `test_trigger_has_trigger_target` asserts `data-ruby-ui--dialog-target="trigger"` on the trigger wrapper.
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Implement as above.
- [ ] **Step 4:** Run → PASS; standardrb. Browser (docs app): a11y tree shows `dialog "Title" modal` with description; trigger button `expanded` toggles; a dialog with `aria-label` keeps that name (no `aria-labelledby` added); on the dropdown_menu page the `menuitem` gets `aria-haspopup="dialog"`/`aria-expanded`, no console error, no ARIA on the role-less `<div>`.
- [ ] **Step 5:** Commit `[Bug Fix] Dialog: name the dialog and expose trigger state`.

### Task 6: Docs, registry, divergence suggestion

**Files:**
- Modify: `docs/app/views/docs/dialog.rb` and `gem/lib/ruby_ui/dialog/dialog_docs.rb` (identical), `mcp/data/registry.json` (generated)

- [ ] **Step 1:** Docs: add a "Close button" example (`DialogContent(show_close_button: false)` + `DialogFooter(show_close_button: true)`), describe the default width (no `size:` → vega's `sm:max-w-md`; explicit sizes unchanged). Keep both files identical (`diff` prints nothing).
- [ ] **Step 2:** `cd docs && bin/rails db:test:prepare test && bundle exec standardrb` → green.
- [ ] **Step 3:** `cd mcp && bundle exec rake mcp:build`, then `bundle exec rake` in `mcp/` → green.
- [ ] **Step 4:** Prepare (do not commit) the divergences entry for Cirdes to add:
  ```yaml
  - component: dialog
    dimension: HTML
    rubyui: "DialogTrigger <div> wrapping its child; ARIA set on the first interactive descendant"
    shadcn: "trigger is the <button> itself (render prop)"
    reason: "Phlex has no render prop and callers pass non-button children; the wrapper only carries the Stimulus action."
    since: "2026-10-29"
  - component: dialog
    dimension: Animation
    rubyui: "motion-reduce:animate-none on the panel and ::backdrop"
    shadcn: "animations run regardless of prefers-reduced-motion"
    reason: "Respect prefers-reduced-motion; the controller closes at once when no animation runs."
    since: "2026-10-29"
  ```
- [ ] **Step 5:** Commit `[Documentation] Dialog: close button options and default size`.

### Task 7: Re-audit

- [ ] **Step 1:** `/shadcn-audit` on the new PR. Expected: Dialog Look/HTML/Props/ARIA/Animation/Spec lines ✅ except the trigger wrapper and `motion-reduce` tokens (✅ intentional once the entries exist) and Native closedby ⚠️ (accepted).
- [ ] **Step 2:** Re-run the 8 backdrop scenarios from the #580 run (padding, drags, backdrop) to confirm no regression from the animated close.
- [ ] **Step 3:** Show Cirdes the audit body; PR only after the ok, then the `cubic` skill.
