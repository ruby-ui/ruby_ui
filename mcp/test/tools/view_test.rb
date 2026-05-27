# frozen_string_literal: true

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
