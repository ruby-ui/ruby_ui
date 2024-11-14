# frozen_string_literal: true

require "test_helper"

class RubyUI::TextareaTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Textarea(rows: 4, placeholder: "Comment")
    end

    assert_match(/Comment/, output)
  end

  def test_render_with_value
    output = phlex do
      RubyUI.Textarea { "Value" }
    end

    assert_match(/Value/, output)
  end
end
