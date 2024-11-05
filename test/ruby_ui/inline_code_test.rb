# frozen_string_literal: true

require "test_helper"

class RubyUI::InlineCodeTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_inline_code
    output = phlex_context do
      RubyUI::InlineCode() { "This is an inline code block" }
    end

    assert_match("This is an inline code block", output)
    assert_match(/<code/, output)
    assert_match(/bg-muted/, output)
    assert_match(/font-mono/, output)
    assert_match(/text-sm/, output)
    assert_match(/font-semibold/, output)
  end
end
