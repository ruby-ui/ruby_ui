# Native over JS (stage 3)

Flag every place where RubyUI's Stimulus controller (or inline JS) does something
the browser already does. Read the component's controller at
`<checkout>/gem/lib/ruby_ui/<folder>/*_controller.js` and its rendered DOM.
Grade on the **Native** line (`grading.md` rule 6). MDN links: try the pt-BR
version first (see `spec-sources.md`).

## Hand-rolled behavior → native feature

| RubyUI hand-rolls | Native feature | MDN |
| --- | --- | --- |
| Modal: `<div role="dialog/alertdialog">` + JS focus trap, Esc handler, backdrop, `aria-hidden` on siblings | `<dialog>` + `showModal()` (top layer, `::backdrop`, inert page, Esc, initial focus) | https://developer.mozilla.org/pt-BR/docs/Web/HTML/Reference/Elements/dialog · https://developer.mozilla.org/en-US/docs/Web/API/HTMLDialogElement/showModal |
| Outside-click / Esc dismissal of a dialog in JS | `closedby="any"` on `<dialog>` (check browser support) | https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/dialog#closedby |
| Non-modal floating panel shown/hidden in JS, outside-click + Esc to close (popover, dropdown, tooltip shell) | `popover` attribute + `popovertarget` (top layer, light dismiss, Esc) | https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes/popover |
| Disclosure/accordion toggled in JS (`aria-expanded` flip + `hidden`) | `<details>` / `<summary>` (`name` for exclusive accordions) | https://developer.mozilla.org/pt-BR/docs/Web/HTML/Reference/Elements/details |
| `aria-hidden` / `tabindex=-1` sprayed on background content | `inert` attribute | https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes/inert |
| Validation styling toggled in JS after blur/submit | `:user-invalid` / `:user-valid` | https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Selectors/:user-invalid |
| Custom date/time/color/number pickers built in JS | `<input type="date">` and siblings (`time`, `datetime-local`, `month`, `week`, `color`, `number`, `range`) | https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/input/date (and siblings) |
| Collapsed content hidden with `display:none` that find-in-page can't reach | `hidden="until-found"` + `beforematch` | https://developer.mozilla.org/pt-BR/docs/Web/HTML/Reference/Global_attributes/hidden |

## When native would lose behavior shadcn provides

A native swap only passes (basis `native`) if it keeps what shadcn's Base UI
side does **as observed in the sandbox**. Check each item on both sides
before suggesting the swap or passing it:

- **Scroll lock**: Base UI locks page scroll under a modal; `showModal()`
  doesn't. Native needs CSS such as `html:has(dialog:modal) { overflow: hidden }`.
  If it's missing, that's a ⚠️ Behavior loss.
- **Exit animation**: a closing `<dialog>` leaves the top layer at once
  unless the CSS uses `@starting-style`, `transition-behavior: allow-discrete`
  and `overlay`/`display` transitions. Missing exit fade/zoom = ⚠️ Animation.
- **Outside click**: `<dialog>` doesn't close on a backdrop click by itself
  (`closedby="any"` or a click handler on the dialog element does it). Compare with shadcn:
  Dialog/Sheet close on outside click, AlertDialog does **not**.
- **Labelling**: native `<dialog>` doesn't wire `aria-labelledby` /
  `aria-describedby` to Title/Description. Base UI does. A missing name is ⚠️ ARIA
  (and a normative Spec miss, `spec-sources.md`).
- **Focus return**: `close()` returns focus to the previously focused
  element. Check that it's the trigger on both sides.
- **Initial focus**: `showModal()` focuses the first focusable or the
  `autofocus` element. Base UI focuses the popup or first tabbable. Record both;
  a different target is ⚠️ Behavior only if it hurts the APG expectation.
- **Popover positioning**: the `popover` attribute doesn't position the panel
  next to its trigger without CSS anchor positioning (`anchor-name`/`position-anchor`).
  If RubyUI relies on Floating UI for placement/flip/collision, native
  `popover` replaces show/hide and dismissal only. Say so, and don't flag the
  positioning JS.
- **Typeahead, roving focus, arrow keys** (menus, listboxes, command):
  there's no native equivalent. Don't flag that JS.

## How to word it

- Candidate: `❌ Native <div role="alertdialog"> + JS (focus trap, Esc) → candidate for <dialog> + showModal()`, `source` = MDN URL, `note` = what would need re-adding (scroll lock, exit animation).
- Kept: `✅ Native showModal(): inert, Esc and focus from the browser — native`.
- Native with a loss: `⚠️ Native <dialog> drops scroll lock (Base UI locks it)`, `source` = MDN URL.
