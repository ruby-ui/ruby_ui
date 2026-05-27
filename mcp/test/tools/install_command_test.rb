require "test_helper"
require "ruby_ui/mcp/tools/get_install_command_for_project"

class InstallCommandToolTest < Minitest::Test
  def test_returns_install_steps
    tool = RubyUI::MCP::Tools::GetInstallCommandForProject.new(registry: nil)
    result = tool.call
    assert_equal 3, result[:steps].length
    assert_match(/bundle add ruby_ui/, result[:steps].first[:command])
  end
end
