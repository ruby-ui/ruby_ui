# frozen_string_literal: true

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
