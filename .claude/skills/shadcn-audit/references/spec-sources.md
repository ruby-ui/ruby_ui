# Spec sources (stage 2)

Stage 2 checks **shadcn's rendered DOM and behavior** (from the sandbox, never the
`.tsx`) against official sources. The same sources grade RubyUI per `grading.md`.

## Weights

| Weight | Source | Base URL | A miss is |
| --- | --- | --- | --- |
| Normative | HTML Living Standard | https://html.spec.whatwg.org/multipage/ | a violation (❌ for RubyUI alone, ⚠️ when RubyUI copies shadcn) |
| Normative | WAI-ARIA 1.2 | https://www.w3.org/TR/wai-aria-1.2/ | a violation |
| Normative | ARIA in HTML | https://www.w3.org/TR/html-aria/ | a violation |
| Guidance | WAI-ARIA Authoring Practices (APG) | https://www.w3.org/WAI/ARIA/apg/patterns/ | ⚠️ "recommendation", never a violation |
| Explanatory | MDN | https://developer.mozilla.org/pt-BR/docs/ (prefer), fallback https://developer.mozilla.org/en-US/docs/ | never a finding on its own; cites the normative text or explains it |

MDN: try the pt-BR page first (swap `en-US` for `pt-BR` in the path). Many
pages exist only in en-US (e.g. `showModal`, `popover`, `inert`); if pt-BR
returns 404, cite en-US.

## The citation rule

Every Spec finding (and every ARIA/HTML line that leans on a spec) carries:

1. **`source`**: the exact URL **with anchor**, e.g.
   `https://www.w3.org/TR/wai-aria-1.2/#dialog`.
2. **The unmet condition**, in `note`: what the text requires and what the DOM
   showed. Example: "WAI-ARIA 1.2 dialog: Accessible Name Required = True;
   `<dialog>` has no aria-labelledby/aria-label/title".

Open the page before citing it and check that the anchor exists. Don't cite from
memory. If you can't find the clause, there's no Spec finding: drop it, or make
the line ⏸ with "spec clause not located".

## Anchors checked on 2026-10-26

HTML Living Standard:
- `<dialog>`: https://html.spec.whatwg.org/multipage/interactive-elements.html#the-dialog-element
- `showModal()`: https://html.spec.whatwg.org/multipage/interactive-elements.html#dom-dialog-showmodal
- dialog focusing steps: https://html.spec.whatwg.org/multipage/interactive-elements.html#dialog-focusing-steps
- `<details>` / `<summary>`: https://html.spec.whatwg.org/multipage/interactive-elements.html#the-details-element, `#the-summary-element`
- `popover`: https://html.spec.whatwg.org/multipage/popover.html#the-popover-attribute
- `inert`: https://html.spec.whatwg.org/multipage/interaction.html#the-inert-attribute
- `hidden` (incl. `until-found`): https://html.spec.whatwg.org/multipage/interaction.html#the-hidden-attribute

WAI-ARIA 1.2 (`https://www.w3.org/TR/wai-aria-1.2/#…`): `dialog`, `alertdialog`,
`aria-modal`, `aria-labelledby`, `aria-describedby`, `aria-hidden`,
`aria-expanded`, `aria-haspopup`, `aria-controls`, `menu`, `menuitem`,
`combobox`, `listbox`, `option`.

ARIA in HTML (`https://www.w3.org/TR/html-aria/#…`): `docconformance` (the
allowed-roles table), `el-dialog`, `el-details`, `el-summary`.

APG (`https://www.w3.org/WAI/ARIA/apg/patterns/<pattern>/`): `dialog-modal`,
`alertdialog`, `menu-button`, `disclosure`, `combobox`; sections
`#keyboard_interaction` and `#roles_states_properties`.

## What to check per kind (starting points, not a closed list)

- **modal**: role `dialog`/`alertdialog` (native `<dialog>` counts); an
  accessible name; `aria-describedby` when there's a description (APG);
  `aria-modal="true"` or a real modal (`showModal()`); content behind is inert or
  `aria-hidden`; focus moves in on open and back to the trigger on close (APG);
  Esc closes (APG); `alertdialog` doesn't close on outside click (APG).
- **menu**: trigger `aria-haspopup` + `aria-expanded`; items `menuitem*`; arrow
  keys, Home/End, typeahead, Esc returns focus (APG menu-button).
- **popover**: trigger `aria-expanded`, plus `aria-controls`/`aria-haspopup`
  when a role demands it; Esc closes; focus return.
- **disclosure**: button `aria-expanded` and `aria-controls`; Enter/Space toggle.
- **form_control**: label association, `aria-invalid`/`aria-describedby` for
  errors, native `required`/`disabled` semantics.

## React Aria: second opinion only

`.shadcn-audit/ui/apps/v4/registry/bases/aria/ui/<name>.tsx` (and React
Aria's behavior) is consulted **only** when the Base UI side looks wrong,
e.g. Base UI sets `aria-hidden` on siblings while React Aria uses `inert`.
A disagreement is settled by the normative spec above, never by picking a
library. React Aria is never the reference for Look, HTML or Props.
