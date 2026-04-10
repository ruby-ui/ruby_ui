# frozen_string_literal: true

require "test_helper"

class RubyUI::SeparatorTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Separator.new.is_a?(Phlex::HTML)
  end

  def test_default_role_none
    assert_equal "none", RubyUI::Separator.new.attrs[:role]
  end

  def test_non_decorative_role_separator
    assert_equal "separator", RubyUI::Separator.new(decorative: false).attrs[:role]
  end

  def test_horizontal_class
    s = RubyUI::Separator.new
    assert_includes s.attrs[:class], "h-[1px]"
    assert_includes s.attrs[:class], "w-full"
  end

  def test_vertical_class
    s = RubyUI::Separator.new(orientation: :vertical)
    assert_includes s.attrs[:class], "w-[1px]"
    assert_includes s.attrs[:class], "h-full"
  end

  def test_as_attr
    assert_equal :div, RubyUI::Separator.new.as
  end

  def test_custom_as
    assert_equal :hr, RubyUI::Separator.new(as: :hr).as
  end

  def test_invalid_orientation_raises
    assert_raises(ArgumentError) { RubyUI::Separator.new(orientation: :diagonal) }
  end
end
