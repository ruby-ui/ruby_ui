# frozen_string_literal: true

require "test_helper"

class RubyUI::ProgressTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Progress.new.is_a?(Phlex::HTML)
  end

  def test_default_value
    p = RubyUI::Progress.new
    assert_equal 0.0, p.attrs[:aria_valuenow]
  end

  def test_custom_value
    p = RubyUI::Progress.new(value: 50)
    assert_equal 50.0, p.attrs[:aria_valuenow]
  end

  def test_value_clamped_to_100
    p = RubyUI::Progress.new(value: 150)
    assert_equal 100.0, p.attrs[:aria_valuenow]
  end

  def test_value_clamped_to_0
    p = RubyUI::Progress.new(value: -10)
    assert_equal 0.0, p.attrs[:aria_valuenow]
  end

  def test_role
    assert_equal "progressbar", RubyUI::Progress.new.attrs[:role]
  end

  def test_has_default_class
    assert_includes RubyUI::Progress.new.attrs[:class], "rounded-full"
  end

  def test_indicator_attrs
    p = RubyUI::Progress.new(value: 50)
    assert_includes p.indicator_attrs[:style], "translateX(-50.0%)"
  end

  def test_aria_valuetext
    p = RubyUI::Progress.new(value: 75)
    assert_equal "75.0%", p.attrs[:aria_valuetext]
  end
end
