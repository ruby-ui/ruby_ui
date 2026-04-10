# frozen_string_literal: true

require "test_helper"

class RubyUI::PopoverTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Popover.new.is_a?(Phlex::HTML)
  end

  def test_default_controller
    assert_equal "ruby-ui--popover", RubyUI::Popover.new.attrs[:data][:controller]
  end

  def test_default_trigger_value
    assert_equal "hover", RubyUI::Popover.new.attrs[:data][:ruby_ui__popover_trigger_value]
  end

  def test_custom_options
    p = RubyUI::Popover.new(options: {placement: "top", trigger: "click"})
    assert_equal "click", p.attrs[:data][:ruby_ui__popover_trigger_value]
  end
end

class RubyUI::PopoverContentTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::PopoverContent.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    assert_includes RubyUI::PopoverContent.new.attrs[:class], "rounded-md"
  end

  def test_data_target
    assert_equal "content", RubyUI::PopoverContent.new.attrs[:data][:ruby_ui__popover_target]
  end
end

class RubyUI::PopoverTriggerTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::PopoverTrigger.new.is_a?(Phlex::HTML)
  end

  def test_data_target
    assert_equal "trigger", RubyUI::PopoverTrigger.new.attrs[:data][:ruby_ui__popover_target]
  end

  def test_has_default_class
    assert_includes RubyUI::PopoverTrigger.new.attrs[:class], "inline-block"
  end
end
