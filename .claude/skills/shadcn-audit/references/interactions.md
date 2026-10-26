# Browser interaction sets

HTML, ARIA, Behavior and Animation verdicts come **only** from these runs, never
from the `.tsx` or the Ruby source. Run the same set on both URLs:

- shadcn: `http://localhost:5179/?c=<folder>&theme=<light|dark>` (sandbox `url_template`)
- RubyUI: `http://localhost:3179/__audit/<folder>?theme=<light|dark>` (preview `url_template`)

## Setup (once per page)

1. `new_page` (one per side), then `resize_page` to **1280×800**.
2. `navigate_page` to the URL; `wait_for` the fixture text (e.g. the trigger label).
3. Environment probe (`evaluate_script`), on both sides:
   ```js
   () => ({
     w: innerWidth, h: innerHeight, dpr: devicePixelRatio,
     font: getComputedStyle(document.body).fontFamily,
     fonts: [...document.fonts].filter(f => f.status === "loaded").map(f => f.family),
     bodyClasses: getComputedStyle(document.body).backgroundColor + " / " + getComputedStyle(document.body).color,
     forms: (() => { const i = document.createElement("input"); i.type = "text"; document.body.append(i);
       const s = getComputedStyle(i); const r = s.appearance + " " + s.borderRadius + " " + s.borderColor; i.remove(); return r })(),
     dark: document.documentElement.classList.contains("dark"),
   })
   ```
   Any difference goes to `environment_diffs` **before** you grade visuals.
4. Open the component by clicking `[data-audit-trigger]`: `take_snapshot`, find
   its uid, `click`. Both fixtures carry exactly one such trigger.

Screenshots: `take_screenshot` with `filePath` =
`<run>/screens/<folder>-<state>-<rubyui|shadcn>-<light|dark>.png`; in
`report.json` write the path relative to the run folder (`screens/…`).
Minimum states: closed, open, keyboard focus, after Esc, in light and dark.

If a step can't be run (trigger not found, state not reachable, page error in
`list_console_messages`), the lines it feeds are ⏸ with the reason. Never
infer them.

## Reusable probes (`evaluate_script`)

```js
// Who has focus, described the same way on both sides
() => { const a = document.activeElement;
  return a && { tag: a.tagName, slot: a.dataset.slot, role: a.getAttribute("role"),
    text: a.textContent.trim().slice(0, 40), inPopup: !!a.closest('[role=dialog],[role=alertdialog],dialog,[role=menu],[role=listbox]') } }

// The open popup's HTML/ARIA facts
() => { const p = document.querySelector('dialog[open],[role=dialog],[role=alertdialog],[role=menu],[role=listbox]');
  if (!p) return null;
  const id = n => n && document.getElementById(n)?.textContent.trim();
  return { tag: p.tagName, role: p.getAttribute("role"), modal: p.matches(":modal"),
    ariaModal: p.getAttribute("aria-modal"), labelledby: id(p.getAttribute("aria-labelledby")),
    describedby: id(p.getAttribute("aria-describedby")), label: p.getAttribute("aria-label"),
    attrs: [...p.attributes].map(a => a.name + "=" + a.value),
    outer: p.outerHTML.slice(0, 600) } }

// Is the page behind inert / hidden?
() => [...document.body.children].map(e => ({ tag: e.tagName, inert: e.inert,
  ariaHidden: e.getAttribute("aria-hidden"), hasPopup: !!e.querySelector('dialog[open],[role=dialog],[role=alertdialog]') }))

// Classes per part. shadcn: [data-slot=<slot>]. RubyUI: locate the part by
// the selector you derived from its Ruby source (tag, Stimulus target, class).
(sel) => [...document.querySelectorAll(sel)].map(e => e.className.baseVal ?? e.className)

// Animations running right after a close starts
async () => { await new Promise(r => requestAnimationFrame(() => requestAnimationFrame(r)));
  return document.getAnimations().map(a => ({ name: a.animationName ?? a.transitionProperty,
    target: a.effect?.target?.dataset?.slot || a.effect?.target?.tagName, state: a.playState })) }
```

Use `get_css_styles` (or `getComputedStyle`) to settle Look tokens that read
differently but may compute the same.

## `modal` (Dialog, AlertDialog, Sheet, CommandDialog)

Run in light, then repeat open + screenshots in dark.

1. **Closed**: screenshot; trigger's ARIA (`aria-haspopup`, `aria-expanded`, `aria-controls`).
2. **Open**: click the trigger. Screenshot. Popup facts probe (tag, role,
   `:modal`, `aria-modal`, labelledby → Title text, describedby → Description
   text). Trigger `aria-expanded` now. Background inert/`aria-hidden` probe.
3. **Initial focus**: focus probe straight after opening.
4. **Tab / Shift+Tab**: `press_key` Tab (N+1 times, N = tabbables in the popup),
   then Shift+Tab as many; focus probe each time. Focus must stay inside (trap)
   on both sides; record the order. Screenshot the keyboard-focus state.
5. **Esc**: `press_key` Escape. Closed? Focus probe (should return to the trigger).
   Screenshot "after Esc".
6. **Outside click**: reopen; `click` a uid outside the content (overlay/backdrop
   from `take_snapshot`). If no uid lands outside, dispatch a
   `pointerdown`/`mousedown`/`pointerup`/`mouseup`/`click` sequence at (10,10) via
   `evaluate_script` and say in the `note` that the events were synthetic. If
   the sides differ only under synthetic events, mark it ⏸. Expected: Dialog/Sheet/Command
   close, AlertDialog stays open.
7. **Focus return**: after a close by the Cancel/close button, focus probe → trigger.
8. **Scroll lock**: on a fresh load, make the page scrollable the same way on both
   sides (`document.body.style.minHeight = "300vh"`), scroll to 200, open, then
   `window.scrollBy(0, 400)` and read `scrollY` plus `getComputedStyle(document.documentElement).overflow`
   and the same for `body`. Locked = `scrollY` unchanged.
9. **Exit animation**: open, then in one `evaluate_script` start the close
   and sample with the animations probe. Close with `.click()` on the fixture's
   Cancel button (works on both sides); a synthetic `keydown` Escape doesn't
   close a native `<dialog>`, so don't use it here. Running fade/zoom on the shadcn popup with none on
   RubyUI → ⚠️ Animation. Also note the enter animation (sample right after open).

If clicking the trigger of a non-modal `kind` opens a modal (a `dialog:modal`
or `aria-modal="true"` appears), run this set too. Command's fixture opens
`CommandDialog`: run the modal set, then the `popover` listbox checks below
inside it.

## `menu`

Open by click and by keyboard (focus trigger, Enter/Space/ArrowDown). Check:
trigger `aria-haspopup`/`aria-expanded`; roles `menu`/`menuitem*`; initial
focus on the first item; ArrowDown/ArrowUp/Home/End move focus (wrap?);
typeahead (type an item's first letter); Enter activates and closes; Esc closes
and returns focus to the trigger; outside click closes; Tab leaves and closes.
Screenshots: closed, open, item focused, after Esc; light and dark.

## `popover`

Open by click. Check: trigger `aria-expanded` (and `aria-controls`/`aria-haspopup`
when present on shadcn); popup role; whether focus moves in; Esc closes and
returns focus; outside click closes; placement vs the trigger (bounding boxes via
`getBoundingClientRect`, at 1280×800). For listbox-like content (Command):
input has `role=combobox`/`aria-controls`/`aria-activedescendant` as shadcn
does; ArrowDown/ArrowUp move the active option; typing filters; Enter selects;
empty state renders. Screenshots: closed, open, option active, after Esc;
light and dark.

## `disclosure`

Check: button `aria-expanded` + `aria-controls`; Enter and Space toggle;
content `hidden`/`display` when collapsed; open/close animation; multiple vs
single open (accordion). Screenshots: collapsed, expanded, focused; light and dark.

## `form_control`

Check: label association (`for`/`id` or wrapping), focus ring classes on
`:focus-visible` (Tab into it, screenshot), `disabled`, `required`,
`aria-invalid` and error styling after an invalid value + blur, native control
semantics (checkbox/switch role, `aria-checked`), keyboard toggling (Space).
Screenshots: default, focused, invalid, disabled; light and dark.

## `static`

Render + Look only: load, screenshot light and dark, compare classes per part.
HTML from the DOM (tags, nesting). Behavior/ARIA lines only if the component has
interactive parts.
