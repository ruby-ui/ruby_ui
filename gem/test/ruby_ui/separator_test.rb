# frozen_string_literal: true

require "test_helper"

class RubyUI::SeparatorTest < ComponentTest
  def test_render
    output = phlex do
      RubyUI.Separator()
    end

    assert_match(/<div/, output)
    assert_match(/role="separator"/, output)
    assert_match(/aria-orientation="horizontal"/, output)
    assert_match(/data-slot="separator"/, output)
    assert_match(/data-orientation="horizontal"/, output)
    assert_match(/h-px w-full/, output)
  end

  def test_render_with_vertical_orientation
    output = phlex do
      RubyUI.Separator(orientation: :vertical)
    end

    assert_match(/aria-orientation="vertical"/, output)
    assert_match(/data-orientation="vertical"/, output)
    assert_match(/w-px self-stretch/, output)
    refute_match(/h-full/, output)
  end

  def test_render_decorative
    output = phlex do
      RubyUI.Separator(decorative: true, orientation: :vertical)
    end

    assert_match(/role="none"/, output)
    refute_match(/aria-orientation/, output)
    assert_match(/data-orientation="vertical"/, output)
  end

  def test_render_as_hr_uses_implicit_role
    output = phlex do
      RubyUI.Separator(as: :hr)
    end

    assert_match(/<hr/, output)
    assert_match(/border-0/, output)
    refute_match(/role=/, output)
    refute_match(/aria-orientation/, output)
  end

  def test_render_as_vertical_hr
    output = phlex do
      RubyUI.Separator(as: :hr, orientation: :vertical)
    end

    refute_match(/role=/, output)
    assert_match(/aria-orientation="vertical"/, output)
    # preflight's hr { height: 0 } would keep self-stretch from stretching it
    assert_match(/self-stretch border-0 h-auto/, output)
  end

  def test_render_as_decorative_hr
    output = phlex do
      RubyUI.Separator(as: :hr, decorative: true)
    end

    assert_match(/role="none"/, output)
  end

  def test_class_override_merges
    output = phlex do
      RubyUI.Separator(class: "w-auto")
    end

    assert_match(/w-auto/, output)
    refute_match(/w-full/, output)
  end

  def test_invalid_orientation
    assert_raises(ArgumentError) { RubyUI::Separator.new(orientation: :diagonal) }
  end
end
