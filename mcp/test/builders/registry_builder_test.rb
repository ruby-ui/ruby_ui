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
