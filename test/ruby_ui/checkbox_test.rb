# frozen_string_literal: true

require "test_helper"

class RubyUI::CheckboxTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_all_items
    output = phlex_context do
      RubyUI.Checkbox(id: "terms")
    end

    assert_match(/terms/, output)
  end
end
