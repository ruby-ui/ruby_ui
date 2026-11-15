# Browser interaction sets

HTML, ARIA, Behavior and Animation verdicts come **only** from these runs, never
from the `.tsx` or the Ruby source. Drive them with the `audit-chrome` MCP
(`mcp__audit-chrome__*`, from the repo's `.mcp.json`: headless, isolated,
1280×800), never the chrome-devtools plugin's server. Run the same set on both URLs:

- shadcn: `http://localhost:5179/?c=<folder>&theme=<light|dark>` (sandbox `url_template`)
- RubyUI: `http://localhost:3179/__audit/<folder>?theme=<light|dark>` (preview `url_template`)

`collect` (SKILL.md step 3) already runs the setup below, the environment
probe, the states closed/open/focus/after-esc, the computed-style and ARIA
probes per part, and the screenshots, deterministically. Use this file for
what it doesn't cover: the per-`kind` sequences (focus trap order, Esc and
focus return, outside click, scroll lock, arrows, typeahead, Enter/Space),
animations, and any state `collect` reported as not reached.

## Setup (once per page)

1. `new_page` (one per side). `audit-chrome` starts every page at 1280×800
   with DPR 1; don't `resize_page`. The probe in step 3 confirms `w`, `h` and
   `dpr` on both sides; any mismatch (someone ran the plugin's headed server
   by mistake, say) goes to `environment_diffs`.
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
   its uid, `click`. Both fixtures carry exactly one such trigger. Use the real
   `click` tool whenever focus matters: a programmatic `.click()` in
   `evaluate_script` doesn't focus the trigger, so a later focus-return check
   would have nothing to return to.

Screenshots: `take_screenshot` with `filePath` =
`<run>/screens/<folder>-<state>-<rubyui|shadcn>-<light|dark>.png`; in
`report.json` write the path relative to the run folder (`screens/…`).
Minimum states: closed, open, keyboard focus, after Esc, in light and dark.

Paths for `filePath` must sit under the session's working directory (the
MCP rejects anything else); the run folder in `.shadcn-audit/runs/` does.

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
5. **Esc**: `press_key` Escape. Closed? Focus probe (should return to the
   trigger; valid only if it was opened with a real `click`).
   Screenshot "after Esc".
6. **Outside click**: reopen; `click` a uid outside the content (overlay/backdrop
   from `take_snapshot`). If no uid lands outside, dispatch a
   `pointerdown`/`mousedown`/`pointerup`/`mouseup`/`click` sequence at (10,10) via
   `evaluate_script` and say in the `note` that the events were synthetic. If
   the sides differ only under synthetic events, mark it ⏸. Expected: Dialog/Sheet/Command
   close, AlertDialog stays open.
7. **Focus return**: open with a real `click` on the trigger uid, close with a
   real `click` on the Cancel/close button uid (not `.click()` in
   `evaluate_script`), then focus probe → trigger.
8. **Scroll lock**: on a fresh load, make the page scrollable the same way on both
   sides (`document.body.style.minHeight = "300vh"`), scroll to 200, open, then
   `window.scrollBy(0, 400)` and read `scrollY` plus `getComputedStyle(document.documentElement).overflow`
   and the same for `body`. Locked = `scrollY` unchanged.
9. **Exit animation**: open, then in one `evaluate_script` start the close
   and sample with the animations probe. Close with `.click()` on the fixture's
   Cancel button (works on both sides); a synthetic `keydown` Escape doesn't
   close a native `<dialog>`, so don't use it here. Running fade/zoom on the shadcn popup with none on
   RubyUI → ⚠️ Animation. Also note the enter animation (sample right after open).
   This programmatic close says nothing about focus; don't read focus here.

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
`getBoundingClientRect`, in the recorded viewport). For listbox-like content (Command):
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

## Video

One video per audited component: the RubyUI side at the audited head, light
theme, on a fresh load of its preview URL. `screencast_start` with `filePath`
= `<run>/videos/<folder>-rubyui-light.mp4`, run the `kind`'s script below
with real `click` and `press_key` calls, wait about 1 s after the last step
so the closing animation lands, then `screencast_stop`. Pause about 0.5 s
between steps: the recorder only writes frames when the page repaints, and
the pauses keep each state on screen long enough to follow. The recorder is
built into Chrome (157 has it, 151 doesn't); "does not support screen
recording" means the user's Chrome needs an update, not a missing tool.

| kind | Script |
| --- | --- |
| `modal` | click the trigger; Tab twice; Escape; click the trigger again; click Cancel/close |
| `menu` | click the trigger; ArrowDown ×3; type the first letter of the third item; Enter; click the trigger again; Escape |
| `popover` | click the trigger; for listbox content, type two letters, ArrowDown, Enter; otherwise Tab once; Escape |
| `disclosure` | click the trigger; click it again; Tab to it and press Space twice |
| `form_control` | Tab into the control; operate it (type a value, or Space to toggle); Tab out; when the fixture has an invalid state, enter an invalid value and blur |
| `static` | no video |

The recorder writes MP4 in AV1, which current Chrome, Firefox and Edge play;
Safari plays AV1 only on Macs with hardware decoding (M3 and later). When
`ffmpeg` is on PATH, convert in place for any viewer:
`ffmpeg -y -i in.mp4 -c:v libx264 -pix_fmt yuv420p -movflags +faststart out.mp4`
(then replace the original). Without `ffmpeg`, keep the AV1 file. Add the
video to the component in `report.json`:
`"videos": [{"label": "walkthrough (light)", "rubyui": "videos/<folder>-rubyui-light.mp4"}]`.
