# frozen_string_literal: true

require "test_helper"

class RubyUI::TooltipTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Tooltip.new.is_a?(Phlex::HTML)
  end

  def test_default_placement
    t = RubyUI::Tooltip.new
    assert_equal "top", t.attrs[:data][:ruby_ui__tooltip_placement_value]
  end

  def test_custom_placement
    t = RubyUI::Tooltip.new(placement: "bottom")
    assert_equal "bottom", t.attrs[:data][:ruby_ui__tooltip_placement_value]
  end

  def test_has_default_class
    assert_includes RubyUI::Tooltip.new.attrs[:class], "group"
  end
end

class RubyUI::TooltipContentTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::TooltipContent.new.is_a?(Phlex::HTML)
  end

  def test_has_id
    tc = RubyUI::TooltipContent.new
    assert tc.attrs[:id]
    assert tc.attrs[:id].start_with?("tooltip")
  end

  def test_has_default_class
    assert_includes RubyUI::TooltipContent.new.attrs[:class], "invisible"
  end
end

class RubyUI::TooltipTriggerTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::TooltipTrigger.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    assert_includes RubyUI::TooltipTrigger.new.attrs[:class], "peer"
  end

  def test_data_target
    assert_equal "trigger", RubyUI::TooltipTrigger.new.attrs[:data][:ruby_ui__tooltip_target]
  end
end
