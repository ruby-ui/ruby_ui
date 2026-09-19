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
`<div>\n</div>`, and that is now caught by the hardened canonical form (the
`test_distinguishes_an_empty_element_from_a_whitespace_only_one` test), not by
this inventory.

**Decision.** The number is not the criterion and does not need to be
accurate. Three things are:

1. The canonical form distinguishes an empty element from a whitespace-only
   one, for every component, per the canonical form's
   `test_distinguishes_an_empty_element_from_a_whitespace_only_one` test.
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

## 2. Normalizer observations from the whole-branch review — 2026-09-19

Three more gaps the review of this branch surfaced in `Golden::CanonicalHtml`.

**Decision: none of the three observations below is acted on in Phase 1.**
Each is real, none changes what the ruler measures today, and each is an
input to the strict lane Phase 2.0 defines — that is where they are weighed.
What would reverse this: a Phase 2 component whose parity depends on one of
them before the strict lane exists.

**F4.** Adjacent text nodes separated only by an HTML comment
(`<div>a<!-- -->b</div>`) are not a fixed point (`a\n  b` → `a b`) and
over-strict against a browser (`ab`). Reachable only through a comment
sitting between two text runs; 1.6 emits comments only in Rails development.
Candidate fix: merge consecutive text children in `significant_children`
after dropping comments.

**F5.** §9.1's exclusion should also name whitespace runs inside text under
CSS `white-space: pre*` (no component sets `whitespace-pre*` today), and that
`combobox_controller.js` reads `input.parentElement.textContent` — so
`ComboboxItem` joins the strict-lane candidate list alongside
`FormFieldError`.

**F9.** U+00A0 is written literally by `escape_text`; a snapshot line holding
one is indistinguishable from spaces in a PR diff. No component emits it
today; escaping it to `&nbsp;` would keep review honest.

## 3. Paths chosen ahead of the upstream conversation — 2026-09-19

The maintainer meets Herb's author the following week. Rather than hold Phase 2
on the three questions in spec §9.2, a path is chosen for each now and
validated afterwards — changing course is cheap while nothing has merged to
`main`.

- **Attribute typing.** Decision B stands: the component coerces and validates
  its enum attributes (`enum` helper in `Base`); nothing depends on Herb typing
  attributes. If upstream ships typed attributes, the coercion becomes
  redundant and stays harmless.
- **Block parameters.** `ToggleGroup` and `ToastRegion` keep the ERB form
  (`render X.new do |group|`), documented as the exception to the tag syntax.
  No implicit-context redesign in 2.0. If a `<Card as |c|>` form is on Herb's
  roadmap, 2.0 waits for it; if not, the redesign is a 2.1 item.
- **herb 0.11 and the ReActionView release that accepts it.** Decision D
  stands: Herb is required from 2.0.0 via ReActionView, the gemspec constraint
  is `reactionview >= 0.4.1` with no upper bound, and the tag syntax arrives
  through `bundle update`. Only the date is open.

**Also decided the same day:** `main` stays as is. The seven 1.6 defects in
`design/v2/follow-up-issues.md` (#537–#543) are addressed on the 2.0 line, not
as 1.6 patches; the 2.0 migration therefore ports those components as they are
and fixes them with a reviewed snapshot change. Phase 2 branches from
`feat/golden-suite`, stacked on PR #536, rather than from `main`.

