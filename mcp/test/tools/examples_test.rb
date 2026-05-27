# frozen_string_literal: true

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
