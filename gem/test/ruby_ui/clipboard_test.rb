# frozen_string_literal: true

require "test_helper"

class RubyUI::ClipboardTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Clipboard(success: "Copied!", error: "Copy Failed!")
    end

    assert_match(/Copied/, output)
  end
end
