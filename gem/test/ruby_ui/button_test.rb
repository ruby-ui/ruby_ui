# frozen_string_literal: true

require "test_helper"

class RubyUI::ButtonTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Button(variant: :primary) { "Primary" }
    end

    assert_match(/Primary/, output)
  end
end
