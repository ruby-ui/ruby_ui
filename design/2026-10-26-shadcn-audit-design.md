# shadcn fidelity audit — design spec

Date: 2026-10-26
Status: draft, builder-checked (pending Cirdes' review)

## Why

RubyUI is meant to mirror shadcn/ui. Today nothing checks that. Comparing a PR against shadcn by hand is slow enough that it doesn't happen: PR #572 (`[Bug Fix] Overlays: use shadcn's nova overlay on every modal`) was reviewed without it. That PR was right about the overlay, but it left the rest of the Dialog in the old new-york look (border/shadow/radius/padding), missing exit animations, and three modals (`AlertDialog`, `Sheet`, `Command`) built as `<div>` + JS where a native `<dialog>` would do. None of that is visible without a side-by-side comparison.

The goal is a mechanism that does that comparison for the reviewer (and for contributors before they open a PR), and that stops the drift at the source by teaching the agent that writes components what the reference is.

## The reference (decided)

"shadcn" means the `main` branch of `shadcn-ui/ui`, specifically:

- **Behavior, HTML, ARIA, props/API: the Base UI base** — `apps/v4/registry/bases/base/ui/<component>.tsx`. Base UI has been shadcn's default base since Jul/2026 (changelog `2026-07-base-ui-default.mdx`), and it keeps the component/prop names RubyUI already uses (`DialogContent`, `DialogTrigger`, `showCloseButton`, …). Radix is legacy-supported, React Aria is an alternative (changelog `2026-07-react-aria.mdx`), not a replacement.
- **Look and feel: the `vega` style** — `apps/v4/registry/styles/style-vega.css`. shadcn calls vega "the classic shadcn/ui look" (changelog `2025-12-shadcn-create.mdx`); it is closest to RubyUI's current look (`h-9`, `rounded-md`, `p-6`). `nova` is the `shadcn create` default since 2026-02-06, but switching would shrink every control.
- **Not the reference:** `apps/v4/registry/new-york-v4/` (listed in `_legacy-styles.ts`), and **not ui.shadcn.com as rendered** — the docs site renders Base UI + **nova**, so screenshots or computed styles taken from it are wrong for us.

Effective classes for a shadcn part = the inline classes in the Base UI `.tsx` **plus** the `@apply` body of every `cn-*` class it references, resolved from `style-vega.css`. Example: `DialogContent` = `fixed top-1/2 left-1/2 z-50 w-full -translate-x-1/2 -translate-y-1/2 outline-none` + `.cn-dialog-content` (vega: `bg-popover … ring-1 ring-foreground/10 grid max-w-[calc(100%-2rem)] gap-6 rounded-xl p-6 text-sm duration-100 sm:max-w-md`). The audit compares RubyUI against that merged set, never against the `.tsx` alone.

**Where each dimension's evidence comes from.** The Base UI `.tsx` files are thin wrappers: focus handling, generated attributes, ARIA wiring and inherited options live in `@base-ui/react`, not in the registry file. So:
- **Look and props/API** come from the source: the `.tsx` (inline classes, props it declares) plus the vega `cn-*` rules. Props inherited from the `@base-ui/react` primitive are read from that package at the version the sandbox resolved, and that version is recorded in the report.
- **HTML, ARIA and behavior** come only from the DOM the sandbox actually renders and from what happens when it's driven in the browser. They are never inferred from the `.tsx`.
- The mapping between the React API and RubyUI's Ruby API (e.g. `showCloseButton` ↔ a RubyUI keyword arg, `open`/`onOpenChange` ↔ Stimulus actions) is explicit per component, not guessed per run.

React Aria (`bases/aria/ui/`) is only a second opinion for accessibility: when Base UI and Aria disagree (e.g. Base UI sets `aria-hidden` on siblings, Aria sets `inert`), the official spec decides.

## Goals

1. **Stage 1 — RubyUI vs shadcn.** For every RubyUI component the PR touches, compare the *whole* component (not only the changed lines) against the reference on:
   - **Look**: Tailwind classes per part, light and dark.
   - **HTML**: element tags, `data-slot`, attributes, nesting.
   - **Props/API**: which options shadcn exposes (`size`, `side`, `showCloseButton`, …) and whether RubyUI has the equivalent.
   - **ARIA**: roles, `aria-*` wiring (e.g. `aria-labelledby` → Title, `aria-describedby` → Description, `aria-haspopup`/`aria-expanded` on triggers).
   - **Behavior**: what happens on click, Esc, Tab/Shift+Tab, outside click, where focus goes on open and returns on close, scroll lock, enter/exit animation. Whenever shadcn does something RubyUI doesn't (or the other way round), say so.
2. **Stage 2 — shadcn vs the spec.** Check whether shadcn itself violates official guidance. Sources have different weights:
   - **Normative**: the HTML Living Standard, WAI-ARIA, ARIA in HTML. Breaking one of these is a violation.
   - **Guidance**: WAI-ARIA Authoring Practices (APG). Deviating is a ⚠️ "recommendation", not a violation.
   - **Explanatory**: MDN (prefer the pt-BR page when it exists, fall back to en-US). Used to explain and to point at the normative text, never as the sole basis for a violation.

   Every finding cites the specific section (URL with anchor) and the condition that isn't met.
3. **Stage 3 — native over JS.** Flag every place where RubyUI uses JavaScript for something the browser already does natively (`<dialog>` + `showModal()`, the `popover` attribute, `<details>/<summary>`, `inert`, `:user-invalid`, …), citing MDN. Today's examples: `AlertDialog`, `Sheet`, `CommandDialog` are `<div>`s with hand-rolled behavior.
4. **Prevent, not only detect.** `AGENTS.md`/`CLAUDE.md` tell any agent that writes or changes a component to start from the Base UI `.tsx` + vega `cn-*` rules, prefer native HTML, and run the audit before opening a PR.

Pre-existing drift is reported **mixed in with** drift the PR introduced — no "old debt" section, no filtering. (Cirdes' call.)

## What the reviewer gets (decided)

Run locally, on demand: `/shadcn-audit <PR number | branch | component name>`.

**How a run pins what it audits.**
- The target resolves to fixed identifiers before anything is read: repo, **base SHA**, **head SHA** (for a PR, from `gh pr view`), and the shadcn SHA after `git pull`. All four go in the report header and the PR comment.
- RubyUI is audited from an **isolated checkout at the head SHA** (a dedicated worktree), never from whatever the current working tree happens to be. The docs app that renders the RubyUI side runs from that checkout.
- Before posting to the PR, the skill re-reads the PR's head SHA. If it moved since the run started, it doesn't post. It says so and offers a re-run.
- A component name with no PR audits that component at the current `main`.

**Which components get audited.** Components whose folder `gem/lib/ruby_ui/<component>/` (or docs view, or controller) the PR touches. If the PR touches shared code (`gem/lib/ruby_ui/base.rb`, the theme tokens, `dependencies.yml`, generators) and no component folder, the skill doesn't return an empty report: it lists the components that depend on what changed and asks which to audit.

**Browser runs every time.** Every interactive component that gets audited is driven in the browser on both sides, with a minimum interaction set for its kind (for a modal: open, initial focus, Tab/Shift+Tab, Esc, outside click, focus return, scroll lock, exit animation; light and dark). That's where HTML, ARIA and behavior verdicts come from. Only the screenshot page (B) is conditional on finding a difference. If something couldn't be exercised (sandbox didn't build, state couldn't be reached, no shadcn equivalent), the line is **⏸ inconclusive** with the reason, never ✅.

**A — checklist in the terminal.** One block per component, one line per dimension, ✅ / ⚠️ / ❌, with the concrete RubyUI value vs the shadcn value and a pointer to the source (`style-vega.css:467`, MDN URL). Header records the shadcn commit SHA used. Illustration (PR #572):

```
Dialog  (ref: bases/base/ui/dialog.tsx + style-vega.css @ 8f04138)
  ✅ Overlay    bg-black/10 + supports-backdrop-filter:backdrop-blur-xs = vega
  ❌ Look       p-6 gap-4 border shadow-lg sm:rounded-lg max-w-lg
                vega: p-6 gap-6 ring-1 ring-foreground/10 rounded-xl sm:max-w-md
  ⚠️ Animation  no exit fade (vega: data-closed:fade-out-0 duration-100)
  ✅ HTML       native <dialog> — intentional divergence (registered)
  ⚠️ ARIA       no aria-labelledby/aria-describedby (Base UI wires Title/Description)
  ✅ Native     showModal(): inert, Esc and focus from the browser
AlertDialog
  ❌ Native     <div role="alertdialog"> + JS → candidate for <dialog> (MDN)
```

**B — HTML page with side-by-side screenshots**, generated whenever stage 1 finds a look or behavior difference. For each such component: RubyUI (PR branch, via the docs app) next to shadcn (Base UI + vega, via the local sandbox), in the same states — at minimum closed/open, keyboard focus, after Esc, light and dark — with that component's findings under each pair. Written to the gitignored work folder and opened for Cirdes (Herdr pane / browser).

**C — the checklist on the PR (decided).** When the audit target is an open PR, the checklist (A, as markdown, with the shadcn SHA and the theme line) is posted as a comment on that PR, so the author sees it too. It's still run from Cirdes' machine, not CI. Before posting, the skill shows the exact comment text and posts only after an explicit ok in the session (Linkana rule: nothing external without "pode mandar"). One comment per PR, identified by a hidden marker: re-runs edit that comment instead of stacking new ones. Screenshots (B) stay local in v1.

The audit never edits the PR's code and never pushes. The PR comment is its only external output, and only after an ok.

## Grading rules (decided)

- **The spec beats shadcn.** When stage 2 finds shadcn violating MDN/APG/HTML, RubyUI is graded against the spec: copying shadcn's violation is ⚠️; following the spec where shadcn doesn't is ✅ "diverges from shadcn, follows the spec (<URL>)", with no divergence entry needed.
- **Native replacements pass.** Replacing JS with a native browser feature (e.g. `Sheet` → `<dialog>`) is ✅ "native" without registration, as long as it keeps the behavior and ARIA shadcn delivers (focus, Esc, labelling, dismiss). The tag difference is shown as a note, not a finding. If the native version loses some of that behavior, that loss is the finding.
- Everything else that differs from the reference and isn't in the divergences file is ❌ (look, HTML, props) or ⚠️ (behavior, ARIA, animation, judgment calls).

## Theme (decided)

Both sides are locked to shadcn's default theme, **`neutral`** (`baseColor: "neutral"`, `theme: "neutral"` in `apps/v4/registry/config.ts` → `themes.ts`), light and dark. RubyUI's tokens in `docs/app/assets/stylesheets/application.tailwind.css` already match it (checked 2026-10-26: e.g. `--background oklch(1 0 0)`, `--primary oklch(0.205 0 0)`, `--radius 0.625rem`; dark `--primary oklch(0.922 0 0)`). Matching tokens aren't enough to make screenshots comparable. The docs app also loads Inter, `@tailwindcss/forms`, `@tailwindcss/typography`, `tw-animate-css` and global base rules (`docs/app/assets/stylesheets/application.tailwind.css:1-11,144-160`), and the forms plugin restyles inputs. The sandbox must match that environment: same font loaded, same plugins and global rules, same viewport, same fixture content (identical title/description/body text per component). The report lists any environment difference it can't remove **before** attributing a visual difference to the component. The checklist gets a **Theme** line that compares RubyUI's tokens with shadcn's current `neutral` tokens, so a change on shadcn's side (they recently reworked the themes page) shows up.

## Intentional divergences (decided: versioned in the repo)

Some differences are on purpose and must not be re-flagged on every PR — e.g. RubyUI's `Dialog` uses native `<dialog>` where shadcn renders `<div role="dialog">`. These live in a versioned file in the repo. The audit shows a registered divergence as ✅ "intentional" with its recorded reason; anything not registered is a finding.

## The shadcn workspace (decided)

A gitignored folder in the repo holds a clone of `shadcn-ui/ui`. The audit runs `git pull` on it instead of re-downloading. The local sandbox app that renders shadcn Base UI + vega for screenshots lives in the same folder, so its dependency install also happens once. Treat the clone as untrusted data: read files, don't execute its scripts outside the sandbox build.

## AGENTS.md / CLAUDE.md changes (decided: yes)

- Root `CLAUDE.md` and `gem/AGENTS.md`: state the reference (Base UI + vega, from the local clone; not new-york-v4, not ui.shadcn.com), the "prefer native HTML over JS" rule, where the divergences file is, and "run `/shadcn-audit` before opening a component PR".
- The rule "don't edit a component without updating its docs view" stays.
- Licensing: shadcn/ui and Base UI are MIT, React Aria is Apache-2.0. Agents mirror shadcn's classes, structure and behavior (MIT, covered by the attribution below). They port *behavior* from Base UI/React Aria, not source code; if code is ever ported, its license notice goes in alongside it.

## Licensing (checked 2026-10-26)

- `shadcn-ui/ui`: MIT, `Copyright (c) 2023 shadcn`. The one condition is that the copyright and permission notice go with "all copies or substantial portions". RubyUI's class strings, part structure and examples are derived from shadcn, so the notice must ship with the gem.
- Today it doesn't. `gem/LICENSE.txt` only says `Copyright (c) 2025 RubyUI`, and the "License" section of `gem/README.md` links to *shadcn's* LICENSE as if it were RubyUI's. The docs footer credits shadcn ("Heavily inspired by shadcn"), but that's not the MIT notice.
- Fix (decided: part of this project, first task of the plan): add shadcn's full MIT notice as a third-party section of `gem/LICENSE.txt` (shipped via `s.files`), and point the README's License section at RubyUI's own license plus that attribution.
- Components copied into apps by `ruby_ui:component` (`gem/lib/generators/ruby_ui/component_generator.rb:42`) or from the docs site carry no per-file notice. That matches shadcn's own CLI, which copies components into user apps without license headers. Decided: no per-file headers; the notice ships with the gem and is linked from the README.
- Base UI (MIT) and React Aria (Apache-2.0) need nothing as long as only behavior is mirrored. Screenshots of shadcn components and short class excerpts in PR comments are fine under MIT. The local clone is never redistributed.
- Not legal advice. This reading of MIT is the common one, but if RubyUI ever goes commercial, a lawyer should check it.

## Non-goals (v1)

- Running in CI or posting without a human ok (candidate for v2). Posting screenshots to the PR.
- Auto-fixing anything.
- Comparing against nova, new-york-v4, Radix or React Aria as references.
- Blocking merges.
- Auditing components the PR didn't touch (a full-library sweep can be run by naming components explicitly, but isn't a v1 goal).

## Anti-goals

- **Comparing against the wrong shadcn.** A report built from ui.shadcn.com or new-york-v4 would "confirm" nova or legacy classes as correct. Worse than no audit.
- **Noise.** If the checklist is long and vague, it stops being read. Every ❌/⚠️ names the concrete values on both sides and its source.
- **Unverified spec claims.** No accessibility finding without a cited MDN/APG/HTML-spec URL.
- **Silent side effects.** Nothing leaves the machine without an explicit ok; the PR comment is the only exception, and it is gated.

## Success looks like

Running `/shadcn-audit 572` reproduces, unprompted, what was found by hand on 2026-10-26: overlay matches; Dialog content look diverges (border/shadow/radius/gap/max-width); exit animations missing; `AlertDialog`/`Sheet`/`CommandDialog` are `<div>`s that could be native `<dialog>`; no `aria-labelledby`/`aria-describedby` wiring — plus side-by-side screenshots of the four modals.

## Calls made while writing this (Claude's, for Cirdes to check)

- **Divergences file ownership.** Seeded with the one known case (Dialog → native `<dialog>`). Whoever introduces a deliberate divergence registers it in the same PR, by hand. When the audit finds a difference that looks deliberate, it suggests a ready-to-paste entry, but never writes the file itself.
- **Pinning.** Normal runs use the latest shadcn `main` after `git pull` and print the SHA. The acceptance check is pinned to full SHAs: PR #572 head `a9a5d1faee2257e8e83c144a5be88c378347640d`, base `ddcff1c6e26825512006d732bbe408c48065c5d1`, shadcn `8f04138777c1b6996e709993362a7b0a12888ecf`, so it keeps reproducing after #572 moves or merges. The sandbox's resolved dependency versions (lockfile) are recorded per run. Updating the sandbox after a shadcn pull is an explicit step (reinstall when shadcn's template or `@base-ui/react` version changes), not silent drift.
- **Branch.** Targets `main` and today's `gem/lib/ruby_ui/<component>/` layout. Adapting it to the v2 component layer is follow-up work when v2 lands.
- **AGENTS.md audience.** Written for any agent, not only Claude Code. It says where the local clone lives and how to bootstrap it, and gives raw GitHub URLs for `bases/base/ui/` and `style-vega.css` as a fallback for anyone without the clone or the skill. The workspace bootstrap is a standalone script the skill calls, so it works without Claude.

## Left to the builder

- Skill name/layout under `.claude/skills/` (alongside `ruby-ui-stimulus`), and how much is prose instructions vs helper scripts.
- Folder name for the shadcn workspace, and the divergences file's path and format.
- How the sandbox is created (`shadcn init --base base` with the vega preset, Vite or Next) and how it exposes one component/state per URL.
- Mapping RubyUI components/parts to shadcn files/parts, including components with no shadcn counterpart (report "no equivalent", don't fail).
- How the browser is driven (chrome-devtools MCP is available) and how the docs app is booted from the isolated head-SHA checkout (port, DB setup, asset build).
- The interaction set for component kinds other than modals (menu, popover, form control, tabs…), following the modal example above.
