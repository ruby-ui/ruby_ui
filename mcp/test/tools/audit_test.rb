# frozen_string_literal: true

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
