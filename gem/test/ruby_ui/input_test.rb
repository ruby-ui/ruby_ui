# frozen_string_literal: true

require "test_helper"

class RubyUI::InputTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Input(type: "email", placeholder: "Email")
    end

    assert_match(/Email/, output)
  end

  def test_render_with_value
    output = phlex do
      RubyUI.Input(type: "email", value: "user@email.com")
    end

    assert_match(/user@email.com/, output)
  end
end
