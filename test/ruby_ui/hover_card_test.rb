# frozen_string_literal: true

require "test_helper"

class RubyUI::HoverCardTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::HoverCard.new.is_a?(Phlex::HTML)
  end

  def test_data_controller
    comp = RubyUI::HoverCard.new
    assert_equal "ruby-ui--hover-card", comp.attrs.dig(:data, :controller)
  end

  def test_default_options_delay
    comp = RubyUI::HoverCard.new
    options = JSON.parse(comp.attrs.dig(:data, :ruby_ui__hover_card_options_value))
    assert_equal [500, 250], options["delay"]
  end

  def test_extra_attrs_pass_through
    comp = RubyUI::HoverCard.new(id: "hc")
    assert_equal "hc", comp.attrs[:id]
  end
end

class RubyUI::HoverCardContentTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::HoverCardContent.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::HoverCardContent.new
    assert_includes comp.attrs[:class], "z-50"
    assert_includes comp.attrs[:class], "rounded-md"
  end
end

class RubyUI::HoverCardTriggerTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::HoverCardTrigger.new.is_a?(Phlex::HTML)
  end

  def test_data_target
    comp = RubyUI::HoverCardTrigger.new
    assert_equal "trigger", comp.attrs.dig(:data, :ruby_ui__hover_card_target)
  end

  def test_default_class
    comp = RubyUI::HoverCardTrigger.new
    assert_includes comp.attrs[:class], "inline-block"
  end
end
