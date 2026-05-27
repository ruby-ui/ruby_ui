# frozen_string_literal: true

require "test_helper"
require "ruby_ui/mcp/server"

class ServerTest < Minitest::Test
  def setup
    @registry = RubyUI::MCP::Registry.load(TestSupport::FIXTURE_PATH)
  end

  def test_builds_with_eight_tools
    builder = RubyUI::MCP::Server.new(registry: @registry)
    names = builder.tool_classes.map(&:name_value).sort
    expected = %w[
      get_add_command_for_items
      get_audit_checklist
      get_install_command_for_project
      get_item_examples_from_registries
      get_project_registries
      list_items_in_registries
      search_items_in_registries
      view_items_in_registries
    ]
    assert_equal expected, names
  end

  def test_build_returns_mcp_server
    mcp_server = RubyUI::MCP::Server.build(registry: @registry)
    assert_kind_of MCP::Server, mcp_server
  end
end
