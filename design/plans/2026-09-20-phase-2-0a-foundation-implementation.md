# Phase 2.0a — Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Put the 2.0 component layer, the test harness it needs, and the golden suite's ERB and strict lanes into the gem — with every component still Phlex — so that the fixtures plan (2.0b) and the migrations (2.1+) change only what they say they change.

**Architecture:** A plain-Ruby `RubyUI::Component` (the 2.0 layer; it takes the name `Base` only when the last Phlex component is gone) renders an ERB sidecar found under the `RubyUI.component_roots` entry that contains its class file — never through the host's view paths. The gem's tests run inside a minimal inline `Rails::Application` so ReActionView's handler compiles every template through Herb exactly as a host app will. The golden suite gains an ERB lane (fixtures under `test/golden/views/`, rendered against the frozen snapshots — still-Phlex components render through `phlex-rails`) and a strict lane (the canonical form in preserve mode, for every scenario). Nothing under `gem/lib/ruby_ui/<component>/` changes.

**Tech Stack:** Ruby 3.3 and 3.4, Minitest, ActionView / Railties 8.1, ReActionView 0.4, Herb 0.10, phlex-rails 2.4 (development only, for the transition), Nokogiri, tailwind_merge.

**Spec:** `design/2026-09-19-rubyui-2-0-design.md` — this plan implements §6 "Phase 2.0 Foundation" with the mechanisms it left open now decided (Task 7 records them). Read §4, §6 "Phase 2", §9.1 and `design/v2/decisions.md` entries 1–4 before starting.

## Global Constraints

- Branch `v2/foundation`, created from `feat/golden-suite` (PR #536, unmerged); the PR for this plan targets `feat/golden-suite`. Never branch from or push to `main`.
- Work in `gem/`. Run every command from `gem/`, never from the repo root. `ENV["RAILS_ENV"]` is `test` for every test run (the helper sets it).
- Ruby 3.2+ syntax, 2-space indent, `snake_case` files, `CamelCase` classes. StandardRB is enforced and `bundle exec rake` runs it.
- **No file under `gem/lib/ruby_ui/<component>/` changes.** No component migrates in this plan. The only new files under `gem/lib/ruby_ui/` are `component.rb` and `attributes.rb`, at the top level.
- **No runtime dependency is added to `ruby_ui.gemspec`.** Every new dependency is `add_development_dependency`. The runtime dependencies arrive in Phase 2.4.
- Never hand-edit a file under `gem/test/golden/snapshots/` or `gem/test/golden/strict/`. The 188 golden snapshots do not change in this plan (`git status --porcelain gem/test/golden/snapshots` is empty at the end of every task). Strict snapshots are created only by `bundle exec rake golden:update`, in Task 6.
- `mcp/data/registry.json` embeds the source of every file under `gem/lib/ruby_ui/<component>/`. This plan adds no such file, so `cd mcp && bundle exec exe/ruby-ui-mcp-build && git diff --exit-code data/registry.json` must pass at the end of every task. Do not touch `docs/`.
- Never commit with `bundle exec rake` failing or skipping.
- Every commit message ends with a `Co-Authored-By:` line naming the model that wrote it.
- Expected lint counts follow StandardRB's rule of one per Ruby file: 410 on the branch today, and each task states its new total.

---

## File Structure

| File | Responsibility |
| --- | --- |
| `gem/ruby_ui.gemspec` | Gains four development dependencies. Runtime dependencies stay empty. |
| `gem/test/test_helper.rb` | Boots the inline `RubyUI::TestApp`, configures ReActionView, sets `RubyUI.component_roots`, loads the probe components, exposes `RubyUI::TestApp.view(*paths)` and `ComponentTest#render_erb`. |
| `gem/test/erb_harness_test.rb` | Proves the harness: ReActionView's handler is registered under `Rails.root`, and a malformed template is refused at compile time. |
| `gem/lib/ruby_ui/attributes.rb` | The attribute layer: `mix`, `merge_classes`, `flat`, with Phlex 2.4.1's guards. Pure Ruby, no view context. |
| `gem/lib/ruby_ui/component.rb` | `RubyUI::Component` (`initialize`, `render_in`, `helpers`, `enum`), `RubyUI.component_roots`, the scoped template lookup. |
| `gem/test/ruby_ui/attributes_test.rb` | Unit tests for the guards. |
| `gem/test/ruby_ui/attributes_differential_test.rb` | `Attributes` against Phlex 2.4.1, canonical form to canonical form. |
| `gem/test/ruby_ui/component_test.rb` | The layer's behaviour, through probe components. |
| `gem/test/ruby_ui/enum_test.rb` | The `enum` helper. |
| `gem/test/probes/ruby_ui/probes/*.rb` + `.html.erb` | Test-only components under a second component root. Never shipped. |
| `gem/test/probes/views/**` | Test-only ERB views: the differential probe, the layer probes, a host template that must **not** shadow a sidecar. |
| `gem/test/golden/catalog.rb` | Scenarios gain a fixture path and a list of lanes; `component_classes` covers both bases. |
| `gem/test/golden/harness.rb` | `render_erb`; the pins and the coverage hook on `RubyUI::Component`. |
| `gem/test/golden_test.rb` | One test per scenario per lane; strict comparison where a strict snapshot exists; two more coverage tests. |
| `gem/test/golden/views/<component>/<name>.html.erb` | The ERB lane's fixtures. This plan writes Button's 15; 2.0b writes the other 173. |
| `gem/test/golden/canonical_html.rb` | `strict:` mode. |
| `gem/test/golden/strict/<component>/<name>.html` | Strict snapshots, one per scenario (188), recorded from the Phlex lane. |
| `design/v2/decisions.md` | Entries 5–9. |
| `design/2026-09-19-rubyui-2-0-design.md` | §4.4 and §6 Phase 2.0 amended to what this plan built. |

---

## Task 1: The harness — an inline Rails application

ReActionView's handler reads `Rails.root` without a guard (`local_template?`, `project_path`), and a template outside `Rails.root` is "external": when Herb rejects it, `external_template_mode: :fallback` **silently recompiles it with Erubi**. So the gem's tests need a `Rails`, and its root must be the gem directory. The smallest honest thing is an inline `Rails::Application` — no `app/` directory, no routes, no database — booted from `test_helper.rb`. Measured on this branch: with it in place the existing suite stays at 504 runs, 0 failures, 0 snapshot changes, and `ActionView::Template.handler_for_extension(:erb)` is `ReActionView::Template::Handlers::ERB`.

One trap, also measured: without `RAILS_ENV=test`, `Rails.env` is `development` and 1.6's `Base#before_template` emits `<!-- Before RubyUI::X -->`, which fails six unit tests. The helper sets the env first.

**Files:**
- Modify: `gem/ruby_ui.gemspec`
- Modify: `gem/Gemfile.lock` (by `bundle install`)
- Modify: `gem/test/test_helper.rb`
- Create: `gem/test/erb_harness_test.rb`
- Create: `gem/test/probes/views/probe/malformed.html.erb`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces:
  - `RubyUI::TestApp` — the inline application; `Rails.root` is the gem directory, `Rails.env` is `test`.
  - `RubyUI::TestApp.view(*paths)` → an `ActionView::Base` instance whose view paths are `paths` (default: `gem/test/probes/views`), sharing one compiled-template cache per process. `view.render(template: "probe/x")` renders `test/probes/views/probe/x.html.erb`; `view.render(object)` goes through `object.render_in`.
  - `ComponentTest#render_erb(template)` → `RubyUI::TestApp.view.render(template:)`, a String.
  - `ReActionView.config` set to `intercept_erb = true`, `validation_mode = :raise`, `debug_mode = false`.

- [ ] **Step 1: Add the development dependencies**

In `gem/ruby_ui.gemspec`, after the `nokogiri` line, add:

```ruby
  # 2.0 harness: the inline Rails application the tests boot, ReActionView's
  # handler (so ERB compiles through Herb as it will in a host app), and
  # phlex-rails so ERB fixtures can render components that are still Phlex
  # during the migration. phlex-rails leaves with the last Phlex component.
  s.add_development_dependency "railties", "~> 8.1"
  s.add_development_dependency "actionview", "~> 8.1"
  s.add_development_dependency "reactionview", "~> 0.4"
  s.add_development_dependency "phlex-rails", "~> 2.4"
```

```bash
cd gem
bundle install
grep -E "^    (railties|actionview|reactionview|phlex-rails|herb) \(" Gemfile.lock
```

Expected: `railties (8.1.3.1)`, `actionview (8.1.3.1)`, `reactionview (0.4.1)`, `phlex-rails (2.4.0)`, `herb (0.10.4)` (plus herb's platform lines). If `reactionview` resolves to anything other than 0.4.x or `herb` to anything other than 0.10.x, STOP — the plan was measured against those.

- [ ] **Step 2: Write the failing harness test**

Create `gem/test/probes/views/probe/malformed.html.erb` with exactly:

```erb
<div><span></div>
```

Create `gem/test/erb_harness_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

# The gem's tests compile ERB the way a host application will: through
# ReActionView's handler, with Herb validating, under Rails.root. Everything
# the ERB lane and the component layer do later stands on these two facts.
class ErbHarnessTest < Minitest::Test
  def test_erb_is_compiled_by_reactionview_under_rails_root
    assert_kind_of Class, ActionView::Base # loading it is what swaps the handler in
    assert_equal ReActionView::Template::Handlers::ERB, ActionView::Template.handler_for_extension(:erb)
    assert_equal File.expand_path("..", __dir__), Rails.root.to_s
    assert_equal "test", Rails.env
  end

  def test_a_malformed_template_is_refused_at_compile_time
    error = assert_raises(ActionView::SyntaxErrorInTemplate) do
      RubyUI::TestApp.view.render(template: "probe/malformed")
    end

    assert_match(/closing tag/i, error.cause.message)
  end
end
```

- [ ] **Step 3: Run it and confirm it fails**

```bash
cd gem
bundle exec rake test N=/ErbHarnessTest/
```

Expected: 2 runs, 2 errors — `RubyUI::TestApp` is undefined (NameError) and `Rails` is not loaded.

- [ ] **Step 4: Rewrite `test_helper.rb`**

Replace `gem/test/test_helper.rb` with exactly:

```ruby
# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ruby_ui"
require "phlex"
require "json"
require "securerandom"
require "rails"
require "action_controller/railtie"
require "reactionview"
require "phlex-rails"
require "minitest/autorun"

module RubyUI
  extend Phlex::Kit

  Dir.glob("lib/ruby_ui/**/*.rb").reject { |f| f.include?("/docs/") || f.end_with?("_docs.rb") }.map do |path|
    class_name = path.split("/").last.delete_suffix(".rb").split("_").map(&:capitalize).join.to_sym

    autoload class_name, path
  end

  # The smallest Rails application that gives ReActionView what it reads:
  # `Rails.root` (a template under it is "local", so a Herb rejection raises
  # instead of falling back to Erubi), `Rails.env` and `Rails.logger`. No app/
  # directory, no routes, no database — an object, so the gem's tests compile
  # ERB exactly as a host application will.
  class TestApp < Rails::Application
    ROOT = File.expand_path("..", __dir__)
    PROBE_VIEWS = File.join(ROOT, "test/probes/views")

    config.root = ROOT
    config.eager_load = false
    config.secret_key_base = "ruby_ui-test"
    config.logger = Logger.new(IO::NULL)
    config.hosts.clear

    class << self
      # One compiled-template cache per process, as in an app; a fresh view
      # context per call, with the given view paths.
      def view(*paths)
        view_class.with_view_paths(paths.empty? ? [PROBE_VIEWS] : paths)
      end

      private

      def view_class
        @view_class ||= ActionView::Base.with_empty_template_cache
      end
    end
  end
end

ReActionView.config.intercept_erb = true
ReActionView.config.validation_mode = :raise
ReActionView.config.debug_mode = false
Rails.application.initialize!

class ComponentTest < Minitest::Test
  def render(component, &)
    component.call(&)
  end

  def phlex(&)
    render Phlex::HTML.new, &
  end

  def render_erb(template)
    RubyUI::TestApp.view.render(template: template)
  end
end
```

- [ ] **Step 5: Run the harness test and confirm it passes**

```bash
cd gem
bundle exec rake test N=/ErbHarnessTest/
```

Expected: `2 runs, ... 0 failures, 0 errors`.

- [ ] **Step 6: Run everything and confirm nothing else moved**

```bash
cd gem
bundle exec rake
```

Expected: `506 runs, ... 0 failures, 0 errors, 0 skips` and `411 files inspected, no offenses detected`. Then:

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain gem/test/golden/snapshots
cd mcp && bundle exec exe/ruby-ui-mcp-build >/dev/null && git diff --exit-code data/registry.json && echo "registry current"
```

Expected: no snapshot lines; `registry current`. If any golden test fails or a snapshot changed, STOP — phlex-rails or the Rails boot has altered what the Phlex lane renders, and that is a finding, not something to re-record.

- [ ] **Step 7: Commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/ruby_ui.gemspec gem/Gemfile.lock gem/test/test_helper.rb gem/test/erb_harness_test.rb gem/test/probes/views/probe/malformed.html.erb
git commit -m "$(cat <<'MSG'
[Feature] Test harness: boot an inline Rails application so ERB compiles through Herb

ReActionView's handler reads Rails.root, and a template outside it is
recompiled with Erubi when Herb rejects it. The gem's tests now boot the
smallest Rails::Application — no app directory, no routes — with the gem
as its root, so every ERB template compiles exactly as it will in a host
app, and a malformed one is refused at compile time.

RAILS_ENV is pinned to test: in development, 1.6's Base emits a
comment before every component and six unit tests fail on it.

phlex-rails is a development dependency for the migration only, so the
ERB fixtures can render components that are still Phlex.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
MSG
)"
```

---

## Task 2: `RubyUI::Attributes`, with Phlex's guards

The attribute layer was written and proved in the gate (`experiments/v2-gate` on `v2-herb`): `mix` with `Phlex::Helpers#mix` semantics, `merge_classes` with tailwind_merge, `flat` with Phlex 2.4.1's serialization — 15 hash shapes and 8 mix shapes checked against Phlex, canonical form to canonical form. It comes over as is, plus the one thing the gate left out and the review made mandatory (spec §4.3): Phlex's attribute guards. Phlex raises on an unsafe attribute name and drops a `javascript:` URL; the gate's layer passed `href="javascript:alert(1)" onclick="alert(1)"` straight to the page.

**Files:**
- Create: `gem/lib/ruby_ui/attributes.rb` (from `v2-herb`, then patched)
- Create: `gem/test/ruby_ui/attributes_test.rb`
- Create: `gem/test/ruby_ui/attributes_differential_test.rb` (from `v2-herb`, then patched)
- Create: `gem/test/probes/views/probe/attributes.html.erb`

**Interfaces:**
- Consumes: `RubyUI::TestApp.view`, `Golden::CanonicalHtml.call` (Phase 1).
- Produces:
  - `RubyUI::Attributes.mix(*hashes)` → Hash (Phlex `mix` semantics; `key!` replaces).
  - `RubyUI::Attributes.merge_classes(value)` → String.
  - `RubyUI::Attributes.flat(hash)` → `Hash[String, String]`, the shape `tag.attributes` takes; raises `ArgumentError` on an unsafe name or an invalid URL-attribute value; omits a URL attribute whose value is a `javascript:` URL.
  - Constants `UNSAFE_ATTRIBUTES`, `REF_ATTRIBUTES`, `UNSAFE_ATTRIBUTE_NAME_CHARS`.

- [ ] **Step 1: Bring the layer over**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git show v2-herb:experiments/v2-gate/app/components/ruby_ui/attributes.rb > gem/lib/ruby_ui/attributes.rb
git show v2-herb:experiments/v2-gate/test/attributes_differential_test.rb > gem/test/ruby_ui/attributes_differential_test.rb
```

- [ ] **Step 2: Write the failing guard tests**

Create `gem/test/ruby_ui/attributes_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

# Phlex 2.4.1's attribute guards, ported into the 2.0 layer so a component
# given untrusted values keeps the protection it has today. Each case mirrors
# phlex/sgml/attributes.rb; the differential test covers the happy path.
class AttributesTest < Minitest::Test
  def flat(**attributes)
    RubyUI::Attributes.flat(attributes)
  end

  def test_an_event_handler_attribute_name_raises
    assert_raises(ArgumentError) { flat(onclick: "x") }
    assert_raises(ArgumentError) { flat("onClick" => "x") }
    assert_raises(ArgumentError) { flat(onerror: "x") }
  end

  def test_srcdoc_sandbox_and_http_equiv_raise
    assert_raises(ArgumentError) { flat(srcdoc: "<p>") }
    assert_raises(ArgumentError) { flat(sandbox: "") }
    assert_raises(ArgumentError) { flat("http-equiv" => "refresh") }
  end

  def test_a_name_with_forbidden_characters_raises_at_any_level
    assert_raises(ArgumentError) { flat("bad name" => "1") }
    assert_raises(ArgumentError) { flat("a=b" => "1") }
    assert_raises(ArgumentError) { flat(data: {"x y" => "1"}) }
  end

  def test_a_javascript_url_is_dropped_from_a_url_attribute
    assert_equal({}, flat(href: "javascript:alert(1)"))
    assert_equal({}, flat(src: "JavaScript:alert(1)"))
    assert_equal({}, flat(href: " java\nscript:alert(1)"))
    assert_equal({}, flat(href: "&#106;avascript:alert(1)"))
    assert_equal({}, flat(href: "&#x6A;avascript:alert(1)"))
    assert_equal({}, flat(href: "javascript&colon;alert(1)"))
    assert_equal({}, flat(formaction: "javascript:alert(1)"))
  end

  def test_an_ordinary_url_is_kept
    assert_equal({"href" => "/edit"}, flat(href: "/edit"))
    assert_equal({"href" => "https://example.com/?q=javascript"}, flat(href: "https://example.com/?q=javascript"))
    assert_equal({"src" => "javascript-guide.png"}, flat(src: "javascript-guide.png"))
  end

  def test_a_non_string_value_is_serialized_then_checked
    # Phlex serializes first and checks the result: 1 and :edit are ordinary
    # values, a Symbol that spells a javascript: URL is not.
    assert_equal({"href" => "1"}, flat(href: 1))
    assert_equal({"href" => "edit"}, flat(href: :edit))
    assert_equal({"href" => "/ edit"}, flat(href: ["/", "edit"]))
    assert_equal({}, flat(href: :"javascript:x"))
  end

  def test_an_out_of_range_character_reference_decodes_to_nothing
    # Phlex rescues the failed pack and treats the reference as empty, which
    # leaves `javascript:` in front.
    assert_equal({}, flat(href: "java&#999999999999999999;script:alert(1)"))
  end

  def test_true_is_allowed_on_a_url_attribute
    assert_equal({"href" => ""}, flat(href: true))
  end

  def test_a_nested_on_key_is_not_an_event_handler
    # Phlex checks `on*` only on top-level names; `data-onclick` is a plain
    # data attribute and stays one here.
    assert_equal({"data-onclick" => "x"}, flat(data: {onclick: "x"}))
  end

  def test_the_guard_does_not_touch_ordinary_attributes
    assert_equal({"class" => "a b", "data-open" => "", "aria-label" => "L"},
      flat(class: ["a", "b"], data: {open: true}, aria: {label: "L"}))
  end
end
```

- [ ] **Step 3: Run them and confirm the guard tests fail**

```bash
cd gem
bundle exec rake test N=/AttributesTest/
```

Expected: 10 runs; `test_an_ordinary_url_is_kept`, `test_true_is_allowed_on_a_url_attribute`, `test_a_nested_on_key_is_not_an_event_handler` and `test_the_guard_does_not_touch_ordinary_attributes` pass (the ported layer already does that); the other 6 FAIL — nothing raises, nothing is dropped, and the javascript-spelling Symbol and the out-of-range reference come through as ordinary strings.

- [ ] **Step 4: Patch `attributes.rb` with the guards**

In `gem/lib/ruby_ui/attributes.rb`:

**(a)** Replace the comment paragraph that begins `# Not reproduced: Phlex's guards` (three lines, ending `depend on either.`) with:

```ruby
  # Phlex's guards (phlex/sgml/attributes.rb) are ported, so a component given
  # untrusted values keeps the protection it has today: a name with `<>&"'/=`,
  # whitespace or NUL raises; `srcdoc`, `sandbox`, `http-equiv` and any `on*`
  # handler name raise; a URL-bearing attribute (`href`, `src`, `action`, …)
  # whose serialized value, character references decoded, starts with
  # `javascript:` is dropped — serialized first, as Phlex does, so `href: 1`
  # renders and `href: :"javascript:x"` does not. Not ported: Phlex's
  # `:id`-must-be-a-lowercase-Symbol check (a Phlex convention) and the leading
  # space it leaves when the first `style:` value is nil (no snapshot depends
  # on it).
```

**(b)** After `TAILWIND_MERGER = TailwindMerge::Merger.new.freeze`, add:

```ruby
    UNSAFE_ATTRIBUTES = Set.new(%w[srcdoc sandbox http-equiv]).freeze
    REF_ATTRIBUTES = Set.new(%w[href src action formaction lowsrc dynsrc background ping xlinkhref]).freeze
    UNSAFE_ATTRIBUTE_NAME_CHARS = %r{[<>&"'/=\s\x00]}

    # The named character references Phlex decodes before the `javascript:`
    # check — exactly these three; every other named reference decodes to
    # nothing, as in Phlex. Numeric references are decoded in full.
    NAMED_REFERENCES = {"colon" => ":", "tab" => "\t", "newline" => "\n"}.freeze
```

**(c)** Replace the whole `flat` method with:

```ruby
      def flat(attributes)
        attributes.each_with_object({}) do |(key, value), out|
          next unless value

          name = key_name(key)
          case value
          when Hash
            (name == "style") ? emit(out, name, styles(value)) : nested(value, "#{name}-", out)
          when Array, Set
            emit(out, name, (name == "style") ? styles(value) : tokens(value))
          else
            emit(out, name, scalar(value))
          end
        end
      end
```

**(d)** In `nested`, replace the line that computes `name` — it begins `name = (key == :_) ?` — so that it is followed by the name-character check:

```ruby
          name = (key == :_) ? prefix.delete_suffix("-") : "#{prefix}#{key_name(key)}"
          raise ArgumentError, "unsafe attribute name #{name.inspect}" if name.match?(UNSAFE_ATTRIBUTE_NAME_CHARS)

```

**(e)** Add four private methods after `key_name`:

```ruby
      # Phlex serializes first and guards the serialized value, so `href: 1`
      # renders `href="1"` and `href: :"javascript:x"` is dropped. A nil here
      # is an empty token list, which omits the attribute.
      def emit(out, name, serialized)
        return if serialized.nil?

        out[name] = serialized unless guard(name, serialized) == :drop
      end

      # :keep or :drop. Raises for the names Phlex refuses.
      def guard(name, serialized)
        raise ArgumentError, "unsafe attribute name #{name.inspect}" if name.match?(UNSAFE_ATTRIBUTE_NAME_CHARS)

        normalized = name.downcase.delete("^a-z-")
        if UNSAFE_ATTRIBUTES.include?(normalized) ||
            (normalized.bytesize > 2 && normalized.start_with?("on") && !normalized.include?("-"))
          raise ArgumentError, "unsafe attribute name #{name.inspect}"
        end

        return :keep unless REF_ATTRIBUTES.include?(normalized)

        decode_references(serialized).downcase.delete("^a-z:").start_with?("javascript:") ? :drop : :keep
      end

      def decode_references(value)
        value
          .gsub(/&#x([0-9a-f]+);?/i) { codepoint($1.to_i(16)) }
          .gsub(/&#(\d+);?/) { codepoint($1.to_i) }
          .gsub(/&([a-z][a-z0-9]+);?/i) { NAMED_REFERENCES[$1.downcase] || "" }
      end

      # Phlex swallows a reference it cannot pack; so does this.
      def codepoint(number)
        [number].pack("U*")
      rescue RangeError
        ""
      end
```

- [ ] **Step 5: Run the guard tests and confirm all nine pass**

```bash
cd gem
bundle exec rake test N=/AttributesTest/
```

Expected: `10 runs, ... 0 failures, 0 errors`.

- [ ] **Step 6: Adapt the differential test to the harness**

Create `gem/test/probes/views/probe/attributes.html.erb` with exactly:

```erb
<div <%= tag.attributes(RubyUI::Attributes.flat(h)) %>></div>
```

In `gem/test/ruby_ui/attributes_differential_test.rb`:

- Replace the `require "test_helper"` / `require "phlex"` lines at the top with:

  ```ruby
  require "test_helper"
  require "golden/canonical_html"
  ```

- Replace `class AttributesDifferentialTest < ActiveSupport::TestCase` with `class AttributesDifferentialTest < Minitest::Test`.
- Every `test "…" do` block becomes `define_method(:"test_…") do`. Concretely: `test "flat: #{label}" do` → `define_method(:"test_flat_#{label.tr(" ", "_")}") do`; `test "mix ##{index + 1}: …" do` → `define_method(:"test_mix_#{index + 1}") do`; the last one, `test "merge_classes accepts …" do` → `def test_merge_classes_applies_tailwind_merge_like_1_6_base`.
- Replace the `canonical_erb` method body so it renders through the harness:

  ```ruby
  def canonical_erb(attributes)
    Golden::CanonicalHtml.call(RubyUI::TestApp.view.render(template: "probe/attributes", locals: {h: attributes}))
  end
  ```

- Add three cases to `FLAT_CASES`, after the `"empty token list omits the attribute"` entry — the URL-value shapes the guards must serialize before checking, compared against Phlex like every other case:

  ```ruby
    "url attribute from a non-string" => {href: 1, src: ["/", "a.png"]},
    "javascript url is dropped, a data attribute is not" => {href: :"javascript:x", "data-href" => "javascript:kept"},
    "out-of-range character reference" => {href: "java&#999999999999999999;script:alert(1)"}
  ```

- [ ] **Step 7: Run the differential test and confirm it passes**

```bash
cd gem
bundle exec rake test N=/AttributesDifferentialTest/
```

Expected: `27 runs, ... 0 failures, 0 errors` — 18 flat cases, 8 mix cases, 1 merge case. If any flat or mix case fails, STOP: the layer disagrees with Phlex 2.4.1 for that shape and the disagreement is the finding.

- [ ] **Step 8: Run everything**

```bash
cd gem
bundle exec rake
```

Expected: `543 runs, ... 0 failures, 0 errors, 0 skips`, `414 files inspected, no offenses detected`. Snapshots unchanged; registry current (`attributes.rb` is a top-level file, not under a component directory, so the builder does not embed it):

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain gem/test/golden/snapshots
cd mcp && bundle exec exe/ruby-ui-mcp-build >/dev/null && git diff --exit-code data/registry.json && echo "registry current"
```

- [ ] **Step 9: Commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/lib/ruby_ui/attributes.rb gem/test/ruby_ui/attributes_test.rb gem/test/ruby_ui/attributes_differential_test.rb gem/test/probes/views/probe/attributes.html.erb
git commit -m "$(cat <<'MSG'
[Feature] RubyUI::Attributes: the 2.0 attribute layer, with Phlex's guards

mix, merge_classes and flat come from the v2 gate, where they were
checked against Phlex 2.4.1 for 15 hash shapes and 8 mix shapes; that
differential test comes with them. Added on top: Phlex's attribute
guards — an unsafe name raises, a javascript: URL in a URL attribute is
dropped — so a component given untrusted values keeps the protection
it has in 1.6.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
MSG
)"
```

---

## Task 3: `RubyUI::Component` and the scoped sidecar lookup

The 2.0 layer is a plain Ruby class that ActionView renders through `render_in`. Its sidecar is looked up under the entry of `RubyUI.component_roots` that contains the class file — `lib` in the gem, `app/components` in a host app — through a `LookupContext` of its own, never through the application's view paths. Measured in a spike on this branch: a host template at the same virtual path is not picked; an ERB block with a parameter is captured; a second render without a block has `content == nil`; an edit to the sidecar is picked up after `ActionView::LookupContext::DetailsKey.clear` (the resolver is registered with `ActionView::PathRegistry`, so Rails' reloader clears it).

The class is named `Component` for the duration of Phase 2. `RubyUI::Base` is the Phlex base that 256 components still inherit; two classes cannot share the name. `Component` becomes `Base` in one commit in Phase 2.4, when no Phlex component is left (decision 6, Task 7).

**Files:**
- Create: `gem/lib/ruby_ui/component.rb`
- Create: `gem/test/probes/ruby_ui/probes/div.rb`, `div.html.erb`, `rootless.rb`, `rootless.html.erb`, `with_id.rb`, `with_id.html.erb`, `frame.rb`, `frame.html.erb`, `fallback.rb`, `fallback.html.erb`, `bare.rb` (no sidecar, on purpose)
- Create: `gem/test/probes/views/probe/div_default.html.erb`, `div_block_arg.html.erb`, `div_nested.html.erb`, `fallback_empty.html.erb`, `fallback_blank.html.erb`, `fallback_text.html.erb`
- Create: `gem/test/probes/views/ruby_ui/probes/div.html.erb` (the host decoy)
- Create: `gem/test/ruby_ui/component_test.rb`
- Modify: `gem/test/test_helper.rb` (component roots, probe loading)

**Interfaces:**
- Consumes: `RubyUI::Attributes` (Task 2), `RubyUI::TestApp.view`, `ComponentTest#render_erb` (Task 1).
- Produces:
  - `RubyUI.component_roots` → `Array<String>`; `RubyUI.component_roots = [...]`.
  - `RubyUI.lookup_for(root)` → memoized `ActionView::LookupContext` scoped to `root`.
  - `RubyUI::Component#initialize(**attrs)`, `#attrs` (`Hash[String, String]`), `#render_in(view_context, **, &block)`, `#content` (`ActiveSupport::SafeBuffer` or `nil`), `#helpers` (the view context; raises outside `render_in`), private `#default_attrs` (`{}`).
  - `RubyUI::Component.template` → `ActionView::Template` for the sidecar; raises `ArgumentError` naming the missing path or the roots.
  - The `component` local inside every sidecar.
  - Probe components `RubyUI::Probes::{Div, Rootless, WithId, Frame, Fallback, Bare}` under the root `gem/test/probes`.

- [ ] **Step 1: Write the layer**

Create `gem/lib/ruby_ui/component.rb`:

```ruby
# frozen_string_literal: true

require "action_view"
require_relative "attributes"

module RubyUI
  class << self
    # The directories that hold `ruby_ui/`: `app/components` in a host
    # application, `lib` in this gem. A component's sidecar template is looked
    # up under the root that contains its class file, and nowhere else — the
    # application's view paths are never consulted, so a host template at the
    # same virtual path cannot shadow it and it cannot shadow the host.
    def component_roots
      @component_roots ||= []
    end

    attr_writer :component_roots

    def lookup_for(root)
      (@lookups ||= {})[root] ||= ActionView::LookupContext.new(
        ActionView::PathRegistry.cast_file_system_resolvers([root]), {formats: [:html]}
      )
    end
  end

  # The 2.0 component layer: a plain Ruby object that ActionView renders
  # through `render_in`, with an ERB sidecar template next to the class file.
  #
  #   # app/components/ruby_ui/dialog/dialog.rb
  #   class RubyUI::Dialog < RubyUI::Component
  #     def initialize(open: false, **attrs)
  #       @open = open
  #       super(**attrs)
  #     end
  #
  #     private def default_attrs
  #       {data: {controller: "ruby-ui--dialog", ruby_ui__dialog_open_value: @open}}
  #     end
  #   end
  #
  #   # app/components/ruby_ui/dialog/dialog.html.erb
  #   <div <%= tag.attributes(component.attrs) %>><%= component.content %></div>
  #
  #   # a view
  #   <%= render RubyUI::Dialog.new(open: true) do %> ... <% end %>
  #
  # `attrs` is computed in `initialize` with no view context — mix, Tailwind
  # merge, then Phlex-semantics serialization (see Attributes) — so a component
  # can read a neighbour's computed attributes (`Button.new(...).attrs["class"]`).
  # `render_in` captures the caller's block with the component as the block
  # argument (for `do |group|` components), then renders the sidecar with
  # `component` as its only local. Nothing else: no named slots, no DSL.
  #
  # Named `Component` while the Phlex `RubyUI::Base` still exists; it takes
  # the name `Base` when the last Phlex component is gone.
  class Component
    attr_reader :attrs, :content

    def initialize(**user_attrs)
      mixed = Attributes.mix(default_attrs, user_attrs)
      mixed[:class] = Attributes.merge_classes(mixed[:class]) if mixed[:class]
      @attrs = Attributes.flat(mixed)
    end

    # ActionView's renderable protocol. Rails passes `locals:`; the caller's
    # locals are not the component's, so they are accepted and ignored.
    # `content` is set on every call — nil without a block — so an instance
    # rendered twice never repeats its first content.
    def render_in(view_context, **, &block)
      @view_context = view_context
      @content = block ? view_context.capture(self, &block) : nil
      self.class.template.render(view_context, {component: self})
    end

    # The view context, for a component that needs a Rails helper from Ruby
    # (`helpers.form_authenticity_token`) or renders a neighbour from a method.
    # Only available during render_in.
    def helpers
      @view_context or raise ArgumentError, "#{self.class.name} has no view context outside render_in"
    end

    class << self
      # Looked up on every render, not cached here: the resolver behind the
      # lookup context caches compiled templates and Rails' reloader clears it,
      # so a Template cached on the class would outlive an edit in development.
      def template
        root = component_root
        relative = source_file.delete_prefix("#{root}/").delete_suffix(".rb")
        prefix, base = File.split(relative)
        RubyUI.lookup_for(root).find(base, [prefix], false, [:component])
      rescue ActionView::MissingTemplate
        raise ArgumentError, "#{name} has no sidecar template at #{relative}.html.erb under #{root}"
      end

      def source_file
        @source_file ||= Object.const_source_location(name)&.first or
          raise ArgumentError, "#{name}: no source location to derive a sidecar template from"
      end

      def component_root
        @component_root ||= RubyUI.component_roots.map(&:to_s).find { |root| source_file.start_with?("#{root}/") } or
          raise ArgumentError, "#{name}: #{source_file} is under none of RubyUI.component_roots #{RubyUI.component_roots.inspect}"
      end
    end

    private

    def default_attrs
      {}
    end
  end
end
```

- [ ] **Step 2: Write the probe components**

Every file below is under `gem/test/probes/ruby_ui/probes/`.

`div.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  module Probes
    # One element with attributes and content: the shape of most components.
    class Div < Component
      private

      def default_attrs
        {class: "probe", data: {probe: true}}
      end
    end
  end
end
```

`div.html.erb`:

```erb
<div <%= tag.attributes(component.attrs) %>><%= component.content %></div>
```

`rootless.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  module Probes
    # Renders no root element at all when hidden — DataTablePagination's shape.
    class Rootless < Component
      def initialize(shown: true, **attrs)
        @shown = shown
        super(**attrs)
      end

      def shown? = @shown
    end
  end
end
```

`rootless.html.erb`:

```erb
<% if component.shown? %><span <%= tag.attributes(component.attrs) %>>shown</span><% end %>
```

`with_id.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  module Probes
    # Mints an id and cross-references it — SelectContent's shape.
    class WithId < Component
      attr_reader :id

      def initialize(**attrs)
        @id = "content#{SecureRandom.hex(4)}"
        super
      end
    end
  end
end
```

`with_id.html.erb`:

```erb
<button aria-controls="<%= component.id %>">open</button><div id="<%= component.id %>"><%= component.content %></div>
```

`frame.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  module Probes
    # A custom-element root — DataTableFrame's shape.
    class Frame < Component
      private

      def default_attrs
        {id: "frame"}
      end
    end
  end
end
```

`frame.html.erb`:

```erb
<turbo-frame <%= tag.attributes(component.attrs) %>><%= component.content %></turbo-frame>
```

`fallback.rb`:

```ruby
# frozen_string_literal: true

module RubyUI
  module Probes
    # Content or a placeholder — SelectValue's shape.
    class Fallback < Component
      attr_reader :placeholder

      def initialize(placeholder:, **attrs)
        @placeholder = placeholder
        super(**attrs)
      end
    end
  end
end
```

`fallback.html.erb`:

```erb
<span><%= component.content.presence || component.placeholder %></span>
```

`bare.rb` — deliberately without a sidecar:

```ruby
# frozen_string_literal: true

module RubyUI
  module Probes
    # Has no sidecar on purpose: the lookup must say so, by name and path.
    class Bare < Component
    end
  end
end
```

- [ ] **Step 3: Write the probe views**

Under `gem/test/probes/views/probe/`:

`div_default.html.erb`:

```erb
<%= render RubyUI::Probes::Div.new do %>Hello<% end %>
```

`div_block_arg.html.erb`:

```erb
<%= render RubyUI::Probes::Div.new(id: "outer") do |div| %>id=<%= div.attrs["id"] %><% end %>
```

`div_nested.html.erb`:

```erb
<%= render RubyUI::Probes::Div.new(id: "outer") do |outer| %><%= render RubyUI::Probes::Div.new(id: "inner") do %>in <%= outer.attrs["id"] %><% end %><% end %>
```

`fallback_empty.html.erb`:

```erb
<%= render RubyUI::Probes::Fallback.new(placeholder: "Pick one") do %><% end %>
```

`fallback_blank.html.erb`:

```erb
<%= render RubyUI::Probes::Fallback.new(placeholder: "Pick one") do %>
<% end %>
```

`fallback_text.html.erb`:

```erb
<%= render RubyUI::Probes::Fallback.new(placeholder: "Pick one") do %>Apple<% end %>
```

And the host decoy, `gem/test/probes/views/ruby_ui/probes/div.html.erb` — a template at exactly the virtual path of `Div`'s sidecar, on the harness's view path, which a view-path lookup would pick and the scoped lookup must not:

```erb
HOST SHADOW
```

- [ ] **Step 4: Wire the roots and the probes into the helper**

In `gem/test/test_helper.rb`, after `Rails.application.initialize!`, add:

```ruby
# component_roots= is a module method, not a constant: the autoload above does
# not reach it, so the file is required outright.
require "ruby_ui/component"

# Two component roots: the gem's own components, and the test-only probes.
# A class's sidecar is looked up under the root that contains the class file.
RubyUI.component_roots = [File.join(RubyUI::TestApp::ROOT, "lib"), File.join(RubyUI::TestApp::ROOT, "test/probes")]
Dir.glob(File.join(RubyUI::TestApp::ROOT, "test/probes/ruby_ui/**/*.rb")).sort.each { |probe| require probe }
```

- [ ] **Step 5: Write the failing layer tests**

Create `gem/test/ruby_ui/component_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"
require "golden/canonical_html"

# The 2.0 component layer, through the probe components under test/probes.
# Output is compared in canonical form where whitespace is irrelevant and raw
# where it is the point. Inherits the helper base for render_erb.
class LayerTest < ComponentTest
  def canonical(html)
    Golden::CanonicalHtml.call(html)
  end

  def view
    RubyUI::TestApp.view
  end

  def test_attrs_are_computed_with_no_view_context
    assert_equal({"class" => "probe", "data-probe" => ""}, RubyUI::Probes::Div.new.attrs)
  end

  def test_caller_classes_merge_over_defaults_and_nil_keeps_the_default
    assert_equal "probe p-4", RubyUI::Probes::Div.new(class: "p-4").attrs["class"]
    assert_equal "probe", RubyUI::Probes::Div.new(class: nil).attrs["class"]
    assert_equal "p-4", RubyUI::Probes::Div.new(class!: "p-4").attrs["class"]
  end

  def test_renders_the_sidecar_with_attributes_and_content
    assert_equal canonical(%(<div class="probe" data-probe="">Hello</div>)), canonical(render_erb("probe/div_default"))
  end

  def test_content_is_nil_when_rendered_without_a_block_even_after_a_render_with_one
    component = RubyUI::Probes::Div.new
    view.render(component) { "first" }

    assert_equal canonical(%(<div class="probe" data-probe=""></div>)), canonical(view.render(component))
  end

  def test_the_block_receives_the_component
    assert_includes render_erb("probe/div_block_arg"), "id=outer"
  end

  def test_a_component_renders_inside_another_components_block
    html = render_erb("probe/div_nested")

    assert_includes html, %(id="inner")
    assert_includes html, "in outer"
  end

  def test_a_component_can_render_nothing
    assert_equal "", view.render(RubyUI::Probes::Rootless.new(shown: false)).strip
    assert_includes view.render(RubyUI::Probes::Rootless.new), "shown"
  end

  def test_a_minted_id_and_its_reference_line_up
    html = view.render(RubyUI::Probes::WithId.new) { "body" }
    id = html[/id="(content[0-9a-f]{8})"/, 1]

    refute_nil id
    assert_includes html, %(aria-controls="#{id}")
  end

  def test_a_custom_element_root
    assert_equal canonical(%(<turbo-frame id="frame">x</turbo-frame>)), canonical(view.render(RubyUI::Probes::Frame.new) { "x" })
  end

  def test_content_presence_falls_back_to_the_placeholder
    assert_equal canonical("<span>Pick one</span>"), canonical(render_erb("probe/fallback_empty"))
    assert_equal canonical("<span>Pick one</span>"), canonical(render_erb("probe/fallback_blank"))
    assert_equal canonical("<span>Apple</span>"), canonical(render_erb("probe/fallback_text"))
  end

  def test_helpers_raises_outside_render_in
    error = assert_raises(ArgumentError) { RubyUI::Probes::Div.new.helpers }

    assert_match(/no view context/, error.message)
  end

  def test_a_missing_sidecar_is_named
    error = assert_raises(ArgumentError) { view.render(RubyUI::Probes::Bare.new) }

    assert_match(%r{ruby_ui/probes/bare\.html\.erb}, error.message)
  end

  def test_a_host_template_at_the_same_virtual_path_is_not_picked
    refute_includes render_erb("probe/div_default"), "HOST SHADOW"
  end

  def test_overlapping_roots_resolve_the_same_sidecar
    # With the gem directory itself as a root ahead of test/probes, Div's file
    # matches the wider root first; the relative path grows, the sidecar found
    # is the same one.
    original = RubyUI.component_roots
    RubyUI.component_roots = [RubyUI::TestApp::ROOT, *original]
    RubyUI::Probes::Div.instance_variable_set(:@component_root, nil)

    assert_equal canonical(%(<div class="probe" data-probe="">Hello</div>)), canonical(render_erb("probe/div_default"))
  ensure
    RubyUI.component_roots = original
    RubyUI::Probes::Div.instance_variable_set(:@component_root, nil)
  end

  class Homeless < RubyUI::Component
  end

  def test_a_class_outside_every_component_root_is_refused
    error = assert_raises(ArgumentError) { Homeless.template }

    assert_match(/component_roots/, error.message)
  end
end
```

- [ ] **Step 6: Run them and confirm they fail**

```bash
cd gem
bundle exec rake test N=/LayerTest/
```

Expected: errors — `RubyUI::Component` does not exist yet if Step 1 was skipped; with Step 1 in place and Step 4 not yet applied, `RubyUI::Probes` is undefined. Every test must be red before Step 4 is applied. (Apply Steps 1–3 first, run, observe the `NameError`s, then apply Step 4.)

- [ ] **Step 7: Run them and confirm they pass**

```bash
cd gem
bundle exec rake test N=/LayerTest/
```

Expected: `15 runs, ... 0 failures, 0 errors`.

- [ ] **Step 8: Run everything**

```bash
cd gem
bundle exec rake
```

Expected: `558 runs, ... 0 failures, 0 errors, 0 skips`, `422 files inspected, no offenses detected` (414 + `component.rb` + `component_test.rb` + six probe `.rb` files). Snapshots unchanged; registry current.

- [ ] **Step 9: Commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/lib/ruby_ui/component.rb gem/test/test_helper.rb gem/test/probes gem/test/ruby_ui/component_test.rb
git commit -m "$(cat <<'MSG'
[Feature] RubyUI::Component: the 2.0 layer with a scoped sidecar lookup

A plain Ruby class ActionView renders through render_in. Its sidecar is
found under the RubyUI.component_roots entry that holds the class file,
through a LookupContext of its own — the application's view paths are
never consulted, so a host template at the same virtual path cannot
shadow the sidecar and the sidecar cannot shadow the host. content is
set on every render, nil without a block.

Named Component while the Phlex RubyUI::Base still exists; it takes the
name Base when the last Phlex component is gone.

Probe components under test/probes exercise the layer without touching
a shipped component.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
MSG
)"
```

---

## Task 4: The `enum` helper

Decision B: components coerce and validate their enumerated attributes. `size: "lg"` arrives as a String from a tag or from `params`, `size: :lg` as a Symbol from Ruby; both must select `SIZES[:lg]`, `nil` takes the default, and anything else names the allowed values instead of dropping the class silently (the 1.6 bug in `DialogContent` and `Badge`).

**Files:**
- Modify: `gem/lib/ruby_ui/component.rb`
- Create: `gem/test/ruby_ui/enum_test.rb`

**Interfaces:**
- Consumes: `RubyUI::Component` (Task 3).
- Produces: `RubyUI::Component#enum(value, table, default:)` → the Symbol key; raises `ArgumentError` listing `table.keys` for an unknown value. Private, for use in a subclass's `initialize`.

- [ ] **Step 1: Write the failing tests**

Create `gem/test/ruby_ui/enum_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class EnumTest < Minitest::Test
  class Sized < RubyUI::Component
    SIZES = {sm: "h-8", md: "h-9", lg: "h-10"}.freeze

    attr_reader :size

    def initialize(size: nil, **attrs)
      @size = enum(size, SIZES, default: :md)
      super(**attrs)
    end
  end

  def test_a_symbol_selects_its_entry
    assert_equal :lg, Sized.new(size: :lg).size
  end

  def test_a_string_is_coerced_to_the_symbol
    assert_equal :lg, Sized.new(size: "lg").size
  end

  def test_nil_takes_the_default
    assert_equal :md, Sized.new.size
    assert_equal :md, Sized.new(size: nil).size
  end

  def test_an_unknown_value_raises_naming_the_allowed_ones
    error = assert_raises(ArgumentError) { Sized.new(size: "xlg") }

    assert_match(/"xlg"/, error.message)
    assert_match(/:sm, :md, :lg/, error.message)
  end

  def test_a_value_that_cannot_be_a_symbol_raises_the_same_way
    error = assert_raises(ArgumentError) { Sized.new(size: 42) }

    assert_match(/42/, error.message)
  end
end
```

- [ ] **Step 2: Run them and confirm they fail**

```bash
cd gem
bundle exec rake test N=/EnumTest/
```

Expected: 5 runs, 5 errors — `NoMethodError: undefined method 'enum'`.

- [ ] **Step 3: Add the helper**

In `gem/lib/ruby_ui/component.rb`, inside `class Component`, in the `private` section after `default_attrs`, add:

```ruby
    # Coerces and validates an enumerated attribute. `size: "lg"` from a tag or
    # from params arrives as a String, `size: :lg` from Ruby as a Symbol, and
    # both must select `table[:lg]`; nil takes the default. Anything else names
    # the allowed values instead of silently dropping the class.
    def enum(value, table, default:)
      key = value.nil? ? default : value
      key = key.to_sym if key.respond_to?(:to_sym)
      return key if table.key?(key)

      raise ArgumentError,
        "#{self.class.name}: #{value.inspect} is not one of #{table.keys.map(&:inspect).join(", ")}"
    end
```

- [ ] **Step 4: Run them and confirm they pass**

```bash
cd gem
bundle exec rake test N=/EnumTest/
```

Expected: `5 runs, ... 0 failures, 0 errors`.

- [ ] **Step 5: Run everything and commit**

```bash
cd gem
bundle exec rake
```

Expected: `563 runs, ... 0 failures, 0 errors, 0 skips`, `423 files inspected, no offenses detected`. Snapshots unchanged; registry current.

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/lib/ruby_ui/component.rb gem/test/ruby_ui/enum_test.rb
git commit -m "$(cat <<'MSG'
[Feature] RubyUI::Component#enum: coerce and validate enumerated attributes

size: "lg" from a tag or params and size: :lg from Ruby both select
SIZES[:lg]; nil takes the default; anything else raises naming the
allowed values, instead of indexing a Symbol-keyed hash with a String
and silently dropping the class, as DialogContent and Badge do in 1.6.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
MSG
)"
```

---

## Task 5: The golden suite's ERB lane, proved on Button

Every scenario keeps its Phlex block. A scenario may also have an ERB fixture at `test/golden/views/<component>/<name>.html.erb`; when it does, the suite renders the fixture through the harness and compares it against the **same frozen snapshot**. The two lanes are independent tests. Because `phlex-rails` is loaded, a fixture can render a component that is still Phlex — so the fixtures for all 188 scenarios can be written and made green before a single component migrates (decision 7). This task builds the lane and writes Button's 15 fixtures as the proof; plan 2.0b writes the other 173.

During the transition the Phlex lane records; the ERB lane only compares. When the last block goes, the ERB lane records. Because Minitest runs a scenario's two lane tests in random order, the recording is done once per scenario **before either lane compares**, not inside the recording lane's own test — otherwise `golden:update` could read a stale or absent file in the lane that happened to run first.

**Files:**
- Modify: `gem/test/golden/catalog.rb`
- Modify: `gem/test/golden/harness.rb`
- Modify: `gem/test/golden_test.rb`
- Create: `gem/test/golden/views/button/*.html.erb` (15 files)

**Interfaces:**
- Consumes: `RubyUI::TestApp.view(*paths)` (Task 1); `RubyUI::Component` (Task 3) for the pins and the coverage hook.
- Produces:
  - `Golden::Catalog::VIEWS_ROOT`; `Scenario#fixture_path`, `#fixture?`, `#lanes` (`[:phlex, :erb]` subset), `#test_name(lane)`.
  - `Golden::Catalog.scenario(name, pending: nil, &block)` — the block is now optional (a scenario may exist only as a fixture, from 2.0b on).
  - `Golden::Catalog.fixture_files` → every `.html.erb` under `VIEWS_ROOT`.
  - `Golden::Harness.render_erb(scenario)` → raw HTML, with the pins active.
  - `Golden::Catalog.component_classes` covers `RubyUI::Base` and `RubyUI::Component` subclasses.

- [ ] **Step 1: Extend the catalog**

In `gem/test/golden/catalog.rb`:

**(a)** After `LIB_ROOT = …`, add:

```ruby
    VIEWS_ROOT = File.expand_path("views", __dir__)
```

**(b)** Inside the `Scenario` struct, after `test_name`, add:

```ruby
      def fixture_path
        File.join(VIEWS_ROOT, component, "#{name}.html.erb")
      end

      def fixture?
        File.exist?(fixture_path)
      end

      # The renderers this scenario runs through: its Phlex block while it has
      # one, its ERB fixture once it has one. Both compare against one snapshot.
      def lanes
        [(:phlex if block), (:erb if fixture?)].compact
      end

      # The lane whose render is written to disk on `golden:update`: the Phlex
      # block while the scenario has one, the ERB fixture after.
      def recording_lane
        block ? :phlex : :erb
      end

      def test_name(lane = nil)
        lane ? :"test_#{component}__#{name}__#{lane}" : :"test_#{component}__#{name}"
      end
```

and delete the original `test_name` method (the one with no parameter).

**(c)** In `scenario`, the block is now optional; replace the method with:

```ruby
      def scenario(name, pending: nil, &block)
        raise "scenario #{name.inspect} declared outside a component block" unless @component

        slug = "#{@component}/#{name}"
        raise "duplicate scenario #{slug}" if scenarios.any? { |existing| existing.slug == slug }

        scenarios << Scenario.new(@component, name.to_s, block, pending)
      end
```

(identical to the current body — the change is that `&block` may be nil, which `Scenario#lanes` handles.)

**(d)** Add a coverage query next to `component_directories`:

```ruby
      def fixture_files
        Dir.glob(File.join(VIEWS_ROOT, "**", "*.html.erb")).sort
      end
```

**(e)** In `component_classes`, replace

```ruby
          .select { |constant| constant.is_a?(Class) && constant < RubyUI::Base }
```

with

```ruby
          .select { |constant| constant.is_a?(Class) && (constant < RubyUI::Base || constant < RubyUI::Component) }
```

- [ ] **Step 2: Extend the harness**

In `gem/test/golden/harness.rb`:

**(a)** After the `render` method, add:

```ruby
      # The ERB lane: renders a scenario's fixture through the same harness a
      # host application's templates go through, with the same pins active.
      def render_erb(scenario)
        @active = true
        @hex_calls = 0
        @rand_calls = 0
        RubyUI::TestApp.view(Golden::Catalog::VIEWS_ROOT).render(template: "#{scenario.component}/#{scenario.name}")
      ensure
        @active = false
      end
```

**(b)** After the `RecordsRenderedClass` module, add:

```ruby
  # The 2.0 layer has no before_template; render_in is the hook that fires on
  # every render and nothing overrides.
  module RecordsRenderedComponent
    def render_in(...)
      Golden::Harness.record(self.class)
      super
    end
  end
```

**(c)** After the two `RubyUI::Base.prepend` lines at the bottom, add:

```ruby
RubyUI::Component.prepend(Golden::DeterministicRandom)
RubyUI::Component.prepend(Golden::RecordsRenderedComponent)
```

- [ ] **Step 3: Extend the runner**

In `gem/test/golden_test.rb`:

**(a)** Replace the scenario loop

```ruby
  Golden::Catalog.scenarios.each do |scenario|
    define_method(scenario.test_name) { assert_golden(scenario) }
  end
```

with

```ruby
  Golden::Catalog.scenarios.each do |scenario|
    scenario.lanes.each do |lane|
      define_method(scenario.test_name(lane)) { assert_golden(scenario, lane) }
    end
  end
```

**(b)** Change `def assert_golden(scenario)` to `def assert_golden(scenario, lane)`, and inside it replace every `canonicalize(scenario)` with `canonicalize(scenario, lane)`. Replace the whole `if UPDATE … end` block (three lines) with

```ruby
    record!(scenario) if UPDATE
```

**(c)** Replace `canonicalize` and add the two helpers:

```ruby
  def canonicalize(scenario, lane)
    Golden::CanonicalHtml.call(render(scenario, lane))
  end

  def render(scenario, lane)
    (lane == :erb) ? Golden::Harness.render_erb(scenario) : Golden::Harness.render(&scenario.block)
  end

  # In update mode the authoritative lane writes the snapshot before either
  # lane compares, once per scenario per process, so the order Minitest picks
  # for a scenario's lane tests cannot make one of them read a stale or absent
  # file.
  def record!(scenario)
    self.class.recorded[scenario.slug] ||= begin
      FileUtils.mkdir_p(File.dirname(scenario.snapshot_path))
      File.write(scenario.snapshot_path, Golden::CanonicalHtml.call(render(scenario, scenario.recording_lane)))
      true
    end
  end

  def self.recorded
    @recorded ||= {}
  end
```

**(d)** In `GoldenCoverageTest.rendered_classes`, replace

```ruby
      Golden::Catalog.scenarios.each { |scenario| Golden::Harness.render(&scenario.block) }
```

with

```ruby
      Golden::Catalog.scenarios.each do |scenario|
        Golden::Harness.render(&scenario.block) if scenario.block
        Golden::Harness.render_erb(scenario) if scenario.fixture?
      end
```

**(e)** Add two coverage tests to `GoldenCoverageTest`. A scenario with neither a block nor a fixture would define no test at all and pass by absence; the first test makes that a failure:

```ruby
  def test_every_scenario_has_at_least_one_lane
    laneless = Golden::Catalog.scenarios.reject { |scenario| scenario.lanes.any? }.map(&:slug)

    assert_empty laneless,
      "scenarios with neither a Phlex block nor an ERB fixture (they would define no test): #{laneless.join(", ")}"
  end

  def test_no_orphan_fixture_files
    expected = Golden::Catalog.scenarios.map(&:fixture_path).sort
    orphans = Golden::Catalog.fixture_files - expected

    assert_empty orphans,
      "fixture files with no scenario (delete them): #{orphans.map { |path| path.delete_prefix("#{Golden::Catalog::VIEWS_ROOT}/") }.join(", ")}"
  end
```

- [ ] **Step 4: Run the suite and confirm it is unchanged**

No fixture exists yet, so every scenario has exactly one lane:

```bash
cd gem
bundle exec rake golden
```

Expected: `210 runs, ... 0 failures, 0 errors, 0 skips` — 188 Phlex-lane scenarios, 5 coverage tests, 12 canonicalizer tests, 5 harness tests.

- [ ] **Step 5: Write Button's fixtures**

The catalog's Button block (`gem/test/golden/scenarios.rb`) is:

```ruby
Golden::Catalog.component "button" do
  %i[primary secondary destructive outline ghost link].each do |variant|
    scenario "variant_#{variant}" do
      RubyUI.Button(variant: variant) { variant.to_s }
    end
  end

  %i[sm md lg xl].each do |size|
    scenario "size_#{size}" do
      RubyUI.Button(size: size) { size.to_s }
    end

    scenario "icon_size_#{size}" do
      RubyUI.Button(size: size, icon: true) { "X" }
    end
  end

  scenario "submit_disabled" do
    RubyUI.Button(type: :submit, disabled: true) { "Save" }
  end
end
```

The translation rule, which 2.0b applies to every other component: `RubyUI.X(args) { "text" }` becomes `<%= render RubyUI::X.new(args) do %>text<% end %>`, on one line, block text verbatim. Create these 15 files under `gem/test/golden/views/button/`, each containing exactly the one line shown (plus a trailing newline):

| File | Content |
| --- | --- |
| `variant_primary.html.erb` | `<%= render RubyUI::Button.new(variant: :primary) do %>primary<% end %>` |
| `variant_secondary.html.erb` | `<%= render RubyUI::Button.new(variant: :secondary) do %>secondary<% end %>` |
| `variant_destructive.html.erb` | `<%= render RubyUI::Button.new(variant: :destructive) do %>destructive<% end %>` |
| `variant_outline.html.erb` | `<%= render RubyUI::Button.new(variant: :outline) do %>outline<% end %>` |
| `variant_ghost.html.erb` | `<%= render RubyUI::Button.new(variant: :ghost) do %>ghost<% end %>` |
| `variant_link.html.erb` | `<%= render RubyUI::Button.new(variant: :link) do %>link<% end %>` |
| `size_sm.html.erb` | `<%= render RubyUI::Button.new(size: :sm) do %>sm<% end %>` |
| `size_md.html.erb` | `<%= render RubyUI::Button.new(size: :md) do %>md<% end %>` |
| `size_lg.html.erb` | `<%= render RubyUI::Button.new(size: :lg) do %>lg<% end %>` |
| `size_xl.html.erb` | `<%= render RubyUI::Button.new(size: :xl) do %>xl<% end %>` |
| `icon_size_sm.html.erb` | `<%= render RubyUI::Button.new(size: :sm, icon: true) do %>X<% end %>` |
| `icon_size_md.html.erb` | `<%= render RubyUI::Button.new(size: :md, icon: true) do %>X<% end %>` |
| `icon_size_lg.html.erb` | `<%= render RubyUI::Button.new(size: :lg, icon: true) do %>X<% end %>` |
| `icon_size_xl.html.erb` | `<%= render RubyUI::Button.new(size: :xl, icon: true) do %>X<% end %>` |
| `submit_disabled.html.erb` | `<%= render RubyUI::Button.new(type: :submit, disabled: true) do %>Save<% end %>` |

- [ ] **Step 6: Run the suite and confirm the ERB lane is at parity**

```bash
cd gem
bundle exec rake golden
```

Expected: `225 runs, ... 0 failures, 0 errors, 0 skips` — the 15 `test_button__*__erb` tests are new and green against the frozen snapshots, rendering the still-Phlex `RubyUI::Button` through phlex-rails. Then:

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain gem/test/golden/snapshots
```

Expected: no output. **If any `__erb` test fails, STOP** and report which and its diff — either the fixture is mistranslated or phlex-rails renders differently from a direct Phlex call, and the difference is the finding.

- [ ] **Step 7: Run everything and commit**

```bash
cd gem
bundle exec rake
```

Expected: `580 runs, ... 0 failures, 0 errors, 0 skips`, `423 files inspected, no offenses detected`. Registry current.

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/test/golden/catalog.rb gem/test/golden/harness.rb gem/test/golden_test.rb gem/test/golden/views
git commit -m "$(cat <<'MSG'
[Feature] Golden suite: an ERB lane, proved on Button

A scenario may now have an ERB fixture under test/golden/views next to
its Phlex block; the suite renders the fixture through the harness and
compares it against the same frozen snapshot, as its own test. With
phlex-rails loaded a fixture can render a component that is still
Phlex, so every fixture can be written and made green before a single
component migrates — after which a migration changes only the
implementation, never the ruler.

Button's 15 fixtures are the proof: byte-identical in canonical form
to the snapshots the Phlex lane recorded.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
MSG
)"
```

---

## Task 6: The strict lane

The canonical form is blind, by design, to whitespace between element siblings and at text–element boundaries (§9.1). Every scenario now keeps a second snapshot: the canonical form in **preserve mode** over the whole fragment (text verbatim, whitespace kept, attributes still sorted, comments still dropped, the fragment's own leading and trailing whitespace trimmed). Recorded from the Phlex lane now, while Phlex still renders; a fixture or a migrated component that adds a newline where Phlex emitted none fails it — for every component, not a chosen list (decision 8: an audit of the catalog found text inside inline elements in 38 of 54 components, and any list is one review away from missing one).

**Files:**
- Modify: `gem/test/golden/canonical_html.rb`
- Modify: `gem/test/golden/canonical_html_test.rb`
- Modify: `gem/test/golden/catalog.rb`
- Modify: `gem/test/golden_test.rb`
- Create (by re-recording): 188 files under `gem/test/golden/strict/`

**Interfaces:**
- Consumes: Task 5's lanes.
- Produces:
  - `Golden::CanonicalHtml.call(html, strict: false)`; `strict: true` is the preserve-mode form.
  - `Golden::Catalog::STRICT_ROOT`; `Scenario#strict_snapshot_path`; `Golden::Catalog.strict_files`; `record!` writes both forms.

- [ ] **Step 1: Write the failing canonicalizer tests**

Add to `gem/test/golden/canonical_html_test.rb`, inside the class:

```ruby
  def strict(html)
    Golden::CanonicalHtml.call(html, strict: true)
  end

  def test_strict_sees_whitespace_between_inline_siblings
    refute_equal strict("<span>a</span><span>b</span>"), strict("<span>a</span> <span>b</span>")
  end

  def test_strict_sees_whitespace_at_a_text_element_boundary
    refute_equal strict("<p>Hello <em>w</em></p>"), strict("<p>Hello<em>w</em></p>")
  end

  def test_strict_keeps_text_verbatim_and_still_sorts_attributes
    assert_equal %(<div class="a" id="x">\n  two  words\n</div>), strict(%(<div id="x" class="a">\n  two  words\n</div>))
  end

  def test_strict_trims_the_fragments_own_edges
    assert_equal "<b>x</b>", strict("\n  <b>x</b>\n")
  end

  def test_strict_is_a_fixed_point
    once = strict(%(<p>Hello <em>w</em>\n<code>a &lt; b</code></p>\n))

    assert_equal once, strict(once)
  end

  def test_strict_keeps_raw_text_elements_raw
    once = strict("<div><script>if (a < b) {}</script></div>")

    assert_equal once, strict(once)
    assert_includes once, "a < b"
  end

  def test_strict_restores_the_newline_the_parser_drops_after_pre_and_textarea
    %w[pre textarea].each do |tag|
      once = strict("<#{tag}>\n\nx</#{tag}>")

      assert_equal "<#{tag}>\n\nx</#{tag}>", once
      assert_equal once, strict(once)
    end
  end

  def test_strict_restores_it_for_a_nested_pre_too
    once = strict("<div><pre>\n\nx</pre></div>")

    assert_equal "<div><pre>\n\nx</pre></div>", once
    assert_equal once, strict(once)
  end
```

- [ ] **Step 2: Run them and confirm they fail**

```bash
cd gem
bundle exec rake test N=/GoldenCanonicalHtmlTest#test_strict/
```

Expected: 8 runs, 8 errors — `ArgumentError: unknown keyword: :strict`.

- [ ] **Step 3: Add strict mode**

In `gem/test/golden/canonical_html.rb`:

**(a)** Replace `def call(html)` and its body with:

```ruby
      # `strict: true` is the preserve-mode form: text verbatim, whitespace
      # kept, only the fragment's own edges trimmed. The normal form is blind to
      # whitespace between siblings and at text boundaries by design; the
      # strict form is for the components whose output is text.
      def call(html, strict: false)
        out = +""
        parse(html).each { |node| emit(node, 0, out, strict ? :preserve : :normal) }
        strict ? out.strip : out
      end
```

The two things strict mode needs from `emit_element` and `child_mode` — the newline the parser drops after `<pre>`/`<textarea>` restored whatever the outer mode, and raw-text elements emitted raw wherever they sit — are already on the branch (`64cf273` on `feat/golden-suite`, which fixed them as normal-mode fixed-point holes). `(a)` is the only code change here; the eight tests exercise both in strict mode.

- [ ] **Step 4: Run the canonicalizer tests and confirm they pass**

```bash
cd gem
bundle exec rake test N=/GoldenCanonicalHtmlTest/
```

Expected: `20 runs, ... 0 failures, 0 errors` (the 12 existing and the 8 new). Then confirm nothing moved in normal mode:

```bash
bundle exec rake golden
```

Expected: `233 runs, 0 failures` (the eight strict tests join the ruler's own), no snapshot change.

- [ ] **Step 5: Wire strict snapshots into the catalog and the runner**

In `gem/test/golden/catalog.rb`:

**(a)** After `VIEWS_ROOT`, add:

```ruby
    # Every scenario also keeps its strict form — the same fragment in
    # preserve mode — so whitespace between siblings and at text boundaries is
    # part of the contract for every component (spec §9.1, decision 8).
    STRICT_ROOT = File.expand_path("strict", __dir__)
```

**(b)** Inside `Scenario`, after `recording_lane`, add:

```ruby
      def strict_snapshot_path
        File.join(STRICT_ROOT, component, "#{name}.html")
      end
```

**(c)** Next to `fixture_files`, add:

```ruby
      def strict_files
        Dir.glob(File.join(STRICT_ROOT, "**", "*.html")).sort
      end
```

In `gem/test/golden_test.rb`:

**(d)** At the end of `assert_golden`, after the final `assert_equal recorded, canonical, …`, add:

```ruby
    assert_strict(scenario, lane)
```

**(e)** Add the method after `assert_golden`:

```ruby
  # The strict form: text and whitespace verbatim. Same discipline as the
  # canonical snapshot — determinism, fixed point, then equality.
  def assert_strict(scenario, lane)
    strict = Golden::CanonicalHtml.call(render(scenario, lane), strict: true)

    assert_equal strict, Golden::CanonicalHtml.call(render(scenario, lane), strict: true),
      "#{scenario.slug} does not render deterministically in strict form"

    assert_path_exists scenario.strict_snapshot_path,
      "no strict snapshot for #{scenario.slug} — run `bundle exec rake golden:update` and review the diff"

    recorded = File.read(scenario.strict_snapshot_path)

    assert_equal recorded, Golden::CanonicalHtml.call(recorded, strict: true),
      "the recorded strict form of #{scenario.slug} is not a fixed point of the normalizer"

    assert_equal recorded, strict,
      "strict HTML for #{scenario.slug} no longer matches the recorded 1.6 snapshot"
  end
```

**(f)** Replace `record!` so one render writes both forms:

```ruby
  def record!(scenario)
    self.class.recorded[scenario.slug] ||= begin
      rendered = render(scenario, scenario.recording_lane)
      FileUtils.mkdir_p(File.dirname(scenario.snapshot_path))
      File.write(scenario.snapshot_path, Golden::CanonicalHtml.call(rendered))
      FileUtils.mkdir_p(File.dirname(scenario.strict_snapshot_path))
      File.write(scenario.strict_snapshot_path, Golden::CanonicalHtml.call(rendered, strict: true))
      true
    end
  end
```

**(g)** Add a coverage test to `GoldenCoverageTest`:

```ruby
  def test_no_orphan_strict_snapshot_files
    expected = Golden::Catalog.scenarios.select(&:pinned?).map(&:strict_snapshot_path).sort
    orphans = Golden::Catalog.strict_files - expected

    assert_empty orphans,
      "strict snapshot files with no scenario (delete them): #{orphans.map { |path| path.delete_prefix("#{Golden::Catalog::STRICT_ROOT}/") }.join(", ")}"
  end
```

- [ ] **Step 6: Run the suite and confirm the strict scenarios fail for want of a snapshot**

```bash
cd gem
bundle exec rake golden 2>&1 | grep -c "no strict snapshot"
```

Expected: `203` — every one of the 188 Phlex-lane tests and the 15 Button ERB-lane tests failing on the missing file and nothing else. If the number differs, STOP and list the scenarios.

- [ ] **Step 7: Record the strict snapshots**

```bash
cd gem
bundle exec rake golden:update
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain gem/test/golden/snapshots | wc -l
git status --porcelain --untracked-files=all gem/test/golden/strict | wc -l
find gem/test/golden/strict -name '*.html' | wc -l
```

Expected: `0` (no canonical snapshot changed), `188`, `188`. Read three of them — `badge/all_variants.html`, `dialog/default.html`, `codeblock/ruby_with_clipboard.html` — and confirm they are the raw Phlex output with attributes sorted: no indentation, no added newlines, text verbatim, the `<pre>` content intact.

- [ ] **Step 8: Run everything and commit**

```bash
cd gem
bundle exec rake
```

Expected: `589 runs, ... 0 failures, 0 errors, 0 skips` (580 + 8 strict canonicalizer tests + 1 coverage test), `423 files inspected, no offenses detected`. Registry current.

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add gem/test/golden/canonical_html.rb gem/test/golden/canonical_html_test.rb gem/test/golden/catalog.rb gem/test/golden_test.rb gem/test/golden/strict
git commit -m "$(cat <<'MSG'
[Feature] Golden suite: a strict lane for every scenario

The canonical form is blind to whitespace between siblings and at text
boundaries by design. Every scenario now also keeps the preserve-mode
form: text verbatim, attributes sorted, the fragment's own edges
trimmed. 188 strict snapshots recorded from the Phlex lane while Phlex
still renders; a fixture or a migrated component that adds a newline
where Phlex emitted none fails here even though the canonical form
cannot see it. The fixed-point fix already on the branch (64cf273) is what
makes the strict form a fixed point too.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
MSG
)"
```

---

## Task 7: Record the decisions and amend the spec

The spec deferred five mechanisms to "Phase 2.0"; this plan decided them. They go into the decision log, and the spec's §4.4 and §6 Phase 2.0 are rewritten to say what was built.

**Files:**
- Modify: `design/v2/decisions.md`
- Modify: `design/2026-09-19-rubyui-2-0-design.md`

**Interfaces:** none.

- [ ] **Step 1: Append the decisions**

Append to `design/v2/decisions.md`:

```markdown

## 5. The gem's test harness is an inline Rails application — 2026-09-20

Decision A said `actionview` + `reactionview`, no controller, no dummy app.
ReActionView's handler reads `Rails.root` without a guard, and a template
outside `Rails.root` is "external": when Herb rejects it, `external_template_mode`
falls back to Erubi silently. So the tests need a `Rails`, and its root must be
the gem. `test_helper.rb` boots the smallest `Rails::Application` — no `app/`
directory, no routes, no database — with `config.root` at the gem and
`RAILS_ENV=test`. Measured: the existing suite is unchanged under it and
`ActionView::Template.handler_for_extension(:erb)` is ReActionView's.
**Cost if wrong:** `railties` as a development dependency and ~1 s of boot per
test run. **What would reverse it:** ReActionView dropping its `Rails.root`
reads, at which point the app object goes.

## 6. The 2.0 layer is `RubyUI::Component` until the last Phlex component is gone — 2026-09-20

`RubyUI::Base` is the Phlex base that 256 components inherit; the 2.0 layer
cannot take the name while they exist. It lands as `RubyUI::Component`, every
migrated component inherits `Component`, and one mechanical commit in Phase
2.4 — after the last migration, before the installer is rewritten — renames
`Component` to `Base`. Users never see `Component`. The alternative, renaming
the Phlex base first, touches all 256 files for no user benefit.
**Cost if wrong:** one sed across the migrated files at the end.

## 7. Every ERB fixture is written before any component migrates — 2026-09-20

With `phlex-rails` loaded (development only), an ERB fixture renders a
component that is still Phlex, so the ERB lane can be green for all 188
scenarios while nothing has migrated. Plan 2.0a proves it on Button's 15;
plan 2.0b writes the other 173. After that a migration changes only an
implementation, never the ruler — "did I write the fixture right" and "did I
port the component right" stop being one failure. While a scenario keeps its
Phlex block, that lane records and the ERB lane compares.
**Cost if wrong:** ~2,000 lines of ERB written ahead of the first migration.
`phlex-rails` leaves the gemspec with the last Phlex component.

## 8. The strict lane is the canonical form in preserve mode, for every scenario — 2026-09-20

Every scenario keeps a second snapshot, `CanonicalHtml.call(html, strict: true)`:
the whole fragment in the normalizer's preserve mode (text and whitespace
verbatim, attributes sorted, comments dropped, the fragment's own edges
trimmed). Same fixed-point discipline, same recording rule, same runner. The 188
strict snapshots were recorded from Phlex.

The spec named seven text-bearing components; the plan first mapped that to
five directories. Review found a sixth (Breadcrumb), and an audit of the raw
Phlex output found text inside an inline element in 38 of 54 components — any
list is one review away from missing one. So there is no list: the contract is
the literal one, *the 2.0 sidecar emits what Phlex emitted*, and Phlex never
emitted whitespace between elements. Fixtures and sidecars are written
whitespace-tight — one line, or `<%-`/`-%>` — because the strict form sees
every newline they add; the canonical form stays as the diagnostic (canonical
passes, strict fails: whitespace only).
**Cost if wrong:** 188 more files to keep, sidecars without newlines between
static elements, and strictness where a browser would not have cared (inside a
flex parent, say). **What would reverse it:** sidecars for the large composites
proving unreadable under the rule, at which point the strict lane narrows to a
criterion computed from the output (text adjacent to an element sibling) rather
than a hand-picked list.

## 9. Sidecar lookup takes a list of roots; the fresh-app script moves to 2.4 — 2026-09-20

`RubyUI.component_roots` is an Array — `lib` and `test/probes` in the gem, one
entry in a host app — and a class's sidecar is found under the root that
contains its file, through a `LookupContext` scoped to that root. Collision
with a host template is impossible by construction, and "two sidecars for one
class" cannot happen (one class file, one directory). The fresh-app install
script the spec put in Phase 2.0 moves to Phase 2.4: until the installer writes
the 2.0 initializer, the script would only exercise the 1.6 installer, which
proves nothing about 2.0.
**Cost if wrong:** installation is first exercised end to end in 2.4 rather
than now.
```

- [ ] **Step 2: Amend the spec**

In `design/2026-09-19-rubyui-2-0-design.md`:

**(a)** In §4.4's initializer block, replace `RubyUI.component_root = Rails.root.join("app/components")` with `RubyUI.component_roots = [Rails.root.join("app/components")]`, and in the paragraph after it replace `` `component_root` is the one
directory the sidecar lookup searches (§4.3) `` with `` `component_roots` lists the directories the sidecar lookup searches — one, in a host app (§4.3) ``.

**(b)** In §4.3, after the table of the two layer files, add a sentence to the paragraph that begins `226 lines at the end of the gate`: `During Phase 2 the class is named `RubyUI::Component`, because `RubyUI::Base` is still the Phlex base the unmigrated components inherit; it takes the name `Base` in Phase 2.4 (decision 6).`

**(c)** In §6 Phase 2.0, replace the bullet that begins `- Replace the test harness:` (four lines, through `is replaced by rendering an ERB fixture.`) with:

```markdown
- Replace the test harness: `railties`, `actionview`, `reactionview` and
  `phlex-rails` as development dependencies, and an inline `Rails::Application`
  in `test_helper.rb` with the gem as `Rails.root` — ReActionView's handler
  reads `Rails.root`, and a template outside it falls back to Erubi silently
  when Herb rejects it (decision 5). `ComponentTest#phlex { }` stays for the
  Phlex-lane tests until the last Phlex component goes; `render_erb` renders a
  test view through the harness.
```

**(d)** Replace the bullet that begins `- Add the **ERB lane**` (three lines) with:

```markdown
- Add the **ERB lane** to the golden suite: a scenario may have an ERB fixture
  under `gem/test/golden/views/`, rendered through the harness and compared
  against the same frozen snapshot as its own test. With `phlex-rails` loaded a
  fixture renders a component that is still Phlex, so all 188 fixtures are
  written before any migration — Button's 15 in plan 2.0a, the rest in 2.0b
  (decision 7).
```

**(e)** Replace the bullet that begins `- Implement the scoped sidecar lookup` (four lines) with:

```markdown
- Implement the scoped sidecar lookup: `RubyUI.component_roots`, a
  `LookupContext` per root, the sidecar found under the root that holds the
  class file and nowhere else; the `Template` is not cached on the class, so
  Rails' reloader reaches it (decision 9). Tested against a host template at
  the same virtual path, a class under no root, and a class with no sidecar.
```

**(f)** Replace the bullet that begins `- Define the **strict lane**.` (eight lines, through `difference, not noise.`) with:

```markdown
- Define the **strict lane**: `CanonicalHtml.call(html, strict: true)`, the
  preserve-mode form, with its own snapshot for every scenario under
  `gem/test/golden/strict/`, recorded from Phlex (decision 8). Sidecars and
  fixtures are written whitespace-tight. A strict-lane failure is a real
  difference, not noise.
```

**(i)** In §10's risk table, in the row that begins `| \`app/components\` is also ViewComponent's directory |`, replace `scoped to \`component_root\` (§4.4)` with `scoped to \`component_roots\` (§4.4)`.

**(j)** In §6 Phase 2.3's acceptance paragraph, replace `In the fresh-app install script (Phase 2.0),` with `In the fresh-app install script (Phase 2.4),`.

**(k)** In §9.1, replace the closing paragraph that begins `What the canonical form still does not see, stated as the contract's` (four lines, through `not as a criterion.`) with:

```markdown
As of Phase 2.0a the strict lane closes this for every scenario: each also
keeps its preserve-mode form, so whitespace between element siblings and at
text–element boundaries is part of the contract, not an exclusion (decision 8).
The inventory script stays in the tree as a way to read the catalog, not as a
criterion.
```

**(g)** Replace the bullet that begins `- **Fresh-app install test.**` (five lines) with:

```markdown
- **Fresh-app install test** — moved to Phase 2.4 (decision 9): it only means
  something once the installer writes the 2.0 initializer.
```

**(h)** Replace the acceptance paragraph that begins `**Acceptance.** The layer is in the gem with its own tests, guards included.` with:

```markdown
**Acceptance.** The layer is in the gem with its own tests, guards included.
The ERB lane is green for Button's 15 scenarios against the frozen snapshots
with Button still Phlex, and the strict lane holds one recorded snapshot per
scenario (188). All
three CI jobs are green with the registry unchanged.
```

- [ ] **Step 3: Check nothing dangles**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
grep -n "component_root\b" design/2026-09-19-rubyui-2-0-design.md
grep -n "install script (Phase 2.0)" design/2026-09-19-rubyui-2-0-design.md
grep -n "stated as the contract's" design/2026-09-19-rubyui-2-0-design.md
```

Expected: all three print nothing — every `component_root` is now `component_roots`, the fresh-app script is attributed to Phase 2.4 everywhere, and §9.1 no longer states an exclusion.

- [ ] **Step 4: Commit**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git add design/v2/decisions.md design/2026-09-19-rubyui-2-0-design.md
git commit -m "$(cat <<'MSG'
[Documentation] RubyUI 2.0: record what Phase 2.0a decided

The spec deferred five mechanisms to Phase 2.0. Decisions 5-9 record
them: the inline Rails application the tests boot, Component as the
layer's name until the last Phlex component is gone, every ERB fixture
written before any migration, the strict lane as the canonical form in
preserve mode, and a list of component roots. The spec's §4.4 and §6
Phase 2.0 now say what was built.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
MSG
)"
```

---

## Task 8: Open the pull request

**Files:** none.

- [ ] **Step 1: Confirm the branch is clean and complete**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git status --porcelain
git log --oneline feat/golden-suite..HEAD
```

Expected: no output from the first; eight commits from the second (this plan's file, then Tasks 1–7).

- [ ] **Step 2: Run everything from a clean state**

```bash
cd gem
bundle exec rake
cd ../mcp && bundle exec exe/ruby-ui-mcp-build >/dev/null && git diff --exit-code data/registry.json && echo "registry current"
```

Expected: `589 runs, ... 0 failures, 0 errors, 0 skips`, `423 files inspected, no offenses detected`, `registry current`.

- [ ] **Step 3: Ask the user before pushing**

Pushing and opening a PR are outward-facing. Do not run Step 4 until the user has said to go ahead.

- [ ] **Step 4: Push and open the PR against `feat/golden-suite`**

```bash
cd /Users/cirdes/Workspaces/ruby_ui
git push -u origin v2/foundation
gh pr create --base feat/golden-suite --title "[Feature] RubyUI 2.0 — Phase 2.0a: the component layer, the harness and the suite's new lanes" --body "$(cat <<'MSG'
## What

Stacked on #536. Puts the 2.0 foundation into the gem with every component
still Phlex:

- **`RubyUI::Component` and `RubyUI::Attributes`** — the 2.0 layer from the v2
  gate, promoted: plain Ruby, ERB sidecar found under `RubyUI.component_roots`
  through a lookup scoped to the root that holds the class file (a host
  template at the same virtual path is not picked — tested), `content` reset
  on every render, Phlex 2.4.1's attribute guards ported (an unsafe name
  raises, a `javascript:` URL is dropped — tested), and an `enum` helper that
  coerces `"lg"`/`:lg` and names the allowed values on anything else.
- **The harness** — the gem's tests boot an inline `Rails::Application` so
  ReActionView compiles every template through Herb exactly as a host app
  will; a malformed template is refused at compile time.
- **The golden suite's ERB lane** — a scenario may have an ERB fixture,
  rendered and compared against the same frozen snapshot. With `phlex-rails`
  loaded a fixture renders a still-Phlex component, so all 188 fixtures can be
  green before any migration. Button's 15 are here as the proof.
- **The strict lane** — the canonical form in preserve mode, with one snapshot
  per scenario (188), recorded from Phlex.

No component migrates. Nothing under `gem/lib/ruby_ui/<component>/` changes;
the 188 golden snapshots are byte-identical to #536. No runtime dependency is
added — every new gem is development-only, and `phlex-rails` leaves with the
last Phlex component.

## Why

Phase 2.0 of `design/2026-09-19-rubyui-2-0-design.md`. The five mechanisms the
spec deferred to this phase are decided in `design/v2/decisions.md` entries 5–9.

## Test steps

```bash
cd gem
bundle exec rake            # 589 runs, 0 skips; 423 files, no offenses
bundle exec rake golden     # 234 runs: 188 Phlex-lane + 15 ERB-lane + 6 coverage + 25 of the ruler's own
```

To see the ERB lane work, edit `test/golden/views/button/size_md.html.erb` to
render `size: :lg` and re-run `rake golden`.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
MSG
)"
```

---

## Definition of done for Phase 2.0a

- `bundle exec rake` green on Ruby 3.3 and 3.4 (CI), zero skips; `mcp/data/registry.json` unchanged.
- `RubyUI::Component` and `RubyUI::Attributes` in `gem/lib/ruby_ui/`, with the differential test against Phlex 2.4.1 green (24 cases) and the guard tests green (9).
- The 188 golden snapshots byte-identical to `feat/golden-suite`.
- The ERB lane green for Button's 15 scenarios with `RubyUI::Button` still Phlex.
- 188 strict snapshots recorded; the strict form a fixed point over every one; every scenario has at least one lane.
- No file under `gem/lib/ruby_ui/<component>/` changed; no runtime dependency added.
- `design/v2/decisions.md` entries 5–9; spec §4.4 and §6 Phase 2.0 amended.

## Not in this plan

- **Plan 2.0b** — the other 173 ERB fixtures, component by component, each batch green against the frozen canonical and strict snapshots before the next — so every fixture is written whitespace-tight. Its first task adds the coverage test `every scenario has a fixture`, which cannot pass until it is done.
- **`docs/Gemfile` pinned to the published 1.6 gem** — nothing in `docs/` breaks until the first component migrates, so the pin is the first task of the 2.1 plan.
- **The fresh-app install script** — Phase 2.4, with the installer.
- **Runtime dependencies in the gemspec, the installer, `Component` → `Base`** — Phase 2.4.
