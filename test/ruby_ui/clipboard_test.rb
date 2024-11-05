# frozen_string_literal: true

require "test_helper"

class RubyUI::ClipboardTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_all_items
    output = phlex_context do
      RubyUI.Clipboard(success: "Copied!", error: "Copy Failed!")
    end

    assert_match(/Copied/, output)
  end
end
