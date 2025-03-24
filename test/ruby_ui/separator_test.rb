# frozen_string_literal: true

require "test_helper"

class RubyUI::SeparatorTest < ComponentTest
  def test_render
    output = phlex do
      RubyUI.Separator()
    end

    assert_match(/div/, output)
    assert_match(/role="none"/, output)
    assert_match(/h-\[1px\]/, output)
  end

  def test_render_with_vertical_orientation
    output = phlex do
      RubyUI.Separator(orientation: :vertical)
    end

    assert_match(/w-\[1px\]/, output)
  end

  def test_render_with_decorative_false
    output = phlex do
      RubyUI.Separator(decorative: false)
    end

    assert_match(/role="separator"/, output)
  end

  def test_render_with_custom_tag
    output = phlex do
      RubyUI.Separator(as: "hr")
    end

    assert_match(/<hr/, output)
  end
end
