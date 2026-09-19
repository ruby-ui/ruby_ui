# Golden Suite (RubyUI 2.0, Phase 1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Land the golden HTML suite on `main`, validated against today's components, so that RubyUI 1.6's rendered HTML becomes a frozen, executable contract that the 2.0 migration can be measured against.

**Architecture:** The suite renders every component in the 1.6 catalog, reduces each render to a canonical form with an HTML5-spec parser, and compares it byte-for-byte against a committed snapshot. The code already exists and was proved on the `v2-herb` branch; this plan ports it to `main`, re-records the one component that changed since, hardens the normalizer against the false equivalences review found, inventories what it still cannot see, and closes the one bug that prevents the catalog from being complete.

**Tech Stack:** Ruby 3.3 and 3.4, Minitest, Nokogiri 1.18 (development dependency, golden suite only), Phlex 2.4.1, tailwind_merge.

**Spec:** `design/2026-09-19-rubyui-2-0-design.md` — this plan implements its Phase 1 (§6). Read §1, §6 "Phase 1" and §9.1 before starting.

## Global Constraints

- Work in `gem/`. Run every command from `gem/`, never from the repo root.
- Ruby 3.2+ syntax, 2-space indent, `snake_case` files, `CamelCase` classes. StandardRB is enforced and `bundle exec rake` runs it.
- Do not touch `docs/` in any task of this plan. `git status --porcelain docs` must be empty at the end of every task.
- `mcp/data/registry.json` is generated and embeds the source of every component file. Never hand-edit it. Any task that changes a file under `gem/lib/ruby_ui/` rebuilds it with `cd mcp && bundle install && bundle exec exe/ruby-ui-mcp-build` and commits the result — CI rebuilds it and fails on a diff.
- Do not modify any file under `gem/lib/ruby_ui/` except in Task 4, which changes exactly one line of one file.
- `nokogiri` is a **development** dependency. Nothing in this plan may add a runtime dependency; `ruby_ui.gemspec` has none and Phase 1 does not change that.
- Never hand-edit a file under `gem/test/golden/snapshots/`. Snapshots are produced by `bundle exec rake golden:update` and reviewed as a diff.
- Never commit with `bundle exec rake` failing.
- Branch from `main` and open a PR. Do not push to `main`.

---

## File Structure

| File | Responsibility |
| --- | --- |
| `gem/test/golden_test.rb` | The runner. One Minitest test per scenario, plus three coverage tests that stop the ruler from silently shrinking. |
| `gem/test/golden/scenarios.rb` | The catalog — what gets rendered. The file to read first; ~1136 lines of `component`/`scenario` blocks. |
| `gem/test/golden/canonical_html.rb` | Parse, normalize, serialize. The executable definition of "acceptable difference". |
| `gem/test/golden/catalog.rb` | The `component`/`scenario` DSL and the coverage queries (`component_directories`, `component_classes`). |
| `gem/test/golden/harness.rb` | Pins the two sources of randomness; records which classes a render touched. |
| `gem/test/golden/snapshots/**/*.html` | 188 recorded snapshots, one file per pinned scenario. |
| `gem/test/golden/tools/inline_adjacency.rb` | Task 3 only. A standalone report that counts where the canonical form is blind to whitespace. Not loaded by the suite. |
| `gem/Rakefile` | Adds the `golden` and `golden:update` tasks. `golden` is also reached by `rake test`, so CI covers it with no workflow change. |
| `gem/ruby_ui.gemspec` | Adds `nokogiri` as a development dependency. |
| `design/v2/01-research/golden-suite.md` | What the suite covers, what it deliberately does not, and what its normalization treats as acceptable. `CLAUDE.md` links to it. |
| `design/v2/decisions.md` | The living decision log. Created in Task 3 with its first entry. |

---

## Task 1: Port the golden suite onto `main`

The suite exists as a single self-contained commit on `v2-herb` (`f7cbeda`). It touches nothing that `main` has changed since, so it cherry-picks cleanly. After porting it, exactly two snapshots are stale — HoverCard's — because `10c01f0` (#530, "let the card escape a clipping ancestor") landed on `main` after the branch point. Re-recording those two and reviewing the diff is what validates the ruler: if anything else differs, the ruler is wrong and the task stops.

**Files:**
- Create (via cherry-pick): `gem/test/golden_test.rb`, `gem/test/golden/canonical_html.rb`, `gem/test/golden/catalog.rb`, `gem/test/golden/harness.rb`, `gem/test/golden/scenarios.rb`, 188 files under `gem/test/golden/snapshots/`
- Create (separately): `design/v2/01-research/golden-suite.md`
- Modify (via cherry-pick): `gem/Rakefile`, `gem/ruby_ui.gemspec`, `gem/Gemfile.lock`, `CLAUDE.md`, `gem/AGENTS.md`
- Modify (by re-recording): `gem/test/golden/snapshots/hover_card/default.html`, `gem/test/golden/snapshots/hover_card/with_options.html`

**Interfaces:**
- Consumes: nothing. This is the first task.
- Produces, for Tasks 2 and 3 and for all of Phase 2:
  - `Golden::Catalog.scenarios` → `Array<Golden::Catalog::Scenario>`; each responds to `component` (String), `name` (String), `slug` (`"component/name"`), `block` (Proc), `pending` (String or nil), `pinned?` (Boolean), `snapshot_path` (String), `test_name` (Symbol)
  - `Golden::Catalog.component(name) { ... }` and `Golden::Catalog.scenario(name, pending: nil) { ... }` — the catalog DSL
  - `Golden::Catalog.component_directories` → `Array<String>`, every directory under `lib/ruby_ui/` except `docs`
  - `Golden::Catalog.component_classes` → `Array<String>`, the names of every `RubyUI::Base` subclass
  - `Golden::Catalog::SNAPSHOT_ROOT` → absolute path to `gem/test/golden/snapshots`
  - `Golden::CanonicalHtml.call(html)` → `String`, the canonical form; idempotent
  - `Golden::Harness.render(&block)` → `String`, raw HTML, with randomness pinned
  - `Golden::Harness.classes_rendered` → `Hash`, keys are class names touched by renders so far
  - Commands: `bundle exec rake golden` (verify), `bundle exec rake golden:update` (re-record)

- [ ] **Step 1: Branch from an up-to-date `main`**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git checkout main
git pull --ff-only
git checkout -b feat/golden-suite
```

- [ ] **Step 2: Cherry-pick the suite without committing**

`-n` stages the change without creating a commit, so the re-record in Step 8 lands in the same commit as the port.

```bash
git cherry-pick -n f7cbeda
```

Expected: no output, exit 0.

- [ ] **Step 3: Verify the cherry-pick is clean**

```bash
git diff --name-only --diff-filter=U
git status --porcelain | wc -l
```

Expected: the first command prints nothing (zero conflicted files). The second prints `196`.

If there are conflicts, STOP. `main` has changed in a way this plan did not anticipate; report it rather than resolving by hand.

- [ ] **Step 4: Bring the suite's reference document**

The cherry-pick edits `CLAUDE.md` to point at `design/v2/01-research/golden-suite.md`. That file lives on `v2-herb` in a different commit, so without this step the link dangles.

```bash
git checkout 67231db -- design/v2/01-research/golden-suite.md
git status --porcelain design/
```

Expected: `A  design/v2/01-research/golden-suite.md`

- [ ] **Step 5: Install the new development dependency**

```bash
cd gem
bundle install
```

Expected: resolves and installs `nokogiri` 1.18.x. `gem/Gemfile.lock` was already updated by the cherry-pick, so `bundle install` should not modify it further.

- [ ] **Step 6: Run the suite and confirm it fails in exactly the expected way**

This is the failing-test step. The suite is the test; the expected failure is the HoverCard change that landed on `main` after the snapshots were recorded.

```bash
cd gem
bundle exec rake golden
```

Expected: `191 runs, 752 assertions, 2 failures, 0 errors, 2 skips`

The two failures must be, and only be:
- `GoldenSuiteTest#test_hover_card__default`
- `GoldenSuiteTest#test_hover_card__with_options`

The two skips are `context_menu/label_*`, declared `pending:` in `scenarios.rb` because of a 1.6 bug that Task 4 fixes.

**If any other scenario fails, STOP.** The port is not a port any more — something about the ruler or about `main` is not what this plan assumes. Report the failing scenarios and their diffs.

- [ ] **Step 7: Read the two diffs and confirm they are #530**

The failure output prints the diff inline. Confirm both changes are the HoverCard fix and nothing else:

- `hover_card/default` and `hover_card/with_options`: the root `<div>` gains `class="group/hover-card is-absolute"`
- `hover_card/default`: the content `<div>` changes `absolute` to `group-[.is-absolute]/hover-card:absolute group-[.is-fixed]/hover-card:fixed`

Cross-check against the commit that made the change:

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git show 10c01f0 -- gem/lib/ruby_ui/hover_card/
```

Expected: the classes in the diff appear in that commit. If they do not, STOP — a component changed for a reason nobody has accounted for.

- [ ] **Step 8: Re-record**

```bash
cd gem
bundle exec rake golden:update
```

Expected: the task runs the suite with `UPDATE_GOLDEN_SNAPSHOTS=1` and exits 0.

- [ ] **Step 9: Confirm the re-record touched exactly two files**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain gem/test/golden/snapshots | grep -v '^A ' 
```

Expected, exactly these two lines and no others:

```
AM gem/test/golden/snapshots/hover_card/default.html
AM gem/test/golden/snapshots/hover_card/with_options.html
```

`AM` means the file was added by the cherry-pick and then modified by the re-record. If a third file appears, STOP — the re-record overwrote a snapshot that should not have changed.

- [ ] **Step 10: Run the full default task**

```bash
cd gem
bundle exec rake
```

Expected: the unit suite and the golden suite pass, then `407 files inspected, no offenses detected`. Skipped tests are reported (the two `context_menu` pendings) and that is not a failure.

- [ ] **Step 11: Commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add -A
git commit -m "$(cat <<'MSG'
[Feature] Golden HTML suite: the 1.6 parity ruler

Renders every component in the catalog, reduces each render to a
canonical form and compares it against a committed snapshot. 186
snapshots over 54 component directories, plus three coverage tests
that fail if a component, a class or a snapshot falls out of the
catalog.

Ported from the v2-herb branch and re-recorded against main. The only
difference is HoverCard, whose markup changed in #530 after the
snapshots were first taken.

`rake golden` is reached by `rake test`, so CI covers it on Ruby 3.3
and 3.4 with no workflow change.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
MSG
)"
```

---

## Task 2: Harden the ruler

Adversarial review of `canonical_html.rb` found three ways two fragments a browser distinguishes canonicalize to the same string, and one way input is silently truncated. None of them changes a recorded snapshot — the raw Phlex output of all 188 scenarios contains zero elements with whitespace-only content and zero `</template>` or U+000B — but every one of them is a difference the ERB lane in Phase 2 could introduce and the ruler would miss. The one that matters most is behavioural: `FormField`'s controller (`gem/lib/ruby_ui/form/form_field_controller.js:9`) enables validation when `errorTarget.textContent` is truthy, and `FormFieldError` uses `empty:hidden`, so `<div></div>` and `<div>\n</div>` are different components to a browser. The ruler on `v2-herb` calls them identical.

Separately, the coverage guard records a class when it is **instantiated**, not when it renders. A component that is only ever `new`ed for its `attrs` — `PaginationItem` does this with `Button` — would count as covered without a single byte of its markup being measured. Today every recorded class does reach `view_template` (review checked), so moving the hook changes nothing now and closes the loophole for later.

This task is TDD in the plain sense: each defect gets a test that fails on the ported code, then the fix.

**Files:**
- Create: `gem/test/golden/canonical_html_test.rb`
- Create: `gem/test/golden/harness_test.rb`
- Modify: `gem/test/golden/canonical_html.rb` (`parse`, `emit_element`, `significant_children`'s comment, `collapse`, `canonical_attribute`, one new constant, one new predicate)
- Modify: `gem/test/golden/harness.rb` (`RecordsRenderedClass`, and the comment above `classes_rendered`)

**Interfaces:**
- Consumes: `Golden::CanonicalHtml.call(html)`, `Golden::Harness.render(&block)`, `Golden::Harness.classes_rendered` from Task 1.
- Produces: the same names with tightened semantics. `CanonicalHtml.call` raises `ArgumentError` on a fragment that escapes the wrapper; canonicalizes an element with only whitespace children as `<tag> </tag>`; splits token lists and collapses text on `[\t\n\f\r ]` only. `Harness.classes_rendered` contains a class only after that class's `before_template` ran.

- [ ] **Step 1: Write the failing canonicalizer tests**

Create `gem/test/golden/canonical_html_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"
require "golden/canonical_html"

# Adversarial tests for the normalizer: inputs a browser distinguishes that the
# canonical form must not conflate, and input it must refuse rather than
# silently truncate. Each of these compared equal on the ported code.
class GoldenCanonicalHtmlTest < Minitest::Test
  def canonical(html)
    Golden::CanonicalHtml.call(html)
  end

  def test_refuses_a_fragment_that_escapes_the_template_wrapper
    error = assert_raises(ArgumentError) do
      canonical("<div>safe</div></template><button>lost</button>")
    end

    assert_match(/escaped the <template> wrapper/, error.message)
  end

  def test_distinguishes_an_empty_element_from_a_whitespace_only_one
    # `:empty` matches only the first; `textContent` is truthy only on the second.
    refute_equal canonical(%(<div data-x="e"></div>)), canonical(%(<div data-x="e">\n</div>))
  end

  def test_whitespace_only_content_is_a_fixed_point
    once = canonical("<div>\n  \n</div>")

    assert_equal "<div> </div>\n", once
    assert_equal once, canonical(once)
  end

  def test_class_tokens_split_on_html_whitespace_only
    # U+000B is Ruby whitespace but not HTML whitespace: "a\vb" is one token.
    refute_equal canonical(%(<div class="a\vb"></div>)), canonical(%(<div class="a b"></div>))
  end

  def test_text_collapses_html_whitespace_only
    refute_equal canonical("<p>a\vb</p>"), canonical("<p>a b</p>")
  end
end
```

- [ ] **Step 2: Run them and confirm all five fail**

```bash
cd gem
bundle exec rake test N=/GoldenCanonicalHtmlTest/
```

Expected: `5 runs, ... 5 failures` (or 4 failures and 1 error — the first test raises nothing, so `assert_raises` fails; the fixed-point test's first assertion gets `"<div></div>\n"` instead of `"<div> </div>\n"`). No test may pass before the fix.

- [ ] **Step 3: Patch `canonical_html.rb`**

Four edits to `gem/test/golden/canonical_html.rb`.

**(a)** Add a constant next to `TOKEN_LISTS`:

```ruby
    # HTML's ASCII whitespace: tab, LF, FF, CR, space. Ruby's `\s` also matches
    # U+000B, which HTML does not treat as whitespace — `"a\vb"` is one class
    # token to a browser and has to stay one here.
    HTML_WHITESPACE = /[\t\n\f\r ]+/
```

**(b)** Replace `parse`:

```ruby
      def parse(html)
        wrapped = Nokogiri::HTML5.fragment("<template>#{html}</template>")

        # A stray `</template>` in the input closes the wrapper early, and
        # whatever follows lands beside it — outside what gets compared.
        # Refuse rather than silently drop it.
        unless wrapped.children.size == 1
          raise ArgumentError,
            "fragment escaped the <template> wrapper (a stray </template>?): #{html[0, 120].inspect}"
        end

        wrapped.children.first.children
      end
```

**(c)** In `emit_element`, replace the `elsif children.empty?` branch, and add the predicate below `significant_children`. Replace the comment on `significant_children` too — its claim that `<div></div>` and `<div>\n</div>` are identical to a browser is the defect.

```ruby
        elsif children.empty?
          # `<div></div>` and `<div>\n</div>` are not the same element to a
          # browser: `:empty` matches only the first, and `textContent` is
          # truthy only on the second. Keep a single space to tell them apart.
          filler = whitespace_only_content?(node) ? " " : ""
          out << (INDENT * depth) << open << filler << close << "\n"
```

```ruby
      # Comments and formatting whitespace are not children for layout
      # purposes: `<div>\n  <span/>\n</div>` and `<div><span/></div>` build the
      # same tree. Whether an element had *only* such children is a separate
      # question, answered by whitespace_only_content? — see emit_element.
      def significant_children(node, mode)
        return node.children.to_a unless mode == :normal
        node.children.reject { |child| child.comment? || (child.text? && collapse(child.text).empty?) }
      end

      def whitespace_only_content?(node)
        node.children.any? { |child| child.text? && !child.text.empty? && collapse(child.text).empty? }
      end
```

**(d)** Use HTML whitespace in `collapse` and in the token-list branch of `canonical_attribute`:

```ruby
      def collapse(text)
        text.gsub(HTML_WHITESPACE, " ").delete_prefix(" ").delete_suffix(" ")
      end
```

```ruby
        elsif TOKEN_LISTS.include?(name)
          [name, value.split(HTML_WHITESPACE).reject(&:empty?).join(" ")]
```

- [ ] **Step 4: Run the canonicalizer tests and confirm all five pass**

```bash
cd gem
bundle exec rake test N=/GoldenCanonicalHtmlTest/
```

Expected: `5 runs, ... 0 failures, 0 errors`.

- [ ] **Step 5: Write the failing harness test**

Create `gem/test/golden/harness_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"
require "golden/harness"

class GoldenHarnessTest < Minitest::Test
  def test_records_a_class_when_it_renders_not_when_it_is_instantiated
    with_fresh_recording do
      Golden::Harness.render { RubyUI::Button.new(variant: :outline).attrs }

      refute_includes Golden::Harness.classes_rendered.keys, "RubyUI::Button",
        "an instantiated-but-unrendered component must not count as covered"

      Golden::Harness.render { RubyUI.Button { "x" } }

      assert_includes Golden::Harness.classes_rendered.keys, "RubyUI::Button"
    end
  end

  private

  # The recording hash is process-wide and the golden scenarios fill it; swap
  # it out so this test sees only its own renders.
  def with_fresh_recording
    saved = Golden::Harness.classes_rendered
    Golden::Harness.instance_variable_set(:@classes_rendered, {})
    yield
  ensure
    Golden::Harness.instance_variable_set(:@classes_rendered, saved)
  end
end
```

- [ ] **Step 6: Run it and confirm it fails**

```bash
cd gem
bundle exec rake test N=/GoldenHarnessTest/
```

Expected: `1 runs, ... 1 failures` — the `refute_includes`, because `Button.new` records on `initialize`.

- [ ] **Step 7: Patch `harness.rb`**

Replace the `RecordsRenderedClass` module at the bottom of `gem/test/golden/harness.rb`:

```ruby
  # Recording on render rather than on instantiation: a component that is only
  # `new`ed for its computed attributes (PaginationItem does this with Button)
  # has not been measured, and the coverage guard must not count it.
  # `before_template` is the hook Phlex calls on every render and no component
  # overrides, so prepending it on Base reaches every subclass.
  module RecordsRenderedClass
    def before_template
      Golden::Harness.record(self.class)
      super
    end
  end
```

And replace the comment above `classes_rendered`:

```ruby
      # Coverage bookkeeping: which classes have rendered while a scenario was
      # active. See RecordsRenderedClass for why render, not instantiation.
      def classes_rendered
        @classes_rendered ||= {}
      end
```

- [ ] **Step 8: Run the harness test and confirm it passes**

```bash
cd gem
bundle exec rake test N=/GoldenHarnessTest/
```

Expected: `1 runs, ... 0 failures`.

- [ ] **Step 9: Run the golden suite and confirm no snapshot changed**

The hardening tightens what the ruler distinguishes; it must not move what it already measures.

```bash
cd gem
bundle exec rake golden
```

Expected: `191 runs, ... 0 failures, 0 errors, 2 skips`. The coverage test `test_every_component_class_is_rendered_by_a_scenario` still passes — if it fails naming a class, that class is only instantiated and never rendered by any scenario, which is a real gap in the catalog; add a scenario that renders it rather than reverting the hook.

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain gem/test/golden/snapshots
```

Expected: no output. **If any snapshot shows as modified, STOP.** Either the measurement that justified this task is wrong or a patch changed more than it should; report the file and its diff.

- [ ] **Step 10: Run the full default task**

```bash
cd gem
bundle exec rake
```

Expected: green, `409 files inspected, no offenses detected` — 407 plus the two test files this task adds. StandardRB counts one per Ruby file; fix any offense with `bundle exec standardrb --fix`.

- [ ] **Step 11: Commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/test/golden/
git commit -m "$(cat <<'MSG'
[Feature] Golden suite: harden the canonical form and the coverage guard

Four false equivalences the ruler accepted, each now a failing test
before its fix: a stray </template> escaped the parsing wrapper and
silently dropped everything after it; an empty element and a
whitespace-only element canonicalized the same (FormField's controller
and `empty:hidden` behave differently on them); class tokens and text
collapsed on Ruby's \s, which includes U+000B, rather than HTML's
whitespace.

The coverage guard recorded a class on instantiation; it now records on
render, so a component that is only ever `new`ed for its attrs cannot
count as measured.

No snapshot changes: the raw Phlex output of all 188 scenarios has no
whitespace-only element and no U+000B.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
MSG
)"
```

---

## Task 3: Inventory the normalizer's remaining blind spot

Task 2 closed the cases the canonical form *can* close without changing what it measures. What remains, by design, is whitespace between two element siblings and at a text–element boundary in `:normal` mode: `<span>a</span><span>b</span>` and `<span>a</span>\n<span>b</span>` still canonicalize the same, as do `Hello <em>` and `Hello<em>`. In an inline formatting context a browser renders those differently, and ERB emits newlines where Phlex emitted nothing.

This task ships a script that lists candidate spots, and records the decision. **The script is an inventory, not a criterion.** Review of its output showed it over- and under-counts — it classifies by tag name and a few Tailwind classes, ignores `absolute`, `hidden`, `sr-only` and responsive variants, and never looks at text nodes — and the decision below does not depend on its number being right. It depends on Task 2 (the case that flips behaviour is now caught for every component) and on Phase 2's strict lane.

It changes no component and no snapshot.

**Files:**
- Create: `gem/test/golden/tools/inline_adjacency.rb`
- Create: `design/v2/decisions.md`

**Interfaces:**
- Consumes: the snapshots on disk at `gem/test/golden/snapshots`.
- Produces: `design/v2/decisions.md`, the living decision log that every later phase appends to. One entry per decision or deviation, newest last, each with a reason.

- [ ] **Step 1: Write the inventory script**

Create `gem/test/golden/tools/inline_adjacency.rb`:

```ruby
# frozen_string_literal: true

# Lists candidate spots where the golden suite's canonical form is blind to
# whitespace: two adjacent inline-level elements under a parent that lays out
# inline. An inventory to read, not a number to rely on.
#
#   cd gem && bundle exec ruby test/golden/tools/inline_adjacency.rb
#
# Known limits, all deliberate: inline-level is judged from the tag name plus
# `inline`, `inline-block` and `inline-flex` in the class list; a parent is
# skipped if its class list has `flex`, `grid`, `inline-flex` or `inline-grid`.
# That is enough to find candidates and not enough to prove absence — it does
# not see `absolute`, `hidden`, `sr-only`, `block` on an inline tag,
# responsive or state variants, or whitespace at a text–element boundary.
# Task 2 of the Phase 1 plan closes the empty-versus-whitespace-only case for
# every component; Phase 2's strict lane covers text-bearing components raw.

require "nokogiri"

SNAPSHOT_ROOT = File.expand_path("../snapshots", __dir__)

INLINE_TAGS = %w[
  a abbr b bdi bdo br cite code data dfn em i kbd mark q rp rt ruby s samp
  small span strong sub sup time u var wbr img svg
].freeze

INLINE_CLASSES = /(?:\A|\s)(?:inline|inline-block|inline-flex)(?:\s|\z)/
FLOW_CLASSES = /(?:\A|\s)(?:flex|grid|inline-flex|inline-grid)(?:\s|\z)/

def inline?(node)
  return false unless node.element?
  return true if INLINE_TAGS.include?(node.name)

  node["class"].to_s.match?(INLINE_CLASSES)
end

def inline_formatting_context?(node)
  return true if node.fragment?

  !node["class"].to_s.match?(FLOW_CLASSES)
end

findings = Hash.new { |hash, key| hash[key] = [] }

Dir.glob(File.join(SNAPSHOT_ROOT, "**", "*.html")).sort.each do |path|
  slug = path.delete_prefix("#{SNAPSHOT_ROOT}/").delete_suffix(".html")
  component = slug.split("/").first

  Nokogiri::HTML5.fragment(File.read(path)).traverse do |node|
    next unless node.element? || node.fragment?
    next unless inline_formatting_context?(node)

    children = node.children.reject { |child| child.text? && child.text.strip.empty? }

    children.each_cons(2) do |left, right|
      next unless inline?(left) && inline?(right)

      findings[component] << "#{slug}: <#{left.name}> + <#{right.name}>"
    end
  end
end

puts "components with candidates: #{findings.keys.size}"
puts "candidate pairs: #{findings.values.sum(&:size)}"
puts

findings.keys.sort.each do |component|
  puts "#{component} (#{findings[component].size})"
  findings[component].first(3).each { |line| puts "  #{line}" }
  puts "  …" if findings[component].size > 3
end
```

- [ ] **Step 2: Run it and confirm the output**

```bash
cd gem
bundle exec ruby test/golden/tools/inline_adjacency.rb
```

Expected, exactly:

```
components with candidates: 8
candidate pairs: 50
```

with `badge` 27, `dialog` 6, `codeblock` 5, `sheet` 5, `sidebar` 3, `carousel` 2, `command` 1, `context_menu` 1. If the numbers differ, the snapshots on disk are not the ones Task 1 recorded; investigate before continuing.

- [ ] **Step 3: Write the decision log**

Create `design/v2/decisions.md`:

```markdown
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
```

- [ ] **Step 4: Verify nothing else changed**

```bash
cd gem
bundle exec rake
```

Expected: green, `410 files inspected, no offenses detected` — one more than Task 2 for the script. Fix any offense with `bundle exec standardrb --fix`.

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain gem/test/golden/snapshots gem/lib docs mcp
```

Expected: no output.

- [ ] **Step 5: Commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/test/golden/tools/inline_adjacency.rb design/v2/decisions.md
git commit -m "$(cat <<'MSG'
[Documentation] Inventory the golden suite's remaining whitespace blind spot

The canonical form cannot see whitespace between element siblings or at
a text boundary without losing its fixed-point property. Adds a script
that lists candidate spots — an inventory, explicitly not a bound — and
records the decision: the protection is the hardened canonical form,
trim mode in every Phase 2 sidecar, and a strict raw lane for
text-bearing components, not a count.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
MSG
)"
```

---

## Task 4: Fix `ContextMenuLabel` and pin its two scenarios

Two scenarios in the catalog are declared `pending:` and carry no snapshot, so two of the catalog's renders are not pinned. The reason is a one-line bug in `ContextMenuLabel`:

```ruby
class: ["px-2 py-1.5 text-sm font-semibold text-foreground", inset?: "pl-8"]
```

Ruby parses that as `["...", {inset?: "pl-8"}]` — an Array whose second element is a Hash. The Hash is serialized into the `class` attribute, so every `ContextMenuLabel` renders:

```html
<div class="px-2 py-1.5 text-sm font-semibold text-foreground {inset?: &quot;pl-8&quot;}">
```

Three consequences: `pl-8` is never applied, so `inset:` does nothing; a garbage class token ships in the HTML; and the serialization differs between Ruby 3.3 (`{:inset?=>"pl-8"}`) and 3.4 (`{inset?: "pl-8"}`), which is why the scenarios could not be pinned across the CI matrix.

This is the last hole in the contract Phase 2 freezes. It is a 1.6 bug fix in its own right. `grep` confirms it is the only occurrence of the pattern in the gem.

> **Scope note.** This task goes beyond the spec's Phase 1, which asks only for the ruler. It is here because Phase 2 freezes the contract, and a scenario with no snapshot is a render nobody is measuring. It is independently reviewable: Tasks 1, 2, 3 and 5 stand without it. Drop it and Phase 1 still succeeds, with two unpinned renders and a known bug shipping in 1.6.

**Files:**
- Modify: `gem/lib/ruby_ui/context_menu/context_menu_label.rb:20`
- Modify: `gem/test/ruby_ui/context_menu_test.rb`
- Modify: `gem/test/golden/scenarios.rb:447-449`
- Modify (by rebuilding): `mcp/data/registry.json` — it embeds the source of `context_menu_label.rb`, and CI fails on a stale copy
- Create (by re-recording): `gem/test/golden/snapshots/context_menu/label_flush.html`, `gem/test/golden/snapshots/context_menu/label_inset.html`

**Interfaces:**
- Consumes: `bundle exec rake golden:update` and `Golden::Catalog.scenario(name, pending: nil)` from Task 1.
- Produces: a catalog with no `pending:` scenarios — `Golden::Catalog.scenarios.all?(&:pinned?)` is true — and a registry that matches the gem.

- [ ] **Step 1: Read the two pending scenarios**

```bash
cd gem
sed -n '440,460p' test/golden/scenarios.rb
```

Note the exact scenario names and the loop that generates them. The next steps refer to them.

- [ ] **Step 2: Write the failing test**

Add to `gem/test/ruby_ui/context_menu_test.rb`:

```ruby
def test_context_menu_label_does_not_leak_a_hash_into_the_class_attribute
  output = phlex { RubyUI.ContextMenuLabel { "Label" } }

  refute_includes output, "inset?",
    "ContextMenuLabel serialized its conditional-class Hash into the class attribute"
end

def test_context_menu_label_applies_the_inset_class_only_when_inset
  inset = phlex { RubyUI.ContextMenuLabel(inset: true) { "Label" } }
  plain = phlex { RubyUI.ContextMenuLabel(inset: false) { "Label" } }

  assert_includes inset, "pl-8"
  refute_includes plain, "pl-8"
end
```

- [ ] **Step 3: Run the tests to verify they fail**

```bash
cd gem
bundle exec rake test N=/context_menu_label/
```

Expected: both new tests FAIL. The first because the output contains `{inset?: &quot;pl-8&quot;}`; the second because the literal `"pl-8"` inside the serialized Hash is present in both renders, so `refute_includes plain, "pl-8"` fails.

- [ ] **Step 4: Fix the one line**

In `gem/lib/ruby_ui/context_menu/context_menu_label.rb`, replace `default_attrs`:

```ruby
    def default_attrs
      {
        class: ["px-2 py-1.5 text-sm font-semibold text-foreground", (inset? ? "pl-8" : nil)]
      }
    end
```

- [ ] **Step 5: Run the tests to verify they pass**

```bash
cd gem
bundle exec rake test N=/context_menu_label/
```

Expected: both PASS.

- [ ] **Step 6: Remove the `pending:` marker**

In `gem/test/golden/scenarios.rb` around line 449, drop the `pending:` argument and the comment above it that explains why it was there. The scenario declaration becomes:

```ruby
    scenario "label_#{style}" do
```

- [ ] **Step 7: Record the two new snapshots**

```bash
cd gem
bundle exec rake golden:update
```

- [ ] **Step 8: Confirm exactly two snapshots were created and none changed**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain gem/test/golden/snapshots
```

Expected, exactly these two lines:

```
?? gem/test/golden/snapshots/context_menu/label_flush.html
?? gem/test/golden/snapshots/context_menu/label_inset.html
```

(The exact file names come from the scenario names read in Step 1.)

**If any existing snapshot shows as modified, STOP.** The fix changed a component other than `ContextMenuLabel`, which it must not.

- [ ] **Step 9: Read the two new snapshots**

```bash
cd gem
cat test/golden/snapshots/context_menu/label_*.html
```

Expected: no `inset?` anywhere; `pl-8` present in the inset snapshot and absent from the other.

- [ ] **Step 10: Rebuild the MCP registry**

`mcp/data/registry.json` embeds the full source of every component file; CI rebuilds it and fails on any diff.

```bash
cd /Users/cirdes/Workspaces/ruby_ui/mcp
bundle install
bundle exec exe/ruby-ui-mcp-build
cd ..
git status --porcelain mcp
```

Expected: `Wrote /Users/cirdes/Workspaces/ruby_ui/mcp/data/registry.json`, then exactly ` M mcp/data/registry.json`. Confirm the diff is only the `context_menu_label.rb` content:

```bash
git diff --stat mcp/data/registry.json
git diff mcp/data/registry.json | grep '^[-+]' | grep -v '^[-+][-+]' | grep -c 'inset'
```

Expected: one file changed; the second command prints a small positive number (the changed line appears in both `-` and `+` forms). If the diff touches any other component, STOP — the registry on `main` was already stale and that is a separate finding.

- [ ] **Step 11: Run the full default task**

```bash
cd gem
bundle exec rake
```

Expected: green, `410 files inspected, no offenses detected`, and the skip count is now **0** — `rake golden` no longer reports "You have skipped tests".

- [ ] **Step 12: Commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/lib/ruby_ui/context_menu/context_menu_label.rb gem/test/ruby_ui/context_menu_test.rb gem/test/golden/scenarios.rb gem/test/golden/snapshots/context_menu/ mcp/data/registry.json
git commit -m "$(cat <<'MSG'
[Bug Fix] ContextMenuLabel: stop serializing a Hash into the class attribute

`class: [..., inset?: "pl-8"]` is an Array whose second element is a
Hash, so every ContextMenuLabel shipped a literal `{inset?: "pl-8"}`
class token, `inset:` never applied `pl-8`, and the output differed
between Ruby 3.3 and 3.4.

Pins the two golden scenarios that were pending on this bug, so the
catalog now has no unpinned renders. Rebuilds the MCP registry, which
embeds the component's source.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
MSG
)"
```

---

## Task 5: Open the pull request

**Files:** none.

**Interfaces:**
- Consumes: the four commits from Tasks 1–4.
- Produces: a PR against `main`. Phase 2 branches from `main` after it merges, so that the 2.0 line inherits the ruler rather than forking it.

- [ ] **Step 1: Confirm the branch is clean and complete**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain
git log --oneline main..HEAD
```

Expected: no output from the first command; four commits from the second.

- [ ] **Step 2: Run everything one more time from a clean state**

```bash
cd gem
bundle exec rake
cd ../mcp
bundle exec exe/ruby-ui-mcp-build && git diff --exit-code data/registry.json
```

Expected: gem green, `410 files inspected, no offenses detected`, zero skips; the registry rebuild produces no diff.

- [ ] **Step 3: Ask the user before pushing**

Pushing and opening a PR are outward-facing. Do not run Step 4 until the user has said to go ahead.

- [ ] **Step 4: Push and open the PR**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git push -u origin feat/golden-suite
gh pr create --base main --title "[Feature] Golden HTML suite: the 1.6 parity ruler" --body "$(cat <<'MSG'
## What

Adds the golden HTML suite: every component in the catalog is rendered, reduced
to a canonical form by an HTML5-spec parser, and compared byte-for-byte against
a committed snapshot. 188 snapshots over 54 component directories.

Three coverage tests stop the ruler from quietly shrinking: every component
directory must have a scenario, every `RubyUI::Base` subclass must actually
render in one, and no snapshot may exist without a scenario. The normalizer is
asserted to be idempotent over every snapshot, which is what makes the final
byte comparison a structural comparison rather than a string one, and every
scenario is rendered twice to catch unpinned randomness.

`rake golden` is reached by `rake test`, so CI covers it on Ruby 3.3 and 3.4
with no workflow change. `nokogiri` is added as a development dependency; the
gem still ships with no runtime dependencies.

## Why now

This is Phase 1 of `design/2026-09-19-rubyui-2-0-design.md`. The 2.0 migration
replaces Phlex with plain Ruby classes and ERB templates, and it needs an
executable definition of "the HTML did not change" before the first component
moves. A ruler written after the thing it measures is not a ruler.

It also earns its place on `main` on its own: it catches markup regressions in
ordinary bug-fix PRs today.

## Also in this PR

- **The ruler is hardened against four false equivalences** found in review,
  each with a test that failed before the fix: a stray `</template>` silently
  truncated the input; an empty element and a whitespace-only element compared
  equal (they are different to `FormField`'s controller and to `empty:hidden`);
  class tokens and text collapsed on Ruby's `\s`, which includes U+000B, rather
  than HTML's whitespace. The coverage guard now records a class when it
  renders, not when it is instantiated. No recorded snapshot changed.
- **HoverCard snapshots re-recorded.** #530 changed its markup after the
  snapshots were first taken. Those two files are the only difference between
  the recording on `v2-herb` and the recording against `main` — which is what
  validates the ruler.
- **`ContextMenuLabel` bug fix.** `class: [..., inset?: "pl-8"]` is an Array
  whose second element is a Hash, so every label shipped a literal
  `{inset?: "pl-8"}` class token and `inset:` never applied `pl-8`. Fixing it
  pins the last two unpinned scenarios. The MCP registry is rebuilt to match.
- **A whitespace inventory.** The canonical form is, by design, blind to
  whitespace between element siblings. `gem/test/golden/tools/inline_adjacency.rb`
  lists candidate spots; the decision it informs — an inventory, not a bound —
  is in `design/v2/decisions.md`.

## Test steps

```bash
cd gem
bundle exec rake golden    # the suite alone
bundle exec rake           # unit tests + golden + standardrb
```

Both green, zero skips. To see the ruler work, change a class in any component
and re-run `rake golden`. To see the hardening, feed
`Golden::CanonicalHtml.call` a `<div>\n</div>` and a `<div></div>`.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
MSG
)"
```

---

## Definition of done for Phase 1

- `bundle exec rake` is green on `main` on Ruby 3.3 and 3.4, and `mcp/data/registry.json` is current.
- 188 snapshots exist; no scenario is `pending:`; the suite reports zero skips.
- Every one of the 54 component directories has at least one scenario; every `RubyUI::Base` subclass **renders** in one (recorded at `before_template`, not at `initialize`); no orphan snapshot files.
- The canonical form refuses a fragment that escapes its `<template>` wrapper, distinguishes `<div></div>` from `<div>\n</div>`, and treats only `[\t\n\f\r ]` as whitespace — each with a test that failed before the fix.
- The only snapshot difference between the `v2-herb` recording and the `main` recording is HoverCard, explained by #530.
- `design/v2/decisions.md` exists and records the whitespace finding as an inventory with the three-part resolution, not as a bound.
- `git status --porcelain docs` is empty.

Phase 2 branches from `main` after this merges.
