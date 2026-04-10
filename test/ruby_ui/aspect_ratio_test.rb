# frozen_string_literal: true

require "test_helper"

class RubyUI::AspectRatioTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AspectRatio.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    ar = RubyUI::AspectRatio.new
    assert_includes ar.attrs[:class], "bg-muted"
    assert_includes ar.attrs[:class], "absolute"
  end

  def test_default_aspect_ratio_padding
    ar = RubyUI::AspectRatio.new
    assert_in_delta 56.25, ar.padding_bottom, 0.01
  end

  def test_custom_aspect_ratio
    ar = RubyUI::AspectRatio.new(aspect_ratio: "1/1")
    assert_in_delta 100.0, ar.padding_bottom, 0.01
  end

  def test_aspect_ratio_4_3
    ar = RubyUI::AspectRatio.new(aspect_ratio: "4/3")
    assert_in_delta 75.0, ar.padding_bottom, 0.01
  end

  def test_invalid_aspect_ratio_raises
    assert_raises(RuntimeError) { RubyUI::AspectRatio.new(aspect_ratio: "16-9") }
  end

  def test_user_class_merges
    ar = RubyUI::AspectRatio.new(class: "rounded-lg")
    assert_includes ar.attrs[:class], "rounded-lg"
    assert_includes ar.attrs[:class], "bg-muted"
  end
end
