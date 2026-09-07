# RubyUI 2.0 — Phase 1 decision gate (throwaway)

Experimental Rails app for the gate described in `design/v2/03-plan-fase1.md`.
Nothing here ships. It exists to answer one question with evidence: does a
minimal in-house ERB component layer over `render_in`, compiled by Herb through
ReActionView on the charter's pinned Rails ref, reproduce the 1.6 golden
snapshots and behave with the 1.6 Stimulus controllers unchanged.

**State (2026-09-07): Phase 0 (day 1) and Phase 1 (days 2–3, Dialog) are done.**
Phases 2–6 (Select, ToggleGroup, Data Table, bench, decision document) are not
started. Deviations from the plan: `design/v2/05-decisions.md`.

A third Gemfile, `Gemfile.tags`, is a **spike outside the gate** (decisions 13
and 14): Herb `main` for its experimental component-tag syntax
(`<RubyUI::Dialog>…</RubyUI::Dialog>`). It does not count towards the gate's
criteria.

## Layout

| Path | What |
| --- | --- |
| `Gemfile.base` | Shared: `rails` at `60eb5cb7…` (charter §3), propshaft, importmap, turbo, stimulus, `tailwind_merge 1.5.5`; test: nokogiri, `phlex 2.4.1` (oracle), capybara, selenium. |
| `Gemfile.herb` | **The gate lane.** base + `reactionview 0.4.0` + `herb 0.10.3`; `intercept_erb = true`, `validation_mode = :raise` (`config/initializers/reactionview.rb`). |
| `Gemfile.erubi` | Control lane. base only; Rails' Erubi handler. |
| `Gemfile.tags` | **Spike, not a gate lane.** base + herb `main` (`4269f79f`, built from git) + prism git; Rails' own `ERB::Herb` handler with `ComponentTags::Visitor` (`config/initializers/component_tags.rb`). No ReActionView. |
| `app/components/ruby_ui/base.rb`, `attributes.rb` | The layer. See `LAYER.md`. |
| `app/components/ruby_ui/{dialog,button}/` | The 9 Phase 1 components: `<name>.rb` + `<name>.html.erb` side by side. |
| `app/views/gate/*.html.erb` | One view per golden scenario, written as a user would. |
| `app/views/gate/*_tags.html.erb` | The same six Dialog scenarios in Herb component-tag syntax; rendered only on the tags lane (elsewhere the tags are unknown HTML elements). |
| `app/controllers/gate_controller.rb` | `/gate/<scenario>`; `form_authenticity_token` pinned to the snapshot literal. |
| `app/javascript/controllers/ruby_ui/*.js` | 37 symlinks to `gem/lib/ruby_ui/*/*_controller.js`. Unedited. |
| `config/initializers/ruby_ui.rb` | The wiring: RubyUI inflection, collapse per component dir (both from the 1.6 installer), `prepend_view_path app/components` (new). |
| `test/golden/` | Harness (SecureRandom pin), scenario catalog, parity test against `gem/test/golden/snapshots/`. |
| `test/probes/` | Phase 0 Herb probes, Phase 1 layer probes, their throwaway components and views. |
| `test/attributes_differential_test.rb` | `RubyUI::Attributes` vs `Phlex::HTML#div(**h)` (Phlex 2.4.1). |
| `test/system/dialog_test.rb` | Behaviour with the 1.6 `dialog_controller.js`. |
| `HERB_FINDINGS.md` | Every Herb acceptance, rejection or divergence seen so far, classified. |
| `LAYER.md` | What the layer is, `wc -l`, install step, what it lacks. |

Ruby 3.4.7 (`.ruby-version`, mise). `gem/`, `docs/` and `mcp/` are read, never
written: the ruler is `gem/test/golden/canonical_html.rb` and the snapshots, in
place.

## Running

```bash
cd experiments/v2-gate

# Gate lane (default, config/boot.rb): unit suites = parity + probes + differential
BUNDLE_GEMFILE=Gemfile.herb  bin/rails test
BUNDLE_GEMFILE=Gemfile.herb  bin/rails test test/golden        # parity only
BUNDLE_GEMFILE=Gemfile.herb  bin/rails test test/system        # headless Chrome

# Control lane
BUNDLE_GEMFILE=Gemfile.erubi bin/rails test
BUNDLE_GEMFILE=Gemfile.erubi bin/rails test test/system

# Spike lane (component tags): the 46 tests above + 6 parity twins + 2 system tests
BUNDLE_GEMFILE=Gemfile.tags  bin/rails test
BUNDLE_GEMFILE=Gemfile.tags  bin/rails test test/system

# Browse a scenario with the 1.6 controllers
bin/rails server                                                        # herb lane, http://localhost:3000/gate/dialog_default
BUNDLE_GEMFILE=Gemfile.tags bin/rails server -p 3001 --pid tmp/pids/server-tags.pid   # http://localhost:3001/gate/dialog_default_tags
```

Results as of 2026-09-07 (Ruby 3.4.7, macOS arm64): 46/46 on herb and erubi,
52/52 on tags; system tests green on all three. Screenshots from the system
tests land in `tmp/screenshots/` (gitignored), evidence only.

## Notes

- Herb is the compiler only on `Gemfile.herb`. The herb gem is present in
  `Gemfile.erubi.lock` too because actionview at the pinned ref depends on it;
  nothing loads it there (`test/lane_test.rb` asserts the handler per lane).
- Only `@floating-ui/dom` is pinned in the importmap (plan §4, Phase 0). The
  controllers that import chart.js, embla-carousel, fuse.js, mustache, maska or
  motion fail to load in the browser with a console error; Stimulus registers
  the rest. Pin those packages when their components join the gate.
- Every test template is a file, never `render inline:` — see `HERB_FINDINGS.md`
  row 13.
- Component tags have no types: `size="lg"` reaches the component as the String
  `"lg"`, so `DialogContent` (Symbol keys) needs the Ruby directive form
  `:size=":lg"`, and booleans always do (`:open="true"`). There is no block
  parameter either. `HERB_FINDINGS.md` rows 17–23.
