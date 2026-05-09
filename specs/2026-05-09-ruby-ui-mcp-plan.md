# Ruby UI MCP Server Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship `ruby_ui-mcp` — a Rails engine gem in `mcp/` that exposes a 7-tool Model Context Protocol server (shadcn-parity) over HTTP, mounted in the existing `docs/` Rails app at `/mcp`, plus a docs page on rubyui.com explaining install + usage.

**Architecture:** New `mcp/` sibling of `gem/` and `docs/`. Static `data/registry.json` built from `../gem/` by a CLI, committed to repo, loaded into memory at Rails boot. `RubyUI::MCP::Engine` mounts a streamable-HTTP MCP endpoint built on `modelcontextprotocol/ruby-sdk`. Seven tools (read-only) query the in-memory registry. Component install happens client-side via `rails g ruby_ui:component` — MCP only returns validated, structured commands.

**Tech Stack:** Ruby 3.3+, Rails 8.1 engine, `mcp` gem (modelcontextprotocol/ruby-sdk), `rack-attack`, `phlex` (docs page), `kramdown` or `reverse_markdown` (HTML→md for docs build), Minitest, StandardRB.

**Reference:** See `specs/2026-05-09-ruby-ui-mcp-design.md` for approved design.

---

## Task 1: Scaffold `mcp/` Rails engine gem

**Files:**
- Create: `mcp/.gitignore`
- Create: `mcp/Gemfile`
- Create: `mcp/Rakefile`
- Create: `mcp/ruby_ui-mcp.gemspec`
- Create: `mcp/lib/ruby_ui/mcp.rb`
- Create: `mcp/lib/ruby_ui/mcp/version.rb`
- Create: `mcp/lib/ruby_ui/mcp/engine.rb`
- Create: `mcp/.standard.yml`

- [ ] **Step 1: Create gemspec**

```ruby
# mcp/ruby_ui-mcp.gemspec
require_relative "lib/ruby_ui/mcp/version"

Gem::Specification.new do |spec|
  spec.name = "ruby_ui-mcp"
  spec.version = RubyUI::MCP::VERSION
  spec.authors = ["Ruby UI"]
  spec.summary = "MCP server for ruby_ui — agent-driven component discovery and install."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3"

  spec.files = Dir["lib/**/*", "data/**/*", "exe/*", "README.md", "LICENSE"]
  spec.bindir = "exe"
  spec.executables = ["ruby-ui-mcp-build"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 8.0"
  spec.add_dependency "mcp", ">= 0.1"
  spec.add_dependency "rack-attack", ">= 6.7"
  spec.add_dependency "reverse_markdown", ">= 2.1"

  spec.add_development_dependency "minitest", ">= 5.0"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "rake"
end
```

- [ ] **Step 2: Create version + module + engine**

```ruby
# mcp/lib/ruby_ui/mcp/version.rb
# frozen_string_literal: true
module RubyUI
  module MCP
    VERSION = "0.1.0"
  end
end
```

```ruby
# mcp/lib/ruby_ui/mcp.rb
# frozen_string_literal: true
require "rails"
require "ruby_ui/mcp/version"
require "ruby_ui/mcp/engine"

module RubyUI
  module MCP
    def self.registry
      @registry ||= Registry.load_default
    end

    def self.root
      Engine.root
    end
  end
end
```

```ruby
# mcp/lib/ruby_ui/mcp/engine.rb
# frozen_string_literal: true
require "rails/engine"

module RubyUI
  module MCP
    class Engine < ::Rails::Engine
      isolate_namespace RubyUI::MCP

      initializer "ruby_ui.mcp.load_registry" do
        require "ruby_ui/mcp/registry"
        RubyUI::MCP.registry # eager load, fail fast on bad registry
      end
    end
  end
end
```

- [ ] **Step 3: Create Gemfile + Rakefile**

```ruby
# mcp/Gemfile
source "https://rubygems.org"
gemspec
```

```ruby
# mcp/Rakefile
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test" << "lib"
  t.pattern = "test/**/*_test.rb"
  t.warning = false
end

begin
  require "standard/rake"
  task default: %i[test standard]
rescue LoadError
  task default: :test
end

namespace :mcp do
  desc "Rebuild registry.json from ../gem"
  task :build do
    sh "exe/ruby-ui-mcp-build"
  end
end
```

- [ ] **Step 4: gitignore + standard config**

```
# mcp/.gitignore
/.bundle/
/Gemfile.lock
/pkg/
/tmp/
```

```yaml
# mcp/.standard.yml
ruby_version: 3.3
```

- [ ] **Step 5: Bundle install + verify load**

Run: `cd mcp && bundle install && bundle exec ruby -Ilib -e "require 'ruby_ui/mcp'; puts RubyUI::MCP::VERSION"`
Expected: `0.1.0`

- [ ] **Step 6: Commit**

```bash
git add mcp/
git commit -m "[Feature] Scaffold ruby_ui-mcp Rails engine gem"
```

---

## Task 2: Registry data model

**Files:**
- Create: `mcp/lib/ruby_ui/mcp/registry.rb`
- Create: `mcp/test/test_helper.rb`
- Create: `mcp/test/registry_test.rb`
- Create: `mcp/test/fixtures/registry.json`

- [ ] **Step 1: Write fixture registry**

```json
// mcp/test/fixtures/registry.json
{
  "version": "1.2.0",
  "generated_at": "2026-05-09T00:00:00Z",
  "components": {
    "button": {
      "name": "Button",
      "description": "Trigger actions or events.",
      "files": [{"path": "button.rb", "content": "class Button; end\n"}],
      "dependencies": {"components": [], "js_packages": [], "gems": []},
      "install_command": "rails g ruby_ui:component Button",
      "docs_markdown": "# Button\n",
      "examples": [{"title": "Basic", "code": "RubyUI.Button { 'x' }"}]
    },
    "dialog": {
      "name": "Dialog",
      "description": "Modal dialog.",
      "files": [{"path": "dialog.rb", "content": "class Dialog; end\n"}],
      "dependencies": {"components": ["Button"], "js_packages": [], "gems": []},
      "install_command": "rails g ruby_ui:component Dialog",
      "docs_markdown": "# Dialog\n",
      "examples": []
    }
  }
}
```

- [ ] **Step 2: Write failing tests**

```ruby
# mcp/test/test_helper.rb
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "minitest/autorun"
require "ruby_ui/mcp/registry"

module TestSupport
  FIXTURE_PATH = File.expand_path("fixtures/registry.json", __dir__)
end
```

```ruby
# mcp/test/registry_test.rb
require "test_helper"

class RegistryTest < Minitest::Test
  def setup
    @registry = RubyUI::MCP::Registry.load(TestSupport::FIXTURE_PATH)
  end

  def test_version
    assert_equal "1.2.0", @registry.version
  end

  def test_list_returns_all_components
    names = @registry.list.map { |c| c[:name] }
    assert_equal %w[Button Dialog], names.sort
  end

  def test_find_by_name_case_insensitive
    assert_equal "Button", @registry.find("button")[:name]
    assert_equal "Button", @registry.find("Button")[:name]
  end

  def test_find_unknown_returns_nil
    assert_nil @registry.find("Nonexistent")
  end

  def test_search_matches_name
    results = @registry.search("dial")
    assert_equal ["Dialog"], results.map { |r| r[:name] }
  end

  def test_search_matches_description
    results = @registry.search("modal")
    assert_equal ["Dialog"], results.map { |r| r[:name] }
  end

  def test_validate_names_returns_known_and_unknown
    known, unknown = @registry.partition_names(["Button", "Bogus"])
    assert_equal ["Button"], known
    assert_equal ["Bogus"], unknown
  end
end
```

- [ ] **Step 3: Run tests, verify failure**

Run: `cd mcp && bundle exec rake test`
Expected: FAIL — `Registry` not defined.

- [ ] **Step 4: Implement Registry**

```ruby
# mcp/lib/ruby_ui/mcp/registry.rb
# frozen_string_literal: true
require "json"

module RubyUI
  module MCP
    class Registry
      NAME_REGEX = /\A[A-Z][A-Za-z0-9]*\z/

      def self.load_default
        path = ENV["RUBY_UI_MCP_REGISTRY"] || default_path
        load(path)
      end

      def self.default_path
        File.expand_path("../../../data/registry.json", __dir__)
      end

      def self.load(path)
        raw = JSON.parse(File.read(path), symbolize_names: true)
        new(raw)
      end

      attr_reader :version, :generated_at

      def initialize(raw)
        @version = raw[:version]
        @generated_at = raw[:generated_at]
        @components = raw[:components] || {}
      end

      def list
        @components.values.map { |c| {name: c[:name], description: c[:description]} }
      end

      def all
        @components.values
      end

      def find(name)
        key = name.to_s.downcase
        @components[key.to_sym]
      end

      def search(query, limit: 10)
        q = query.to_s.downcase
        scored = @components.values.map do |c|
          haystack = "#{c[:name]} #{c[:description]} #{c[:docs_markdown]}".downcase
          score = haystack.include?(q) ? haystack.scan(q).length : 0
          [c, score]
        end
        scored.select { |_, s| s > 0 }
          .sort_by { |_, s| -s }
          .first(limit)
          .map { |c, s| {name: c[:name], description: c[:description], score: s} }
      end

      def partition_names(names)
        known_set = @components.values.map { |c| c[:name] }.to_set
        names.partition { |n| NAME_REGEX.match?(n) && known_set.include?(n) }
      end
    end
  end
end
```

- [ ] **Step 5: Run tests, verify pass**

Run: `cd mcp && bundle exec rake test`
Expected: PASS, 7 assertions.

- [ ] **Step 6: Commit**

```bash
git add mcp/lib/ruby_ui/mcp/registry.rb mcp/test/
git commit -m "[Feature] MCP Registry data model + tests"
```

---

## Task 3: Registry Builder (reads `../gem`)

**Files:**
- Create: `mcp/lib/ruby_ui/mcp/builders/registry_builder.rb`
- Create: `mcp/test/builders/registry_builder_test.rb`
- Create: `mcp/test/fixtures/fake_gem/lib/ruby_ui/version.rb`
- Create: `mcp/test/fixtures/fake_gem/lib/ruby_ui/button/button.rb`
- Create: `mcp/test/fixtures/fake_gem/lib/ruby_ui/button/button_docs.rb`
- Create: `mcp/test/fixtures/fake_gem/lib/generators/ruby_ui/dependencies.yml`

- [ ] **Step 1: Build fake gem fixture**

```ruby
# mcp/test/fixtures/fake_gem/lib/ruby_ui/version.rb
module RubyUI; VERSION = "9.9.9"; end
```

```ruby
# mcp/test/fixtures/fake_gem/lib/ruby_ui/button/button.rb
# RubyUI::Button — clickable.
module RubyUI
  class Button
  end
end
```

```ruby
# mcp/test/fixtures/fake_gem/lib/ruby_ui/button/button_docs.rb
class Views::Docs::Button
  def view_template
    h1 { "Button" }
    p { "A clickable button." }
  end
end
```

```yaml
# mcp/test/fixtures/fake_gem/lib/generators/ruby_ui/dependencies.yml
button:
  components: []
  js_packages: []
```

- [ ] **Step 2: Write failing test**

```ruby
# mcp/test/builders/registry_builder_test.rb
require "test_helper"
require "ruby_ui/mcp/builders/registry_builder"

class RegistryBuilderTest < Minitest::Test
  def test_builds_registry_from_fake_gem
    fixture = File.expand_path("../fixtures/fake_gem", __dir__)
    registry = RubyUI::MCP::Builders::RegistryBuilder.new(gem_path: fixture).build

    assert_equal "9.9.9", registry[:version]
    assert registry[:components][:button]
    button = registry[:components][:button]
    assert_equal "Button", button[:name]
    assert_match(/clickable/i, button[:description])
    assert button[:files].any? { |f| f[:path] == "button.rb" }
    assert_equal "rails g ruby_ui:component Button", button[:install_command]
  end
end
```

- [ ] **Step 3: Run, verify failure**

Run: `cd mcp && bundle exec rake test TEST=test/builders/registry_builder_test.rb`
Expected: FAIL — builder missing.

- [ ] **Step 4: Implement Builder**

```ruby
# mcp/lib/ruby_ui/mcp/builders/registry_builder.rb
# frozen_string_literal: true
require "yaml"
require "time"

module RubyUI
  module MCP
    module Builders
      class RegistryBuilder
        SKIP_DIRS = %w[base.rb docs].freeze

        def initialize(gem_path:)
          @gem_path = gem_path
        end

        def build
          {
            version: read_version,
            generated_at: (ENV["SOURCE_DATE_EPOCH"] ? Time.at(ENV["SOURCE_DATE_EPOCH"].to_i).utc : Time.now.utc).iso8601,
            components: components_hash
          }
        end

        def write(path)
          require "json"
          File.write(path, JSON.pretty_generate(build) + "\n")
        end

        private

        def read_version
          eval(File.read(File.join(@gem_path, "lib/ruby_ui/version.rb")))
          RubyUI::VERSION
        rescue
          "unknown"
        end

        def components_hash
          deps = load_deps
          Dir.children(File.join(@gem_path, "lib/ruby_ui"))
            .select { |d| File.directory?(File.join(@gem_path, "lib/ruby_ui", d)) }
            .reject { |d| SKIP_DIRS.include?(d) }
            .sort
            .each_with_object({}) { |d, h| h[d.to_sym] = build_component(d, deps[d] || {}) }
        end

        def load_deps
          path = File.join(@gem_path, "lib/generators/ruby_ui/dependencies.yml")
          File.exist?(path) ? YAML.safe_load_file(path) || {} : {}
        end

        def build_component(slug, dep_entry)
          dir = File.join(@gem_path, "lib/ruby_ui", slug)
          files = Dir.glob(File.join(dir, "*"))
            .reject { |f| File.basename(f).end_with?("_docs.rb") }
            .sort
            .map { |f| {path: File.basename(f), content: File.read(f)} }
          name = camelize(slug)
          docs_md = render_docs_markdown(dir, slug)
          {
            name: name,
            description: extract_description(files, docs_md),
            files: files,
            dependencies: {
              components: Array(dep_entry["components"]),
              js_packages: Array(dep_entry["js_packages"]),
              gems: Array(dep_entry["gems"])
            },
            install_command: "rails g ruby_ui:component #{name}",
            docs_markdown: docs_md,
            examples: extract_examples(docs_md)
          }
        end

        def camelize(slug)
          slug.split("_").map(&:capitalize).join
        end

        def render_docs_markdown(dir, slug)
          docs_file = File.join(dir, "#{slug}_docs.rb")
          return "" unless File.exist?(docs_file)
          # First-pass heuristic: extract h1/p text via regex.
          # Phlex render is added in a follow-up if needed.
          src = File.read(docs_file)
          headings = src.scan(/h1\s*\{\s*"([^"]+)"\s*\}/).flatten.map { |t| "# #{t}" }
          paras = src.scan(/p\s*\{\s*"([^"]+)"\s*\}/).flatten
          (headings + paras).join("\n\n")
        end

        def extract_description(files, docs_md)
          if (m = docs_md.match(/^# .+?\n+([^\n#].+)/m))
            m[1].strip
          elsif files.first && (m = files.first[:content].match(/^# (?:RubyUI::\w+ — )?(.+)$/))
            m[1].strip
          else
            ""
          end
        end

        def extract_examples(_docs_md)
          [] # phase 1: no examples extracted; populated later via VisualCodeExample parser
        end
      end
    end
  end
end
```

- [ ] **Step 5: Run, verify pass**

Run: `cd mcp && bundle exec rake test TEST=test/builders/registry_builder_test.rb`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add mcp/lib/ruby_ui/mcp/builders mcp/test/builders mcp/test/fixtures/fake_gem
git commit -m "[Feature] MCP RegistryBuilder reads gem source"
```

---

## Task 4: Build CLI + initial registry.json

**Files:**
- Create: `mcp/exe/ruby-ui-mcp-build`
- Create: `mcp/data/registry.json` (committed artifact)

- [ ] **Step 1: Write executable**

```ruby
#!/usr/bin/env ruby
# mcp/exe/ruby-ui-mcp-build
# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ruby_ui/mcp/builders/registry_builder"

gem_path = ENV["RUBY_UI_GEM_PATH"] || File.expand_path("../../gem", __dir__)
out = File.expand_path("../data/registry.json", __dir__)
FileUtils.mkdir_p(File.dirname(out))
RubyUI::MCP::Builders::RegistryBuilder.new(gem_path: gem_path).write(out)
puts "Wrote #{out}"
```

- [ ] **Step 2: Make executable**

```bash
chmod +x mcp/exe/ruby-ui-mcp-build
```

- [ ] **Step 3: Run build against real gem**

Run: `cd mcp && bundle exec exe/ruby-ui-mcp-build`
Expected: `Wrote .../mcp/data/registry.json`. File exists with all components from `gem/lib/ruby_ui/`.

- [ ] **Step 4: Sanity-check output**

Run: `cd mcp && ruby -rjson -e "r = JSON.parse(File.read('data/registry.json')); puts r['components'].keys.sort.join(', ')"`
Expected: comma-separated list of all component slugs (button, dialog, etc.).

- [ ] **Step 5: Commit**

```bash
git add mcp/exe/ruby-ui-mcp-build mcp/data/registry.json
git commit -m "[Feature] MCP build CLI + initial registry.json"
```

---

## Task 5: MCP Tools — list, search, view

**Files:**
- Create: `mcp/lib/ruby_ui/mcp/tools/base.rb`
- Create: `mcp/lib/ruby_ui/mcp/tools/get_project_registries.rb`
- Create: `mcp/lib/ruby_ui/mcp/tools/list_items_in_registries.rb`
- Create: `mcp/lib/ruby_ui/mcp/tools/search_items_in_registries.rb`
- Create: `mcp/lib/ruby_ui/mcp/tools/view_items_in_registries.rb`
- Create: `mcp/test/tools/list_test.rb`
- Create: `mcp/test/tools/search_test.rb`
- Create: `mcp/test/tools/view_test.rb`

- [ ] **Step 1: Tool base + tests**

```ruby
# mcp/lib/ruby_ui/mcp/tools/base.rb
# frozen_string_literal: true
module RubyUI
  module MCP
    module Tools
      class Base
        def initialize(registry:)
          @registry = registry
        end

        def call(**args)
          raise NotImplementedError
        end
      end
    end
  end
end
```

```ruby
# mcp/test/tools/list_test.rb
require "test_helper"
require "ruby_ui/mcp/tools/list_items_in_registries"

class ListItemsToolTest < Minitest::Test
  def setup
    @registry = RubyUI::MCP::Registry.load(TestSupport::FIXTURE_PATH)
    @tool = RubyUI::MCP::Tools::ListItemsInRegistries.new(registry: @registry)
  end

  def test_returns_all_components
    items = @tool.call[:items]
    assert_equal 2, items.length
    assert_equal %w[Button Dialog], items.map { |i| i[:name] }.sort
  end
end
```

```ruby
# mcp/test/tools/search_test.rb
require "test_helper"
require "ruby_ui/mcp/tools/search_items_in_registries"

class SearchItemsToolTest < Minitest::Test
  def setup
    @registry = RubyUI::MCP::Registry.load(TestSupport::FIXTURE_PATH)
    @tool = RubyUI::MCP::Tools::SearchItemsInRegistries.new(registry: @registry)
  end

  def test_finds_by_name
    items = @tool.call(query: "dial")[:items]
    assert_equal ["Dialog"], items.map { |i| i[:name] }
  end

  def test_empty_when_no_match
    assert_empty @tool.call(query: "zzz")[:items]
  end
end
```

```ruby
# mcp/test/tools/view_test.rb
require "test_helper"
require "ruby_ui/mcp/tools/view_items_in_registries"

class ViewItemsToolTest < Minitest::Test
  def setup
    @registry = RubyUI::MCP::Registry.load(TestSupport::FIXTURE_PATH)
    @tool = RubyUI::MCP::Tools::ViewItemsInRegistries.new(registry: @registry)
  end

  def test_returns_full_components
    result = @tool.call(items: ["Button"])
    assert_equal 1, result[:items].length
    assert_equal "Button", result[:items].first[:name]
    assert result[:items].first[:files].any?
  end

  def test_unknown_in_unresolved
    result = @tool.call(items: ["Bogus"])
    assert_equal ["Bogus"], result[:unresolved]
  end
end
```

- [ ] **Step 2: Run, verify failures**

Run: `cd mcp && bundle exec rake test`
Expected: 3 failing tests.

- [ ] **Step 3: Implement tools**

```ruby
# mcp/lib/ruby_ui/mcp/tools/get_project_registries.rb
# frozen_string_literal: true
require "ruby_ui/mcp/tools/base"

module RubyUI
  module MCP
    module Tools
      class GetProjectRegistries < Base
        def call(**)
          {
            registries: [{
              name: "ruby_ui",
              url: "https://rubyui.com/mcp",
              description: "Ruby UI components for Phlex + Rails."
            }]
          }
        end
      end
    end
  end
end
```

```ruby
# mcp/lib/ruby_ui/mcp/tools/list_items_in_registries.rb
# frozen_string_literal: true
require "ruby_ui/mcp/tools/base"

module RubyUI
  module MCP
    module Tools
      class ListItemsInRegistries < Base
        def call(**)
          {items: @registry.list, gem_version: @registry.version}
        end
      end
    end
  end
end
```

```ruby
# mcp/lib/ruby_ui/mcp/tools/search_items_in_registries.rb
# frozen_string_literal: true
require "ruby_ui/mcp/tools/base"

module RubyUI
  module MCP
    module Tools
      class SearchItemsInRegistries < Base
        def call(query:, limit: 10, **)
          {items: @registry.search(query, limit: limit), gem_version: @registry.version}
        end
      end
    end
  end
end
```

```ruby
# mcp/lib/ruby_ui/mcp/tools/view_items_in_registries.rb
# frozen_string_literal: true
require "ruby_ui/mcp/tools/base"

module RubyUI
  module MCP
    module Tools
      class ViewItemsInRegistries < Base
        def call(items:, **)
          resolved = []
          unresolved = []
          items.each do |name|
            comp = @registry.find(name)
            comp ? resolved << comp : unresolved << name
          end
          {items: resolved, unresolved: unresolved, gem_version: @registry.version}
        end
      end
    end
  end
end
```

- [ ] **Step 4: Run, verify pass**

Run: `cd mcp && bundle exec rake test`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add mcp/lib/ruby_ui/mcp/tools mcp/test/tools
git commit -m "[Feature] MCP tools: list, search, view"
```

---

## Task 6: MCP Tools — examples, add command, audit

**Files:**
- Create: `mcp/lib/ruby_ui/mcp/tools/get_item_examples_from_registries.rb`
- Create: `mcp/lib/ruby_ui/mcp/tools/get_add_command_for_items.rb`
- Create: `mcp/lib/ruby_ui/mcp/tools/get_audit_checklist.rb`
- Create: `mcp/test/tools/examples_test.rb`
- Create: `mcp/test/tools/add_command_test.rb`
- Create: `mcp/test/tools/audit_test.rb`

- [ ] **Step 1: Write tests**

```ruby
# mcp/test/tools/examples_test.rb
require "test_helper"
require "ruby_ui/mcp/tools/get_item_examples_from_registries"

class ExamplesToolTest < Minitest::Test
  def setup
    @registry = RubyUI::MCP::Registry.load(TestSupport::FIXTURE_PATH)
    @tool = RubyUI::MCP::Tools::GetItemExamplesFromRegistries.new(registry: @registry)
  end

  def test_returns_examples_per_item
    result = @tool.call(items: ["Button"])
    assert_equal 1, result[:items].length
    assert_equal "Button", result[:items].first[:name]
    assert_equal 1, result[:items].first[:examples].length
  end

  def test_empty_examples_returned_for_components_without_any
    result = @tool.call(items: ["Dialog"])
    assert_empty result[:items].first[:examples]
  end
end
```

```ruby
# mcp/test/tools/add_command_test.rb
require "test_helper"
require "ruby_ui/mcp/tools/get_add_command_for_items"

class AddCommandToolTest < Minitest::Test
  def setup
    @registry = RubyUI::MCP::Registry.load(TestSupport::FIXTURE_PATH)
    @tool = RubyUI::MCP::Tools::GetAddCommandForItems.new(registry: @registry)
  end

  def test_returns_structured_and_string_form
    result = @tool.call(items: ["Button", "Dialog"])
    assert_equal "ruby_ui:component", result[:generator]
    assert_equal ["Button", "Dialog"], result[:components]
    assert_equal "rails g ruby_ui:component Button Dialog", result[:command_string]
  end

  def test_filters_unknown_names
    result = @tool.call(items: ["Button", "Bogus"])
    assert_equal ["Button"], result[:components]
    assert_equal ["Bogus"], result[:unresolved]
  end

  def test_rejects_shell_metachars
    result = @tool.call(items: ["Button; rm -rf /"])
    assert_empty result[:components]
    refute_match(/rm/, result[:command_string])
  end
end
```

```ruby
# mcp/test/tools/audit_test.rb
require "test_helper"
require "ruby_ui/mcp/tools/get_audit_checklist"

class AuditChecklistToolTest < Minitest::Test
  def test_returns_checklist
    tool = RubyUI::MCP::Tools::GetAuditChecklist.new(registry: nil)
    items = tool.call[:checklist]
    assert items.length >= 5
    assert items.all? { |i| i[:check] && i[:description] }
  end
end
```

- [ ] **Step 2: Verify failure**

Run: `cd mcp && bundle exec rake test`
Expected: 3 failing test files.

- [ ] **Step 3: Implement**

```ruby
# mcp/lib/ruby_ui/mcp/tools/get_item_examples_from_registries.rb
# frozen_string_literal: true
require "ruby_ui/mcp/tools/base"

module RubyUI
  module MCP
    module Tools
      class GetItemExamplesFromRegistries < Base
        def call(items:, **)
          resolved = items.map do |n|
            c = @registry.find(n)
            c ? {name: c[:name], examples: c[:examples] || []} : nil
          end.compact
          {items: resolved, gem_version: @registry.version}
        end
      end
    end
  end
end
```

```ruby
# mcp/lib/ruby_ui/mcp/tools/get_add_command_for_items.rb
# frozen_string_literal: true
require "ruby_ui/mcp/tools/base"

module RubyUI
  module MCP
    module Tools
      class GetAddCommandForItems < Base
        GENERATOR = "ruby_ui:component"

        def call(items:, **)
          known, unresolved = @registry.partition_names(Array(items))
          {
            generator: GENERATOR,
            components: known,
            unresolved: unresolved,
            command_string: known.empty? ? "" : "rails g #{GENERATOR} #{known.join(" ")}",
            gem_version: @registry.version
          }
        end
      end
    end
  end
end
```

```ruby
# mcp/lib/ruby_ui/mcp/tools/get_audit_checklist.rb
# frozen_string_literal: true
require "ruby_ui/mcp/tools/base"

module RubyUI
  module MCP
    module Tools
      class GetAuditChecklist < Base
        CHECKLIST = [
          {check: "gem_in_gemfile", description: "`ruby_ui` gem present in Gemfile."},
          {check: "components_copied", description: "Component files exist under app/components/ruby_ui/<name>/."},
          {check: "stimulus_registered", description: "Stimulus controllers registered (where applicable)."},
          {check: "js_packages_installed", description: "JS packages from dependencies.yml present in package.json."},
          {check: "tailwind_content_paths", description: "Tailwind content config includes app/components/ruby_ui/**/*."},
          {check: "zeitwerk_loads", description: "Zeitwerk loads the RubyUI namespace without errors."},
          {check: "views_compile", description: "Generated Phlex views render without errors."}
        ].freeze

        def call(**)
          {checklist: CHECKLIST}
        end
      end
    end
  end
end
```

- [ ] **Step 4: Run, verify pass**

Run: `cd mcp && bundle exec rake test`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add mcp/lib/ruby_ui/mcp/tools mcp/test/tools
git commit -m "[Feature] MCP tools: examples, add_command, audit"
```

---

## Task 7: MCP Server wiring (ruby-sdk integration)

**Files:**
- Create: `mcp/lib/ruby_ui/mcp/server.rb`
- Create: `mcp/test/server_test.rb`

- [ ] **Step 1: Read ruby-sdk docs**

Run: `cd mcp && bundle info mcp` and skim `https://github.com/modelcontextprotocol/ruby-sdk` README. Confirm Tool/Server API surface used below matches installed version. Adjust class/method names if SDK has evolved.

- [ ] **Step 2: Write smoke test**

```ruby
# mcp/test/server_test.rb
require "test_helper"
require "ruby_ui/mcp/server"

class ServerTest < Minitest::Test
  def test_lists_seven_tools
    registry = RubyUI::MCP::Registry.load(TestSupport::FIXTURE_PATH)
    server = RubyUI::MCP::Server.build(registry: registry)
    names = server.tools.map(&:name).sort
    assert_equal 7, names.length
    expected = %w[
      get_add_command_for_items
      get_audit_checklist
      get_item_examples_from_registries
      get_project_registries
      list_items_in_registries
      search_items_in_registries
      view_items_in_registries
    ]
    assert_equal expected, names
  end
end
```

- [ ] **Step 3: Run, verify failure**

Run: `cd mcp && bundle exec rake test TEST=test/server_test.rb`
Expected: FAIL — Server missing.

- [ ] **Step 4: Implement Server**

```ruby
# mcp/lib/ruby_ui/mcp/server.rb
# frozen_string_literal: true
require "mcp"
require "ruby_ui/mcp/registry"
require "ruby_ui/mcp/tools/get_project_registries"
require "ruby_ui/mcp/tools/list_items_in_registries"
require "ruby_ui/mcp/tools/search_items_in_registries"
require "ruby_ui/mcp/tools/view_items_in_registries"
require "ruby_ui/mcp/tools/get_item_examples_from_registries"
require "ruby_ui/mcp/tools/get_add_command_for_items"
require "ruby_ui/mcp/tools/get_audit_checklist"

module RubyUI
  module MCP
    class Server
      TOOL_DEFINITIONS = [
        {name: "get_project_registries", klass: Tools::GetProjectRegistries, schema: {}},
        {name: "list_items_in_registries", klass: Tools::ListItemsInRegistries, schema: {}},
        {name: "search_items_in_registries", klass: Tools::SearchItemsInRegistries,
         schema: {query: {type: :string, required: true}, limit: {type: :integer}}},
        {name: "view_items_in_registries", klass: Tools::ViewItemsInRegistries,
         schema: {items: {type: :array, required: true}}},
        {name: "get_item_examples_from_registries", klass: Tools::GetItemExamplesFromRegistries,
         schema: {items: {type: :array, required: true}}},
        {name: "get_add_command_for_items", klass: Tools::GetAddCommandForItems,
         schema: {items: {type: :array, required: true}}},
        {name: "get_audit_checklist", klass: Tools::GetAuditChecklist, schema: {}}
      ].freeze

      def self.build(registry: RubyUI::MCP.registry)
        new(registry: registry).server
      end

      attr_reader :tools

      def initialize(registry:)
        @registry = registry
        @tools = TOOL_DEFINITIONS.map { |d| build_tool(d) }
      end

      def server
        ::MCP::Server.new(name: "ruby_ui", version: RubyUI::MCP::VERSION, tools: @tools)
      end

      private

      def build_tool(definition)
        impl = definition[:klass].new(registry: @registry)
        ::MCP::Tool.define(
          name: definition[:name],
          description: definition[:klass].name,
          input_schema: definition[:schema]
        ) do |args|
          impl.call(**(args || {}).transform_keys(&:to_sym))
        rescue => e
          {error: e.message}
        end
      end
    end
  end
end
```

NOTE: The exact `MCP::Tool.define` / `MCP::Server.new` API depends on the installed `mcp` gem version. If the API differs (e.g., subclassing `MCP::Tool` instead of `define`), adapt accordingly — keep the per-tool dispatch and exception trap behavior.

- [ ] **Step 5: Run, verify pass**

Run: `cd mcp && bundle exec rake test`
Expected: all PASS.

- [ ] **Step 6: Commit**

```bash
git add mcp/lib/ruby_ui/mcp/server.rb mcp/test/server_test.rb
git commit -m "[Feature] MCP Server wiring with 7 tools"
```

---

## Task 8: Rails Engine HTTP mount

**Files:**
- Modify: `mcp/lib/ruby_ui/mcp/engine.rb`
- Create: `mcp/lib/ruby_ui/mcp/rack_app.rb`
- Create: `mcp/config/routes.rb`

- [ ] **Step 1: Implement Rack app wrapping ruby-sdk HTTP transport**

```ruby
# mcp/lib/ruby_ui/mcp/rack_app.rb
# frozen_string_literal: true
require "ruby_ui/mcp/server"
require "mcp/transports/streamable_http" # adjust if SDK path differs

module RubyUI
  module MCP
    class RackApp
      def self.call(env)
        new.call(env)
      end

      def call(env)
        server = Server.build
        transport = ::MCP::Transports::StreamableHTTP.new(server)
        transport.call(env)
      rescue => e
        Rails.logger.tagged("MCP") { Rails.logger.error("#{e.class}: #{e.message}") }
        [500, {"content-type" => "application/json"}, [{error: "internal"}.to_json]]
      end
    end
  end
end
```

- [ ] **Step 2: Routes**

```ruby
# mcp/config/routes.rb
RubyUI::MCP::Engine.routes.draw do
  match "/", to: "RubyUI::MCP::RackApp", via: %i[get post], as: :mcp_root
end
```

If `match` to a Rack class doesn't work, use `mount` in the host app instead and skip engine-level routes.

- [ ] **Step 3: Verify engine boots in isolation**

Run: `cd mcp && bundle exec ruby -Ilib -e "require 'ruby_ui/mcp'; puts RubyUI::MCP::Engine.routes.routes.map(&:path).map(&:spec).join(', ')"`
Expected: lists `/` route. (If SDK transport differs, adjust before proceeding.)

- [ ] **Step 4: Commit**

```bash
git add mcp/lib/ruby_ui/mcp/rack_app.rb mcp/lib/ruby_ui/mcp/engine.rb mcp/config/routes.rb
git commit -m "[Feature] MCP Rails engine + Rack mount point"
```

---

## Task 9: Mount engine in `docs/` Rails app

**Files:**
- Modify: `docs/Gemfile`
- Modify: `docs/config/routes.rb`
- Modify: `docs/config/application.rb` (add Rack::Attack middleware)
- Create: `docs/config/initializers/rack_attack.rb`

- [ ] **Step 1: Add gem to docs Gemfile**

Add line to `docs/Gemfile`:

```ruby
gem "ruby_ui-mcp", path: "../mcp"
```

- [ ] **Step 2: Bundle**

Run: `cd docs && bundle install`
Expected: resolves `ruby_ui-mcp 0.1.0` from path source.

- [ ] **Step 3: Mount in routes**

Append to `docs/config/routes.rb` (top-level, before catch-alls):

```ruby
mount RubyUI::MCP::Engine => "/mcp"
```

- [ ] **Step 4: Configure rate limit**

```ruby
# docs/config/initializers/rack_attack.rb
class Rack::Attack
  throttle("mcp/ip", limit: 60, period: 60.seconds) do |req|
    req.ip if req.path.start_with?("/mcp")
  end
end

Rails.application.config.middleware.use Rack::Attack
```

- [ ] **Step 5: Smoke test boot**

Run: `cd docs && bin/rails runner "puts Rails.application.routes.routes.map { |r| r.path.spec.to_s }.grep(/mcp/)"`
Expected: prints `/mcp` route(s).

- [ ] **Step 6: Smoke test request (in devcontainer)**

Run docker exec rails server (per CLAUDE.local.md), then:

```bash
curl -X POST http://localhost:3001/mcp \
  -H 'content-type: application/json' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

Expected: JSON response listing 7 tools.

- [ ] **Step 7: Commit**

```bash
git add docs/Gemfile docs/Gemfile.lock docs/config/routes.rb docs/config/initializers/rack_attack.rb
git commit -m "[Feature] Mount ruby_ui-mcp engine in docs app at /mcp"
```

---

## Task 10: Docs page — Views::Docs::Mcp

**Files:**
- Create: `docs/app/views/docs/mcp.rb`
- Modify: `docs/app/controllers/docs_controller.rb`
- Modify: `docs/config/routes.rb`
- Modify: `docs/app/components/shared/menu.rb`

- [ ] **Step 1: Add controller action**

In `docs/app/controllers/docs_controller.rb` add:

```ruby
def mcp
end
```

- [ ] **Step 2: Add route**

In `docs/config/routes.rb` inside the existing docs scope:

```ruby
get "mcp", to: "docs#mcp", as: :docs_mcp
```

- [ ] **Step 3: Add menu entry**

In `docs/app/components/shared/menu.rb`, add "MCP" link to the Getting Started or Tools section:

```ruby
{ title: "MCP Server", path: "/docs/mcp" }
```

(Match the exact data shape used in that file.)

- [ ] **Step 4: Write the docs view (shadcn-style)**

```ruby
# docs/app/views/docs/mcp.rb
class Views::Docs::Mcp < Views::Base
  def view_template
    div(class: "mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(
        title: "MCP Server",
        description: "Use the Ruby UI MCP server to give your AI agent access to component source, examples, and an install command."
      )

      Heading(level: 2) { "Setup" }
      P { "Add the MCP server to your editor or AI client. The endpoint is hosted at " }
      Codeblock(content: "https://rubyui.com/mcp", language: "text")

      render Docs::ClientTabs.new do |tabs|
        tabs.tab("Claude Code", "claude mcp add --transport http ruby-ui https://rubyui.com/mcp", "bash")
        tabs.tab("Cursor", cursor_config_json, "json")
        tabs.tab("Claude Desktop", claude_desktop_config_json, "json")
        tabs.tab("Windsurf", windsurf_config_json, "json")
        tabs.tab("VS Code", vscode_config_json, "json")
        tabs.tab("Zed", zed_config_json, "json")
      end

      Heading(level: 2) { "Usage" }
      P { "Once the MCP is connected, ask your agent things like:" }
      ul(class: "list-disc pl-6 space-y-1") do
        li { "Install Button and Dialog from Ruby UI." }
        li { "Show me the source of the Card component." }
        li { "Search Ruby UI for a date input." }
        li { "Audit my Ruby UI install." }
      end

      Heading(level: 2) { "Tools" }
      render Docs::ComponentsTable.new(tools_table_rows)

      Heading(level: 2) { "Troubleshooting" }
      ul(class: "list-disc pl-6 space-y-2") do
        li { "Endpoint must be reachable from the client; corporate proxies may block streamable HTTP." }
        li { "If your agent can't find components, try `get_project_registries` first to confirm the registry is loaded." }
        li { "Run `bundle exec rails g ruby_ui:component <Name>` only inside a Rails app that has the `ruby_ui` gem in its Gemfile." }
      end
    end
  end

  private

  def cursor_config_json
    <<~JSON
      {
        "mcpServers": {
          "ruby-ui": { "url": "https://rubyui.com/mcp" }
        }
      }
    JSON
  end

  def claude_desktop_config_json
    <<~JSON
      {
        "mcpServers": {
          "ruby-ui": { "url": "https://rubyui.com/mcp" }
        }
      }
    JSON
  end

  def windsurf_config_json = cursor_config_json
  def vscode_config_json = cursor_config_json
  def zed_config_json = cursor_config_json

  def tools_table_rows
    [
      ["get_project_registries", "Lists available registries (always returns ruby_ui)."],
      ["list_items_in_registries", "Returns all components with descriptions."],
      ["search_items_in_registries", "Fuzzy search by name, description, or docs."],
      ["view_items_in_registries", "Returns full source files and dependencies for selected components."],
      ["get_item_examples_from_registries", "Returns code examples per component."],
      ["get_add_command_for_items", "Returns a validated `rails g ruby_ui:component …` command."],
      ["get_audit_checklist", "Returns a post-install verification checklist."]
    ]
  end
end
```

NOTE: `Docs::ClientTabs` may not exist — if the codebase doesn't already have a tabs component for code snippets, reuse the existing pattern from `docs/app/views/docs/installation.rb` (or whichever existing page has multi-tab install snippets) and adapt. Do not invent new components for this.

- [ ] **Step 5: Browser-test in devcontainer**

Visit `http://localhost:3001/docs/mcp`. Verify all sections render, tabs switch, code blocks copy.

- [ ] **Step 6: Commit**

```bash
git add docs/app/views/docs/mcp.rb docs/app/controllers/docs_controller.rb docs/config/routes.rb docs/app/components/shared/menu.rb
git commit -m "[Documentation] Add MCP docs page with multi-client install tabs"
```

---

## Task 11: CI integration

**Files:**
- Modify: `.github/workflows/ci.yml`

- [ ] **Step 1: Add mcp test job**

Append to `.github/workflows/ci.yml`:

```yaml
  mcp-test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: mcp
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
          bundler-cache: true
          working-directory: mcp
      - run: bundle exec rake

  mcp-registry-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
          bundler-cache: true
          working-directory: mcp
      - name: Rebuild registry
        working-directory: mcp
        run: bundle exec exe/ruby-ui-mcp-build
      - name: Fail on diff
        run: |
          if ! git diff --exit-code mcp/data/registry.json; then
            echo "registry.json out of date — run 'cd mcp && bundle exec exe/ruby-ui-mcp-build' and commit"
            exit 1
          fi
```

- [ ] **Step 2: Push branch, verify CI green**

Run: `git push origin da/mcp` and watch GitHub Actions. Both new jobs must pass.

- [ ] **Step 3: Commit (if not pushed yet)**

```bash
git add .github/workflows/ci.yml
git commit -m "[CI] Add ruby_ui-mcp test + registry-drift jobs"
```

---

## Task 12: Documentation polish + README

**Files:**
- Create: `mcp/README.md`
- Modify: `README.md` (root, if exists — add MCP section)

- [ ] **Step 1: Write `mcp/README.md`**

Cover: what it is, how to develop locally (`bundle && rake test`), how to rebuild registry (`exe/ruby-ui-mcp-build`), how it's deployed (mounted in docs/), tool reference link to docs site.

- [ ] **Step 2: Commit**

```bash
git add mcp/README.md README.md
git commit -m "[Documentation] Add MCP README"
```

---

## Self-Review Notes

- All 7 tools from spec → Tasks 5 + 6.
- Registry schema → Task 2 (model) + Task 3 (builder) + Task 4 (artifact).
- Engine + HTTP transport → Tasks 7–9.
- Rate limit → Task 9.
- Docs page (shadcn-style multi-client install) → Task 10.
- CI gates including registry drift → Task 11.
- Security (allowlist + structured commands) → Task 6 add_command tests + impl.
- Audit checklist matches spec items → Task 6.

Known soft spots:
- `mcp` ruby-sdk API surface (Tool.define / Server / StreamableHTTP) is assumed; Task 7 step 1 explicitly directs the implementer to verify against installed gem version and adjust.
- `docs_markdown` extraction is regex-based as a phase-1 heuristic (Task 3); a follow-up can render Phlex views properly. Examples extraction is empty in v1.
- `Docs::ClientTabs` may need to be implemented or replaced with existing codebase pattern (Task 10 step 4 NOTE).
