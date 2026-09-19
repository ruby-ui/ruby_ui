# RubyUI 2.0 — decisions

One entry per decision or deviation from `design/2026-09-19-rubyui-2-0-design.md`,
newest last, each with the reason. The eleven decisions taken before execution
started are in §5 and §6 of that document; this file records what happens after.

## 1. The normalizer's whitespace blind spot (§9.1) — 2026-09-19

`Golden::CanonicalHtml` does not see whitespace between two element siblings,
or at a text–element boundary, in `:normal` mode. It cannot without giving up
the fixed-point property that makes the byte comparison a structural one.

`gem/test/golden/tools/inline_adjacency.rb` lists 8 components and 50 candidate
pairs. Reading them: Badge's 27 are the `all_variants` scenario laying 28
badges side by side — an artefact of the scenario, not a composition users
write; Dialog's, Sheet's and Sidebar's 14 are the close button's icon beside
its `sr-only` label, invisible either way; Codeblock's 5 sit inside `pre`,
which the normalizer preserves verbatim; Carousel's 2 are absolutely
positioned; Command's and ContextMenu's anchors are `flex` and so block-level.
The script also cannot see the text–element case at all, which is the one that
carries behaviour — `FormField` flips on `<div></div>` versus
`<div>\n</div>`, and that is now caught by the hardened canonical form (Phase 1
plan, Task 2), not by this inventory.

**Decision.** The number is not the criterion and does not need to be
accurate. Three things are:

1. The canonical form distinguishes an empty element from a whitespace-only
   one, for every component, as of Phase 1 Task 2.
2. Phase 2 sidecars are written in ERB trim mode (`<%-` / `-%>`), so the ERB
   lane emits no whitespace Phlex did not. This is a rule for all 256
   classes, not for eight.
3. Phase 2.0 defines a strict lane — raw output, attribute order normalized,
   nothing else — and every component that carries text runs through it.
   Badge, Typography, InlineCode, InlineLink, ShortcutKey and FormFieldError
   are the first entries on that list; this inventory is one way to find more.

**What would reverse this.** A Phase 2 component showing a visible spacing
difference in a browser that both lanes reported as parity. §9.4 of the design
is the reason that cannot be caught automatically before Phase 3.
