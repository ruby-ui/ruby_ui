# RubyUI 2.0 — research prompt

Date: 2026-09-07
Status: ready to run
Scope: **technical research only** — no implementation plan, no code.

Use this file as the opening prompt for a planning/research session in this repo.
Everything under "Verified facts" was checked on 2026-09-07 and does not need to
be rediscovered.

---

## 1. Task

Answer one question with evidence: **can RubyUI 2.0 be built as an ERB-first
component library on Herb / ReActionView today, and if not, what exactly is
missing?**

Produce a research report. Do **not** produce phases, estimates, migration
plans, or component code. The go/no-go decision and the spike that follows are
separate work.

## 2. Verified facts — this repo (do not re-research)

- Monorepo, two independent projects: `gem/` (the `ruby_ui` gem, Phlex
  components + generators + Minitest) and `docs/` (Rails 8 app behind
  rubyui.com, consumes the gem via `path: "../gem"`). Plus `mcp/` (registry
  built by `cd mcp && bundle exec rake mcp:build`).
- Current version: `1.6.0` (`RubyUI::VERSION` in `gem/lib/ruby_ui.rb`).
- 55 components under `gem/lib/ruby_ui/<component>/`, 37 colocated Stimulus
  controllers (`<component>_controller.js`), symlinked into
  `docs/app/javascript/controllers/ruby_ui/`.
- Component base: `RubyUI::Base < Phlex::HTML` (`gem/lib/ruby_ui/base.rb`).
  Its whole job is three things:
  1. `@attrs = mix(default_attrs, user_attrs)` — arbitrary attribute
     pass-through;
  2. `TailwindMerge::Merger` on `@attrs[:class]` — caller classes override
     component defaults;
  3. dev-only `before_template` HTML comment.
- Components are invoked as `RubyUI.Accordion()` via `Phlex::Kit`.
- Composition style is shadcn-shaped: `Accordion` / `AccordionItem` /
  `AccordionTrigger` / `AccordionContent` as separate classes, each rendering
  one element with `**attrs`. This is the library's core value proposition —
  compose freely, restyle any part with Tailwind — and is what Rails partials
  and helpers do badly.
- Distribution is shadcn-shaped too: `gem/lib/generators/ruby_ui/component_generator.rb`
  **copies** component `.rb` files into the host app's
  `app/components/ruby_ui/<component>/`, copies Stimulus controllers into
  `app/javascript/controllers/ruby_ui/`, installs JS packages from
  `gem/lib/generators/ruby_ui/dependencies.yml`, and updates the Stimulus
  manifest. The user owns and edits the copied code.
- Tests: `gem/test/test_helper.rb` defines `ComponentTest` with a `phlex { ... }`
  helper that renders a component in isolation, no Rails, no request.
- `phlex` is a **development** dependency in `gem/ruby_ui.gemspec` (`~> 2.1`);
  `tailwind_merge` is the runtime one.
- Design docs live in `design/YYYY-MM-DD-<slug>-design.md`, implementation plans
  in `design/plans/`. English, with `Date` and `Status` headers.

## 3. Verified facts — upstream (checked 2026-09-07, do not re-research)

[rails/rails#58552](https://github.com/rails/rails/pull/58552) — "Add Herb as an
HTML-aware ERB implementation", by Marco Roth. **Merged into `main` on
2026-08-25**, merge commit `60eb5cb72dbf06ef9de39c6786df2f20e838884f`.

- Adds `ActionView::Template::Handlers::ERB::Herb`, a `::Herb::Engine` subclass
  that mirrors the Erubi handler and is designed to be API-compatible with
  `Erubi::Engine` (same `@output_buffer` conventions, same append protocol,
  escaping still done by `ActionView::OutputBuffer`). Block expressions are
  detected from the Herb syntax tree via Prism instead of Erubi's `BLOCK_EXPR`
  regexp.
- `actionview.gemspec` on `main` now declares `herb >= 0.10` alongside
  `erubi ~> 1.11`.
- **It is opt-in and has no user-facing config yet.** The PR reaches it only via
  `ActionView::Template::Handlers::ERB.erb_implementation=`; the author proposes
  a follow-up PR for a config that routes HTML templates through Herb while
  keeping other formats on Erubi.
- `RAILS_VERSION` at that commit is `8.2.0.alpha` — **this is not in Rails 8.1**.
  `v8.1.0` and the merge commit have diverged histories.
- Herb's Erubi compatibility is pinned upstream by a compat suite and a
  divergence suite in the `marcoroth/herb` repo.

**Baseline for 2.0, pinned:** Rails locked to that exact merge commit —
`gem "rails", github: "rails/rails", ref: "60eb5cb72dbf06ef9de39c6786df2f20e838884f"`.
Do not float on `main`. If research shows this ref is unusable (e.g. ReActionView
requires a later commit), say so explicitly and name the ref it does require —
do not silently change the baseline.

## 4. Decided context (closed — do not relitigate)

- 2.0 is ERB-first on Herb / ReActionView. Phlex goes away.
- 2.0 lives on a long-lived `v2` branch in this monorepo (not a new directory on
  `main`, not a separate repo).
- Rails baseline is the pinned ref above.
- The charter below is settled. Disagreement with it belongs in the report's
  "Risks" section, not in a redesign.

### Charter

**Why 2.0** — ERB-first component library built on Herb / ReActionView,
replacing the Phlex foundation.

**Non-goals**
- No Phlex support in 2.0. No compatibility adapter, no dual-render layer.
- No new components. 2.0 ships the 1.6 surface, nothing more.
- No redesign. Visual output stays shadcn-equivalent.
- No API redesign for its own sake. Deviations from 1.6 need a written reason.

**Success criteria**
- Visual/HTML parity with 1.6 across all components, verified by the golden suite.
- Render performance within `<TBD>`x of 1.6 (Phlex). Measured, not assumed.
- Component + slot layer expressive enough for Dialog, Select and Data Table.

**Go/no-go** — Phase 1 is a decision gate, not a first step. If the ERB
component layer cannot express Dialog, Select and Data Table, 2.0 changes nature
(upstream contribution to Herb / ReActionView) or is postponed. That outcome is a
success of the process.

Two charter placeholders are **yours to resolve** in this report: the
performance target `<TBD>` (propose a measurement method and a defensible
number) and what "the golden suite" concretely is (what tool compares
Phlex-1.6 HTML against ERB-2.0 HTML).

## 5. Research questions

### A. Herb
1. What Herb is and is not today: parser, HTML-aware ERB engine, linter,
   formatter, language server — which of these actually ship and at what
   maturity? Version, license, maintainers, release cadence, public Ruby API
   stability.
2. Given #58552 is opt-in with no config yet: what is the practical way to run
   RubyUI's templates through `Herb::Engine` on the pinned ref today, and did the
   follow-up config PR land? What is the cost of sitting on `8.2.0.alpha` (CI,
   `docs/` app, contributor setup)?
3. **Does Herb change anything for component authoring, or is it compiler and
   tooling only?** #58552 reads as compiler-level with Erubi-compatible output.
   If that is the whole story, say so plainly — then 2.0's authoring foundation
   is ReActionView, and Herb is the layer underneath it.
4. What does the Herb layer actually buy RubyUI in return for the pinning cost —
   compile-time template validation, better errors, performance, tooling? Be
   concrete; this is the justification for an edge-Rails dependency.

### B. ReActionView
5. Programming model: how a component is defined, where its files live, how it
   is invoked from a template, and what plays the role of `RubyUI::Base`.
6. Attributes: how arbitrary attributes reach the rendered element, and whether
   a `mix`-equivalent exists for merging caller attributes over defaults. If
   not, what replaces it — and can `tailwind_merge` still sit in that path?
7. Slots: named slots, multiple slots, blocks that take parameters, conditional
   and reordered slots, nesting depth. Document known limits, not just the happy
   path.
8. Reactivity: what is actually reactive, what transport and machinery it
   requires, and how it coexists with 37 existing Stimulus controllers — does it
   replace them, wrap them, or ignore them?
9. Project state: version, license, pre-1.0?, API churn, dependencies (which
   Rails ref does it require? which Herb version?), any production usage.
10. Testability: can a component be rendered in a unit test without a full
    request cycle — the equivalent of today's `phlex { ... }` helper?
11. **Distribution.** With ERB templates, does the copy-into-`app/` generator
    model still work (view lookup paths, template resolution, per-app editing),
    or does 2.0 have to ship as an engine? This is the highest-risk product
    question: "easy to compose, easy to restyle, you own the code" depends on
    the answer.

### C. Gate readiness (assess from documentation, do not build)
12. For **Dialog**, **Select** and **Data Table**, list the specific capabilities
    each one needs — overlay/portal escape from the DOM position, focus trap,
    open/close state, exit animation before hide, keyboard-driven listbox,
    collection iteration with server-side sort/paginate — and mark which of
    those already have a documented answer in ReActionView, which are unknown,
    and which look blocked.

### D. Risks and alternatives
13. If ReActionView does not hold up: sketch the alternatives in one short table
    (ViewComponent + ERB slots, plain partials + helpers, staying on Phlex).
    Context for the go/no-go only — no recommendation on architecture beyond it.
14. Risks: shipping a library pinned to an unreleased Rails commit (what happens
    to users who cannot run `8.2.0.alpha`), pre-1.0 API churn, license, bus
    factor, and what upstreaming to Herb / ReActionView would involve (the
    charter names it as a valid outcome).

## 6. Method and evidence rules

- Read the local repo first. Paths above are the map.
- Use primary sources: source code, README, CHANGELOG, releases, PRs, issues.
  A blog post or talk is not sufficient evidence for an API claim — confirm it in
  the code.
- Cite every external claim with a URL and the date you read it. This ecosystem
  is pre-1.0 and moves fast; an undated claim is worthless in a month.
- Label every finding **Verified** (with link), **Inferred** (say from what), or
  **Unknown**. "Unknown" is a correct answer and is strictly better than a
  confident guess.
- Minimal empirical verification is allowed and encouraged: build a throwaway
  app in the scratchpad directory against the pinned Rails ref to check a claim.
  Do **not** touch `gem/`, `docs/` or `mcp/`.
- Anything that can only be resolved by asking upstream goes in "Questions for
  upstream", not into a guess.

## 7. Deliverable

`design/2026-09-07-v2-research.md` (English, `Date` + `Status: draft` header):

1. **Executive summary** — 10 lines max. Is 2.0 buildable today, on what
   baseline, and what is the single biggest blocker?
2. **Ecosystem state** — Herb, ReActionView, the pinned Rails ref. Table:
   version, license, stability, what it actually ships.
3. **Capability matrix** — one row per capability RubyUI 1.6 depends on
   (attribute pass-through, Tailwind class merge, kit-style invocation,
   sub-component composition, slots, isolated unit rendering, Stimulus
   colocation, copy-into-app distribution). Columns: how 1.6 does it → the
   2.0 equivalent → status (works / partial / blocked / unknown) → evidence.
4. **Gate readiness** — Dialog, Select, Data Table.
5. **Distribution and generator impact.**
6. **Parity and performance measurement proposal** — resolves the charter's two
   placeholders.
7. **Risks** — including the cost of the pinned edge-Rails baseline.
8. **Questions for upstream.**
9. **Recommendation on the go/no-go** — exactly one of: proceed to spike /
   proceed only with an upstream contribution / postpone. One paragraph, with
   the strongest single reason. No phases, no estimates, no plan.

## 8. Constraints

- Research only. No production code, no changes under `gem/`, `docs/` or `mcp/`,
  no branch, no PR, no commit without explicit approval.
- Report in English (repo convention); conversation in Brazilian Portuguese.
- Report what you found, including inconvenient findings. If the honest answer is
  "ReActionView cannot express Dialog today", that is the valuable result.
