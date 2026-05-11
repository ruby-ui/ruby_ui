# frozen_string_literal: true

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
