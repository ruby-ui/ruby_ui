# frozen_string_literal: true

require "test_helper"

class RubyUI::SwitchTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Switch(name: "toggle")
    end

    assert_match(/toggle/, output)
  end

  def test_render_checked
    output = phlex do
      RubyUI.Switch(name: "toggle", checked: true)
    end

    assert_match(/checked/, output)
  end
end
