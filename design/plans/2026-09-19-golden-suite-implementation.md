# Golden Suite (RubyUI 2.0, Phase 1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Land the golden HTML suite on `main`, validated against today's components, so that RubyUI 1.6's rendered HTML becomes a frozen, executable contract that the 2.0 migration can be measured against.

**Architecture:** The suite renders every component in the 1.6 catalog, reduces each render to a canonical form with an HTML5-spec parser, and compares it byte-for-byte against a committed snapshot. The code already exists and was proved on the `v2-herb` branch; this plan ports it to `main`, re-records the one component that changed since, resolves the one known blind spot in the normalizer, and closes the one bug that prevents the catalog from being complete.

**Tech Stack:** Ruby 3.3 and 3.4, Minitest, Nokogiri 1.18 (development dependency, golden suite only), Phlex 2.4.1, tailwind_merge.

**Spec:** `design/2026-09-19-rubyui-2-0-design.md` — this plan implements its Phase 1 (§6). Read §1, §6 "Phase 1" and §9.1 before starting.

## Global Constraints

- Work in `gem/`. Run every command from `gem/`, never from the repo root.
- Ruby 3.2+ syntax, 2-space indent, `snake_case` files, `CamelCase` classes. StandardRB is enforced and `bundle exec rake` runs it.
- Do not touch `docs/` or `mcp/` in any task of this plan. `git status --porcelain docs mcp` must be empty at the end of every task.
- Do not modify any file under `gem/lib/ruby_ui/` except in Task 3, which changes exactly one line of one file.
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
| `gem/test/golden/snapshots/**/*.html` | 186 recorded snapshots, one file per pinned scenario. |
| `gem/test/golden/tools/inline_adjacency.rb` | Task 2 only. A standalone report that counts where the canonical form is blind to whitespace. Not loaded by the suite. |
| `gem/Rakefile` | Adds the `golden` and `golden:update` tasks. `golden` is also reached by `rake test`, so CI covers it with no workflow change. |
| `gem/ruby_ui.gemspec` | Adds `nokogiri` as a development dependency. |
| `design/v2/01-research/golden-suite.md` | What the suite covers, what it deliberately does not, and what its normalization treats as acceptable. `CLAUDE.md` links to it. |
| `design/v2/decisions.md` | The living decision log. Created in Task 2 with its first entry. |

---

## Task 1: Port the golden suite onto `main`

The suite exists as a single self-contained commit on `v2-herb` (`f7cbeda`). It touches nothing that `main` has changed since, so it cherry-picks cleanly. After porting it, exactly two snapshots are stale — HoverCard's — because `10c01f0` (#530, "let the card escape a clipping ancestor") landed on `main` after the branch point. Re-recording those two and reviewing the diff is what validates the ruler: if anything else differs, the ruler is wrong and the task stops.

**Files:**
- Create (via cherry-pick): `gem/test/golden_test.rb`, `gem/test/golden/canonical_html.rb`, `gem/test/golden/catalog.rb`, `gem/test/golden/harness.rb`, `gem/test/golden/scenarios.rb`, 186 files under `gem/test/golden/snapshots/`
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

The two skips are `context_menu/label_*`, declared `pending:` in `scenarios.rb` because of a 1.6 bug that Task 3 fixes.

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

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
MSG
)"
```

---

## Task 2: Measure the normalizer's whitespace blind spot

`Golden::CanonicalHtml` collapses runs of whitespace to a single space and drops text nodes that collapse to empty, preserving whitespace only inside `pre` and `textarea`. So it treats `<span>a</span><span>b</span>` and `<span>a</span>\n<span>b</span>` as identical — and a browser does not, when the parent lays its children out in an inline formatting context.

This matters for Phase 2, not for Phase 1: ERB emits a newline where Phlex emitted nothing, so an inline-adjacent pair could render differently in a browser while the ruler reports parity. `scenarios.rb` already acknowledges the blindness in its header comment; this task counts how much of the catalog it touches and records the decision that follows.

It changes no component and no snapshot.

**Files:**
- Create: `gem/test/golden/tools/inline_adjacency.rb`
- Create: `design/v2/decisions.md`

**Interfaces:**
- Consumes: the snapshots recorded in Task 1, read from disk at `gem/test/golden/snapshots`.
- Produces: `design/v2/decisions.md`, the living decision log that every later phase appends to. One entry per decision or deviation, newest last, each with a reason.

- [ ] **Step 1: Write the report script**

Create `gem/test/golden/tools/inline_adjacency.rb`:

```ruby
# frozen_string_literal: true

# Counts where the golden suite's canonical form is blind to whitespace.
#
#   cd gem && bundle exec ruby test/golden/tools/inline_adjacency.rb
#
# The canonical form collapses whitespace between elements, so two adjacent
# inline-level elements compare equal whether or not a space separated them.
# A browser renders those two cases differently. This report finds every such
# adjacency in the recorded snapshots, so Phase 2 knows which sidecars have to
# be written whitespace-tight.
#
# Two judgements, both approximations, both deliberate:
#
#   * Inline-level is an intrinsically inline tag, or any element whose class
#     list contains `inline`, `inline-block` or `inline-flex` — because
#     Tailwind overrides display and the tag name alone is not enough.
#   * Whitespace between siblings only renders as a space when the parent
#     establishes an inline formatting context. A flex or grid parent ignores
#     it, so those parents are skipped. Without this filter the count is
#     inflated roughly threefold by icons sitting next to labels inside
#     flex buttons.

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

puts "components affected: #{findings.keys.size}"
puts "adjacent inline pairs: #{findings.values.sum(&:size)}"
puts

findings.keys.sort.each do |component|
  puts "#{component} (#{findings[component].size})"
  findings[component].first(3).each { |line| puts "  #{line}" }
  puts "  …" if findings[component].size > 3
end
```

- [ ] **Step 2: Run it and confirm the count**

```bash
cd gem
bundle exec ruby test/golden/tools/inline_adjacency.rb
```

Expected, exactly:

```
components affected: 8
adjacent inline pairs: 50
```

and these eight components, with these counts:

| Component | Pairs |
| --- | --- |
| `badge` | 27 |
| `codeblock` | 5 |
| `dialog` | 6 |
| `sheet` | 5 |
| `sidebar` | 3 |
| `carousel` | 2 |
| `command` | 1 |
| `context_menu` | 1 |

If the numbers differ, the snapshots on disk are not the ones Task 1 recorded, or Nokogiri's HTML5 parser behaves differently on this machine. Investigate before writing the decision — the decision is only worth what the number is worth.

- [ ] **Step 3: Write the decision log**

Create `design/v2/decisions.md`:

```markdown
# RubyUI 2.0 — decisions

One entry per decision or deviation from `design/2026-09-19-rubyui-2-0-design.md`,
newest last, each with the reason. The ten decisions taken before execution
started are in §5 of that document; this file records what happens after.

## 1. The normalizer's whitespace blind spot (§9.1) — measured 2026-09-19

`Golden::CanonicalHtml` is blind to whitespace between adjacent inline-level
elements whose parent establishes an inline formatting context. Measured with
`gem/test/golden/tools/inline_adjacency.rb` over the recorded snapshots:
**8 components, 50 adjacent inline pairs**.

| Component | Pairs | What they are |
| --- | --- | --- |
| `badge` | 27 | the `all_variants` scenario, 28 badges in a row — an artefact of how the scenario is written, not of a composition users write |
| `dialog` | 6 | the close button's `<svg>` next to its `sr-only` label |
| `codeblock` | 5 | highlighted token spans |
| `sheet` | 5 | the close button, as in `dialog` |
| `sidebar` | 3 | icon next to label |
| `carousel` | 2 | the previous and next buttons |
| `command` | 1 | adjacent `<a>` items |
| `context_menu` | 1 | adjacent `<a>` items |

**Decision: leave the normalizer alone; write these eight components' sidecars
whitespace-tight in Phase 2.** Each of the eight gets an explicit line in its
Phase 2 task saying so, and the sidecar must not put a newline between the
inline siblings named above.

**Why not extend the normalizer.** A second comparison mode that records
inter-element whitespace would have to be threaded through the canonical form,
the fixed-point assertion and all 186 snapshots, for eight components — most of
which are benign anyway: the `sr-only` label next to a close icon renders the
same either way, and `codeblock`'s tokens sit inside `pre`, which the
normalizer already preserves. The cost is not proportional to the risk.

**What would reverse this.** A Phase 2 component showing a visible spacing
difference that the suite reported as parity. That is the failure this decision
accepts, and §9.4 is the reason it cannot be caught automatically before
Phase 3.
```

- [ ] **Step 4: Verify nothing else changed**

```bash
cd gem
bundle exec rake
```

Expected: green, `407 files inspected, no offenses detected`. The report script lives under `test/` and is not loaded by the suite, but StandardRB does inspect it — fix any offense with `bundle exec standardrb --fix` and re-run.

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain gem/test/golden/snapshots gem/lib docs mcp
```

Expected: no output. This task changes no snapshot, no component, and nothing outside `gem/test/golden/tools/` and `design/`.

- [ ] **Step 5: Commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/test/golden/tools/inline_adjacency.rb design/v2/decisions.md
git commit -m "$(cat <<'MSG'
[Documentation] Measure the golden suite's whitespace blind spot

The canonical form collapses whitespace between elements, so adjacent
inline-level elements compare equal whether or not a space separated
them — and a browser renders those two cases differently when the
parent lays out inline. ERB emits a newline where Phlex emitted
nothing, so Phase 2 needs to know how much of the catalog this touches.

8 components, 50 pairs. Adds the report that counts it and records the
decision: write those eight whitespace-tight rather than grow a second
comparison mode.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
MSG
)"
```

---

## Task 3: Fix `ContextMenuLabel` and pin its two scenarios

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

> **Scope note.** This task goes beyond the spec's Phase 1, which asks only for the ruler. It is here because Phase 2 freezes the contract, and a scenario with no snapshot is a render nobody is measuring. It is independently reviewable: Tasks 1, 2 and 4 stand without it. Drop it and Phase 1 still succeeds, with two unpinned renders and a known bug shipping in 1.6.

**Files:**
- Modify: `gem/lib/ruby_ui/context_menu/context_menu_label.rb:20`
- Modify: `gem/test/ruby_ui/context_menu_test.rb`
- Modify: `gem/test/golden/scenarios.rb:447-449`
- Create (by re-recording): `gem/test/golden/snapshots/context_menu/label_default.html`, `gem/test/golden/snapshots/context_menu/label_inset.html`

**Interfaces:**
- Consumes: `bundle exec rake golden:update` and `Golden::Catalog.scenario(name, pending: nil)` from Task 1.
- Produces: a catalog with no `pending:` scenarios — `Golden::Catalog.scenarios.all?(&:pinned?)` is true.

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

Expected: both new tests FAIL.
- The first fails because the output contains `{inset?: &quot;pl-8&quot;}`.
- The second fails because `pl-8` is absent from the `inset: true` render and the literal `"pl-8"` inside the Hash makes it present in both, depending on which assertion runs first.

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
?? gem/test/golden/snapshots/context_menu/label_default.html
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

- [ ] **Step 10: Run the full default task**

```bash
cd gem
bundle exec rake
```

Expected: green, and the skip count is now **0** — `rake golden` no longer reports "You have skipped tests".

- [ ] **Step 11: Commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add -A
git commit -m "$(cat <<'MSG'
[Bug Fix] ContextMenuLabel: stop serializing a Hash into the class attribute

`class: [..., inset?: "pl-8"]` is an Array whose second element is a
Hash, so every ContextMenuLabel shipped a literal `{inset?: "pl-8"}`
class token, `inset:` never applied `pl-8`, and the output differed
between Ruby 3.3 and 3.4.

Pins the two golden scenarios that were pending on this bug, so the
catalog now has no unpinned renders.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
MSG
)"
```

---

## Task 4: Open the pull request

**Files:** none.

**Interfaces:**
- Consumes: the three commits from Tasks 1–3.
- Produces: a PR against `main`. Phase 2 branches from `main` after it merges, so that the 2.0 line inherits the ruler rather than forking it.

- [ ] **Step 1: Confirm the branch is clean and complete**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain
git log --oneline main..HEAD
```

Expected: no output from the first command; three commits from the second.

- [ ] **Step 2: Run everything one more time from a clean state**

```bash
cd gem
bundle exec rake
```

Expected: green, `407 files inspected, no offenses detected`, zero skips.

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
a committed snapshot. 186 snapshots over 54 component directories.

Three coverage tests stop the ruler from quietly shrinking: every component
directory must have a scenario, every `RubyUI::Base` subclass must be reached by
one, and no snapshot may exist without a scenario. The normalizer is asserted to
be idempotent over every snapshot, which is what makes the final byte comparison
a structural comparison rather than a string one, and every scenario is rendered
twice to catch unpinned randomness.

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

- **HoverCard snapshots re-recorded.** #530 changed its markup after the
  snapshots were first taken. Those two files are the only difference between
  the recording on `v2-herb` and the recording against `main` — which is what
  validates the ruler.
- **`ContextMenuLabel` bug fix.** `class: [..., inset?: "pl-8"]` is an Array
  whose second element is a Hash, so every label shipped a literal
  `{inset?: "pl-8"}` class token and `inset:` never applied `pl-8`. Fixing it
  pins the last two unpinned scenarios.
- **The whitespace report.** The canonical form is blind to whitespace between
  adjacent inline elements. `gem/test/golden/tools/inline_adjacency.rb` counts
  where that matters; the finding and the decision are in
  `design/v2/decisions.md`.

## Test steps

```bash
cd gem
bundle exec rake golden    # the suite alone
bundle exec rake           # unit tests + golden + standardrb
```

Both green, zero skips. To see the ruler work, change a class in any component
and re-run `rake golden`.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
MSG
)"
```

---

## Definition of done for Phase 1

- `bundle exec rake` is green on `main` on Ruby 3.3 and 3.4.
- 188 snapshots exist; no scenario is `pending:`; the suite reports zero skips.
- Every one of the 54 component directories has at least one scenario; every `RubyUI::Base` subclass is reached; no orphan snapshot files.
- The only snapshot difference between the `v2-herb` recording and the `main` recording is HoverCard, explained by #530.
- `design/v2/decisions.md` exists and records the whitespace finding with a real number.
- `git status --porcelain docs mcp` is empty.

Phase 2 branches from `main` after this merges.
