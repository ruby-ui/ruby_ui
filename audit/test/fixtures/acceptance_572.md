# shadcn-audit acceptance: PR #572

Pins: RubyUI PR #572 head `a9a5d1faee2257e8e83c144a5be88c378347640d`, base
`ddcff1c6e26825512006d732bbe408c48065c5d1`; shadcn `8f04138777c1b6996e709993362a7b0a12888ecf`
(`workspace --sha`). Sandbox lock: `@base-ui/react` 1.9.0, `cmdk` 1.1.1,
`tailwindcss` 4.3.3.

Run: 2026-10-26, `.shadcn-audit/runs/20261026-194918-pr572/` (gitignored).
`target 572` returned head `a9a5d1fa…` and state `OPEN`, so the pinned head was
audited directly (no `preview a9a5d1fa…` fallback needed). Components:
`alert_dialog`, `command`, `dialog`, `sheet` (none unmapped).

Legend: ✅ matched · ❌ missing · ➕ extra (produced, not in the expected list).

## Expected findings vs. what the run produced

| # | Expected (unprompted) | Run produced | Result |
| --- | --- | --- | --- |
| 1 | Dialog Look ✅ overlay `bg-black/10` + blur matches vega | `✅ Look overlay ::backdrop bg-black/10 + supports-backdrop-filter:backdrop-blur-xs` (computed `oklab(0 0 0 / 0.1)`, `blur(4px)` on both), `style-vega.css:464` | ✅ matched |
| 2 | Dialog Look ❌ border/shadow-lg/rounded-lg/gap-4/max-w-lg vs ring-1/rounded-xl/gap-6/sm:max-w-md | `❌ Look p-6 gap-4 border shadow-lg sm:rounded-lg max-w-lg bg-background` vs `p-6 gap-6 ring-1 ring-foreground/10 rounded-xl sm:max-w-md bg-popover`, `style-vega.css:468` | ✅ matched |
| 3 | Dialog Animation ⚠️ no exit fade | `⚠️ Animation no exit fade` vs `data-closed:animate-out fade-out-0 zoom-out-95 duration-100`, `style-vega.css:468` (getAnimations() after close: shadcn `exit` on overlay + content, RubyUI none) | ✅ matched |
| 4 | Dialog HTML ✅ intentional/native | `✅ HTML native <dialog> + showModal() — intentional`, `audit/divergences.yml` | ✅ matched |
| 5 | Dialog ARIA ⚠️ no `aria-labelledby`/`aria-describedby` | `⚠️ ARIA no aria-labelledby/aria-describedby on <dialog>` vs Base UI wiring "Edit profile" / "Make changes to your profile here.", `bases/base/ui/dialog.tsx:122` | ✅ matched |
| 6 | AlertDialog Native ❌ `<div>` + JS, candidate for `<dialog>`, cites MDN | `❌ Native <div role="alertdialog"> + JS (insertAdjacentHTML, body overflow-hidden)`, "candidate for <dialog> + showModal()", `https://developer.mozilla.org/pt-BR/docs/Web/HTML/Reference/Elements/dialog` | ✅ matched |
| 7 | Sheet Native ❌ `<div>` + JS, candidate for `<dialog>`, cites MDN | `❌ Native <div> panel + JS (insertAdjacentHTML, backdrop click, exit-animation removal)`, "candidate for <dialog> + showModal()", MDN pt-BR dialog | ✅ matched |
| 8 | CommandDialog Native ❌ `<div>` + JS, candidate for `<dialog>`, cites MDN | Command: `❌ Native <div> panel + JS (insertAdjacentHTML, backdrop/Esc dismiss)`, "candidate for <dialog> + showModal()", MDN pt-BR dialog | ✅ matched |
| 9 | Theme line present | `❌ Theme 10 token diffs vs shadcn neutral` | ✅ matched |
| 10 | Header carries the four SHAs | `shadcn audit PR #572 ruby-ui/ruby_ui` / `base ddcff1c6 head a9a5d1fa shadcn 8f041387` (comment table: Repo, PR, RubyUI base, RubyUI head, shadcn) | ✅ matched |
| 11 | HTML page with side-by-side screenshots for the four modals, open, light and dark | `report.html`: sections Dialog, AlertDialog, Sheet, Command; 48 images (6 states × 2 sides × 4), none broken, RubyUI and shadcn in one row (x=57 and x=646, same top); states include `open (light)` and `open (dark)` | ✅ matched |
| 12 | `comment` prints a body starting with `<!-- shadcn-audit -->`, not posted | `{"posted": false, "body": "<!-- shadcn-audit -->\n## shadcn audit …"}`; `--post` never run | ✅ matched |

All 12 expected items present. Nothing missing.

## Extras

Accepted beforehand:

| Line | Note |
| --- | --- |
| ➕ Dialog `❌ Spec <dialog> has no accessible name`, `https://www.w3.org/TR/wai-aria-1.2/#dialog` | Ruling R9 (grading rule 5). |
| ➕ Theme chart-1..5 diffs, light and dark (10 tokens) | RubyUI keeps colored charts; vega/neutral charts are greys (`oklch(0.87 0 0)` … `oklch(0.269 0 0)`). |

Not in the expected list, produced by this run (each seen in the browser or in
`reference` output):

| Component | Line |
| --- | --- |
| Environment | ➕ ⚠️ Font: sandbox loads "Inter Variable"; preview asks for Inter but loads no web font (system fallback). |
| Dialog | ➕ ❌ Look dark: `<dialog>` computed `color: rgb(0,0,0)` (UA default, no `text-foreground`), so title, body text and the Cancel label are black on `oklch(0.145 0 0)`. Visible in `screens/dialog-open-rubyui-dark.png`. A real bug, worth a look. |
| Dialog | ➕ ❌ Look header/title/footer: `space-y-1.5 text-center sm:text-left`, `h3 text-lg font-semibold tracking-tight`, `sm:space-x-2 gap-y-2` vs `gap-2`, `h2 leading-none font-medium font-heading`, `gap-2`. |
| Dialog | ➕ ✅ Behavior (native): initial focus Cancel, Esc closes and returns focus to the trigger, outside click closes, body overflow hidden on both. Tab wraps through browser chrome on the native side. |
| Dialog | ➕ ❌ Props: no `showCloseButton` (map → null). |
| Dialog | ➕ ✅ Native `showModal()` — native. |
| AlertDialog | ➕ ✅ Look overlay matches; ➕ ❌ Look content (gap-4/border/rounded-lg vs gap-6/ring-1/rounded-xl, bg-background vs bg-popover); ➕ ❌ Look header/title. |
| AlertDialog | ➕ ✅ HTML `<div role="alertdialog">` on both. |
| AlertDialog | ➕ ⚠️ ARIA: no labelledby/describedby, page behind not hidden. |
| AlertDialog | ➕ ❌ Spec: `role=alertdialog` with no accessible name, `#alertdialog` (same rule as R9). |
| AlertDialog | ➕ ⚠️ Behavior: focus not moved in, no trap (Tab reaches the trigger behind), Esc doesn't close, focus to body after Cancel. ➕ ✅ Behavior: outside click keeps it open on both, body overflow hidden. |
| AlertDialog | ➕ ⚠️ Animation: no exit animation. ➕ ❌ Props: no `size`. |
| Sheet | ➕ ✅ Look overlay; ➕ ❌ Look content (block p-6 bg-background 439px vs flex bg-popover w-3/4 sm:max-w-sm 384px); ➕ ❌ Look header/title. |
| Sheet | ➕ ❌ HTML: panel `<div>` with no role vs `role="dialog"`. ➕ ⚠️ ARIA: no role/name, trigger has no `aria-haspopup`/`aria-expanded`/`aria-controls`. ➕ ⚠️ Spec (APG recommendation) `dialog-modal/#roles_states_properties`. |
| Sheet | ➕ ⚠️ Behavior: focus not moved in, Esc doesn't close, no scroll lock (body overflow visible), focus to body after Cancel. ➕ ⚠️ Animation: slide duration-500/300 vs translate 2.5rem + opacity duration-200. ➕ ❌ Props: no `showCloseButton`. |
| Command | ➕ ✅ Look overlay; ➕ ❌ Look CommandDialogContent (top-[50%], border, rounded-lg, max-w-lg vs top-1/3, ring-1, rounded-xl!, sm:max-w-md, p-0); ➕ ⏸ Look inner parts not compared class by class. |
| Command | ➕ ❌ HTML: panel `<div>` with no role. ➕ ⚠️ ARIA: no dialog role/name; combobox `aria-expanded=""`, no `aria-controls`, no `aria-activedescendant`. ➕ ❌ Spec: combobox Required States and Properties (`aria-controls`, `aria-expanded`), `#combobox`. |
| Command | ➕ ⚠️ Behavior: no option active on open, focus to body after Esc. ➕ ⚠️ Animation: extra slide + duration-200 vs fade/zoom duration-100. ➕ ❌ Props: no `title`/`description`/`showCloseButton`. |

## Run artifacts (local, gitignored)

- Checklist text: `.shadcn-audit/runs/20261026-194918-pr572/checklist.txt`
- Report JSON: `.shadcn-audit/runs/20261026-194918-pr572/report.json`
- Screenshot page: `.shadcn-audit/runs/20261026-194918-pr572/report.html`
- Comment body (not posted): `.shadcn-audit/runs/20261026-194918-pr572/comment-body.md`
