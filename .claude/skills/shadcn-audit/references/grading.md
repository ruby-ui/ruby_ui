# Grading

How each `report.json` line gets its `status` and `basis`. `ShadcnAudit::Report`
validates the shape: a `pass`, `warn` or `fail` with no `source`, a
`fail`/`warn` Spec line without an `http` source, and a `pass` with basis
`spec` without an `http` source are all rejected.

## Statuses

| `status` | Shows as | Use when |
| --- | --- | --- |
| `pass` | ✅ | RubyUI matches the reference **and you saw the evidence** (resolved classes, the DOM, a browser run). |
| `warn` | ⚠️ | Behavior, ARIA or Animation differ from shadcn; an APG recommendation is unmet; a judgment call. |
| `fail` | ❌ | Look, HTML or Props differ and the difference isn't registered; hand-rolled JS where a native feature fits (Native); RubyUI alone breaks a normative spec (Spec). A normative miss that shadcn also has is ⚠️ (rule 1). |
| `inconclusive` | ⏸ | You couldn't verify it. The `note` gives the reason: sandbox didn't build, state not reachable, no shadcn equivalent, unmapped folder, reference `warnings` the DOM couldn't settle. |

**Nothing unverified is ever `pass`.** No browser run, no ✅ on HTML, ARIA,
Behavior or Animation. When unsure, use ⏸ and say what's missing.

## Basis (only on `pass`)

| `basis` | Shows as | Rule |
| --- | --- | --- |
| `intentional` | ✅ … — intentional | The difference matches an entry from `divergences <folder>` (same `dimension`). `source` = `audit/divergences.yml`, `note` = its `reason`. |
| `native` | ✅ … — native | RubyUI swaps shadcn's JS for a native feature **and keeps** what shadcn delivers: focus in and back, Esc, dismiss, inertness of the page behind. Labelling is markup, graded on the ARIA line, not here. Tag differences go in `note`. No registration needed. |
| `spec` | ✅ … — follows spec | shadcn breaks a spec (stage 2) and RubyUI follows it. `source` = the spec URL#anchor. No registration needed. |

`basis` stays `null` on every other line.

A registered divergence covers only the difference its `rubyui`/`shadcn`
fields describe. Any other difference in the same component and dimension is
still graded on its own and is still a finding.

## Order of precedence

1. **The spec beats shadcn.** If shadcn's rendered DOM or behavior breaks a
   source from `spec-sources.md`:
   - RubyUI follows the spec → ✅ basis `spec`, "diverges from shadcn, follows the spec (<URL#anchor>)".
   - RubyUI copies shadcn's violation → ⚠️ on a `Spec` line (normative or APG alike), citing the URL and the unmet condition.
2. **Registered divergence** → ✅ basis `intentional`.
3. **Native replacement keeping shadcn's behavior/ARIA** → ✅ basis `native`.
   If the native version **loses** something shadcn does (e.g. `showModal()`
   doesn't lock page scroll, Base UI does), that loss is the finding: ⚠️ on
   the Behavior/ARIA line that shows it, and the Native line is ⚠️ naming the
   loss instead of ✅.
4. **Anything else that differs** → ❌ for Look, HTML, Props; ⚠️ for Behavior,
   ARIA, Animation.
5. **RubyUI alone breaks a normative spec** (shadcn complies) → ❌ on a `Spec`
   line with the URL#anchor, in addition to the ARIA/HTML line describing the
   difference with shadcn. An APG-only gap there is ⚠️ "recommendation".
6. **Native dimension**: RubyUI hand-rolls (JS) what a native feature in
   `native-html.md` does → ❌ "candidate for <feature>", citing MDN. Native
   already used and nothing lost → ✅ basis `native`.

## Per-dimension notes

- **Look**: compare per part, light and dark. Class tokens that differ but
  compute to the same value (`left-[50%]` vs `left-1/2`, `end-4` vs `right-4`
  in LTR) are ✅ with a note, once `getComputedStyle` confirms the match. One line
  per part that differs; group matching parts in a single ✅ line.
- **Props**: from `map <folder>`. A shadcn prop mapped to `null` → ❌ ("no
  `showCloseButton`"). `rubyui_only` kwargs → a `note` on the Props line,
  never a failure. A prop the `.tsx` declares (reference `parts.<slot>.props`)
  that the map lacks → ⏸ "map gap", and tell the user to add it to
  `audit/component_map.yml`.
- **Reference `unresolved`** (cn-* markers with no vega rule): shadcn's CLI
  strips them, so they add no classes. Mention in a `note`, never as a missing
  class.
- **Reference `warnings`** (classes it couldn't extract, parts rendered via
  `<Button>` or a `render` prop, unattributed tokens): the Look line for that
  part is ⏸ unless the sandbox DOM shows the final classes. If it does, grade from the DOM
  and cite "sandbox DOM" in `source`.
- **Theme** is not a component line. It comes from `theme --checkout <preview path>`
  as-is. Every theme diff is a real finding: report it, never suppress it.
- **Environment**: if the font, plugins, viewport or global rules differ between
  the two servers, add the difference to `environment_diffs` first, and don't
  blame the component for a visual gap that difference explains (⏸ or a note).

## Fixture-originated differences (never findings)

The fixtures in `audit/fixtures/<folder>/` keep identical strings on both sides,
but a few wrappers differ because each library structures the body its own way.
These are not component findings. Leave them out, or at most add a `note`:

- **Sheet body**: shadcn's fixture wraps the body in `<div className="px-4">`; RubyUI
  uses `SheetMiddle`. Don't compare `SheetMiddle` with `div.px-4` as a part.
- **Dialog body**: shadcn's fixture puts a bare `<p>` in `DialogContent`; RubyUI
  wraps it in `DialogMiddle`. `DialogMiddle` maps to `null` (no shadcn part).

Any other difference between the two fixture trees: check `audit/fixtures/<folder>/`
before blaming the component.

## Scope rules

- Pre-existing drift is reported **mixed with** drift the PR introduced. No
  "old debt" section, no filtering by changed lines.
- The audit never edits PR code, `divergences.yml` or `component_map.yml`.
  When a difference looks deliberate, show a ready-to-paste divergences entry
  (fields: `component`, `dimension`, `rubyui`, `shadcn`, `reason`, `since`)
  for the PR author to add by hand.

## Worked examples: PR #572

From `audit/test/fixtures/report_572.json` (pins: head `a9a5d1fa`, base
`ddcff1c6`, shadcn `8f041387`).

| Line | Why |
| --- | --- |
| Dialog ✅ Look `overlay bg-black/10 + supports-backdrop-filter:backdrop-blur-xs` | Effective vega classes for `dialog-overlay` match the RubyUI overlay's classes in the DOM. `source: style-vega.css:464`. |
| Dialog ❌ Look `p-6 gap-4 border shadow-lg sm:rounded-lg max-w-lg` vs `p-6 gap-6 ring-1 ring-foreground/10 rounded-xl sm:max-w-md` | Look difference, not registered → ❌. Both values concrete, `source: style-vega.css:468`. |
| Dialog ⚠️ Animation "no exit fade" vs `data-closed:fade-out-0 duration-100` | Seen in the browser: shadcn's popup runs an animation on close, RubyUI's disappears at once. Animation → ⚠️, `source: style-vega.css:468`. |
| Dialog ✅ HTML native `<dialog>` — intentional | `divergences dialog` has the HTML entry → basis `intentional`, `source: audit/divergences.yml`. |
| Dialog ⚠️ ARIA "no aria-labelledby/aria-describedby" | Base UI wires Title/Description in the sandbox DOM; RubyUI doesn't. ARIA → ⚠️, `source: bases/base/ui/dialog.tsx:122-138`. (A dialog with no accessible name also breaks WAI-ARIA 1.2 `#dialog` "Accessible Name Required", which is a separate ❌ Spec line, rule 5.) |
| Dialog ⏸ Behavior "scroll lock not exercised" | The state wasn't reached. Never ✅ by default. |
| Dialog ✅ Native `showModal()` — native | Native `<dialog>` gives inert, Esc and focus. Scroll lock is kept on both sides (RubyUI's controller adds `overflow-hidden` to `body`; Base UI locks it too), so nothing shadcn delivers is lost. `source` = MDN showModal. |
| AlertDialog ❌ Native `<div role="alertdialog"> + JS` | Hand-rolled modal where `<dialog>` + `showModal()` fits → "candidate for `<dialog>`", `source: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/dialog`. Same for Sheet and CommandDialog. |
