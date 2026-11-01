# shadcn-audit `collect`: deterministic browser collection

Status: design, approved for planning once reviewed.
Date: 2026-11-01.

## Intent

The shadcn-audit skill compares a RubyUI component with its shadcn
(Base UI + vega + neutral) counterpart. Today the agent does every browser
step by hand through the chrome-devtools MCP: opens both fixtures, clicks the
trigger, reads classes and ARIA, takes screenshots, and grades each line.

Nothing is broken. The goal is **determinism**: running the audit twice on the
same commit should produce the same collected facts and the same starting
grades, line by line. Today that depends on the agent collecting the same
things the same way every run (which selector it derives for a RubyUI part,
which properties it compares, which states it screenshots).

## Goals

1. A new CLI subcommand, `collect`, in `audit/` (same one-JSON-object
   contract as every other subcommand, run from `audit/`), that drives a
   browser through **playwright-ruby-client** and collects, for both sides:
   - **Setup**: fixed 1280×800 viewport, light and dark, and the environment
     probe from `interactions.md` (viewport, DPR, fonts, body colors, form
     control defaults, dark class). Differences go into `environment_diffs`.
   - **States** common to every `kind`: closed, open (click on
     `[data-audit-trigger]`), keyboard focus, after Escape. A state that does
     not apply to the kind, or can't be reached, is recorded as unreachable
     with the reason (→ ⏸).
   - **Per state and per mapped part**: computed styles, the accessibility
     tree (Playwright `ariaSnapshot`), plus a screenshot per state and side.
   - **Pixel diff** per state (same viewport, both sides).
2. `collect` grades the **objective** lines itself:
   - computed style equal on both sides → `pass` (even when class tokens
     differ: this settles look-alikes such as `ring-1` vs `border`);
   - computed style differs on a visual property → `fail`, both values named;
   - ARIA difference (role, accessible name, state, or one of the checked
     attributes present on one side only) → `warn`, as `grading.md` rule 4
     says (ARIA is ⚠️, not ❌; see "Builder-check decisions");
   - difference registered in `divergences.yml` → `pass`, basis
     `intentional`;
   - state unreachable / trigger missing / page error → `inconclusive` with
     the reason.
   Every graded line carries a `source` the way `report.json` requires.
3. The skill (`.claude/skills/shadcn-audit/SKILL.md` and
   `references/interactions.md`) is updated so the agent runs `collect`
   first and builds `report.json` on top of its output.
4. The agent keeps: Spec, Native, Animation, the kind-specific behavior
   sequences (focus-trap order, scroll lock, outside click, arrow keys,
   typeahead, Enter/Space toggling), fixture-originated wrappers, and
   exploration of anything `collect` didn't cover. The agent **may override**
   a `collect` grade, but only with a written reason that ends up in the
   report line's `note`.

## Non-goals

- Running `collect` in CI. Local only for now (the user's call). The `audit`
  CI job keeps running unit tests only.
- Kind-specific behavior sequences in v1. They move into `collect` later, one
  kind at a time.
- Pixel diff as a grade. It is **evidence** for the agent (number of
  differing pixels / ratio, plus a diff image), never a status on its own.
  Font and antialiasing noise make it unreliable as an automatic verdict.
- Booting the servers. Sandbox (5179) and preview (3179) keep being started
  as today (Herdr panes or background processes); `collect` receives the URLs.
- Changing `report.json`'s schema in a breaking way, or the renderers.
- Cross-browser runs (Firefox/WebKit). Chromium only, even though Playwright
  would allow more later.

## Anti-goals

- `collect` producing grades that need judgment (spec conformance, "is this
  JS replaceable by native HTML", "is this a fixture wrapper"). A rule-based
  guess there is a false positive generator.
- Output that differs between two runs on the same SHAs for reasons other
  than timestamps, absolute paths, or pixel noise under the tolerance.
- Running anything from `.shadcn-audit/ui` (still untrusted), or booting fork
  code without the existing cross-repository confirmation step.

## Constraints and decisions already made

- **Library: playwright-ruby-client** (user's call). It needs the Node
  `playwright` package and a Chromium installed locally; the README and the
  skill's prerequisites must say how (the audit already requires Node and
  pnpm).
- **Local only** (user's call).
- **Grading split** as in Goals 2 and 4 (user agreed).
- **Pixel diff = evidence only** (proposed, user agreed).
- **v1 scope** = setup + common states + styles/ARIA/screenshots/pixel diff
  for every kind; behavior sequences stay with the agent (user agreed).
- **RubyUI part selectors become fixed data.** RubyUI parts have no
  `data-slot`; today the agent derives a selector from the Ruby source on
  every run, which is a source of non-determinism. `component_map.yml` gains
  a selector per RubyUI part, next to the existing class → `data-slot`
  mapping. `ComponentMap` validation and `map` output include it.
  `collect` refuses (⏸ for that part) when a mapped part has no selector.
- Existing conventions hold: Ruby 3.4 via mise, StandardRB, Minitest, one JSON
  object per subcommand, `{"error": …}` + exit 1 on failure, errors listed
  in `CLI::ERRORS`.

## Divergences become machine-matchable (user's call)

`divergences.yml` entries today are free text (`rubyui`, `shadcn`,
`reason`) keyed by component + dimension, and `grading.md` says an entry
covers only the difference its text describes. Reading that prose is
judgment, so:

- Entries gain **optional structured match keys**: the part, the computed
  property or ARIA attribute/role, and the value on each side (exact shape
  left to the builder). `Divergences` validates them.
- `collect` marks a difference `pass` / basis `intentional` **only** when a
  structured key matches it exactly. It never matches on component +
  dimension alone.
- Entries without match keys stay valid; the agent applies them as overrides,
  as today.
- The four existing entries are migrated to include match keys where the
  difference is expressible that way.

## Builder-check decisions (designer's calls, check these)

- **ARIA grade and basis.** ARIA differences are `warn`, per `grading.md`
  rule 4, so the old flow's verdicts are preserved. The comparison is on the
  computed accessibility tree (`ariaSnapshot`: role, name, states), so a native
  `<dialog>` vs `div[role=dialog]` is not a difference. On top of that, an
  attribute probe checks `aria-expanded`, `aria-controls` (resolves or
  dangling), `aria-haspopup`, `aria-describedby` (resolved text) and a
  computed `modal` fact (`:modal` or `aria-modal="true"`, so a native
  `<dialog>` counts). `aria-labelledby` isn't read raw: the accessible name it
  produces is already in the snapshot. ID-valued attributes are compared by
  what they resolve to, never by the raw ID. Snapshots compare exactly
  (hierarchy, case, numbers); only Look values are normalized.
- **Line granularity follows `grading.md`.** One Look line per differing
  part, with all matching parts grouped into a single `pass` line; same for
  ARIA. State and theme where the difference shows up go into `note`
  (e.g. "open, light+dark"). No per-property or per-state lines, so a re-run
  can be compared line by line with the old report.
- **Theme and environment explain before they fail.** A differing computed
  value that equals a `theme` diff pair (RubyUI value vs shadcn value of the
  same token) is not graded as a component `fail`; it becomes `inconclusive`
  with a note naming the token (theme diffs are already reported on their
  own). Same for typography properties when `environment_diffs` has a font
  difference. Only what's left is graded.
- **Selectors come from the audited head.** `collect` loads
  `component_map.yml` from the `preview` checkout (the audited SHA), falling
  back to the working tree only when the head has no selectors yet, and says
  which one it used. The expected count is the shadcn side's: the RubyUI
  selector must match as many visible elements as `[data-slot=<slot>]` does
  in the same state (one, or N for repeated parts such as accordion items);
  otherwise that part is `inconclusive` ("selector matched 0/3 visible
  elements"). A part never visible on either side is `inconclusive` too. A PR that
  changes a part's markup updates its selector in the same PR.

## Shape of the output (guidance, not a contract)

`collect` writes its artifacts into the run folder and prints one JSON
object, roughly:

- `viewport`, `environment` (per side) and `environment_diffs`;
- `states`: for each state × theme, per side: reached or not (+ reason),
  screenshot path (relative to the run folder), per-part computed styles,
  `ariaSnapshot` text; plus the pixel diff (ratio + diff image path);
- `lines`: the objectively graded lines, already in `report.json` line shape
  (`dimension`, `status`, `basis`, `rubyui`, `shadcn`, `source`, `note`), so
  the agent can append them to the component's `lines`;
- `screenshots`: entries already in `report.json`'s screenshot shape.

The agent then adds its own lines and overrides, and writes `report.json` as
today; `render` and `comment` are unchanged.

## Success criteria

- Two `collect` runs on the same `head_sha`/`shadcn_sha`, with servers
  booted the same way, produce identical JSON after removing timestamps and
  absolute paths, and identical `lines`.
- Re-running the audit of an already-mapped component (e.g. Dialog) with the
  new flow yields every Look/ARIA line the old flow had, with the same
  verdicts or a documented reason for the change.
- Unit tests cover grading rules and map validation without a browser; the
  browser-driving code is exercised by a local smoke test that is skipped
  when Playwright/Chromium is not installed.

## Left to the builder

- Subcommand arguments and flags (how URLs, run folder, folder/component and
  states are passed), and whether light/dark runs in one call.
- Which computed-style properties count as "visual" and how they are
  normalized (color formats, sub-pixel rounding).
- How "keyboard focus" is reached generically (e.g. Tab to the trigger) and
  how a state is declared not applicable per kind.
- Pixel diff implementation and the noise tolerance used to report it.
- The exact YAML shape of the RubyUI selectors in `component_map.yml`, and
  filling them in for the five mapped components.
- How Playwright is installed/located and how its absence is reported.
- How `source` is filled for `collect` lines (e.g. `style-vega.css:<line>`
  from `reference` effective classes, or the fixture URL + state).

## Not in this project

- The accordion audit itself (no map entry or fixture yet). It runs with the
  current flow or after this lands, separately.
