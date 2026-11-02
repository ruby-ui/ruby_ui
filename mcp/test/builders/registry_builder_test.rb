require "test_helper"
require "ruby_ui/mcp/builders/registry_builder"
require "tmpdir"

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

  def test_extracts_examples_from_visual_code_example_blocks
    fixture = File.expand_path("../fixtures/fake_gem", __dir__)
    registry = RubyUI::MCP::Builders::RegistryBuilder.new(gem_path: fixture).build
    button = registry[:components][:button]

    assert_equal 2, button[:examples].length
    assert_equal "Example", button[:examples][0][:title]
    assert_match(/Button \{ "Button" \}/, button[:examples][0][:code])
    assert_equal "ruby", button[:examples][0][:language]
  end

  def test_docs_markdown_contains_header_and_examples
    fixture = File.expand_path("../fixtures/fake_gem", __dir__)
    registry = RubyUI::MCP::Builders::RegistryBuilder.new(gem_path: fixture).build
    md = registry[:components][:button][:docs_markdown]

    assert_match(/# Button/, md)
    assert_match(/A clickable button\./, md)
    assert_match(/## Usage\n\nUse it for actions\.\n\n/, md)
    assert_includes md, %(Pass variant: "primary" for the main one.\n\n)
    assert_match(/### Example/, md)
    assert_match(/```ruby/, md)
  end

  def test_write_splits_one_file_per_component_and_round_trips
    fixture = File.expand_path("../fixtures/fake_gem", __dir__)
    Dir.mktmpdir do |dir|
      File.write(File.join(FileUtils.mkdir_p(File.join(dir, "components")).first, "removed.json"), "{}")
      RubyUI::MCP::Builders::RegistryBuilder.new(gem_path: fixture).write(dir)

      assert_equal({"version" => "9.9.9"}, JSON.parse(File.read(File.join(dir, "index.json"))))
      refute File.exist?(File.join(dir, "components", "removed.json"))
      expected = JSON.parse(JSON.generate(RubyUI::MCP::Builders::RegistryBuilder.new(gem_path: fixture).build), symbolize_names: true)
      registry = RubyUI::MCP::Registry.load(dir)
      assert_equal expected[:version], registry.version
      expected[:components].each { |slug, component| assert_equal component, registry.find(slug) }
      assert_equal expected[:components].size, registry.list.size
    end
  end
end
