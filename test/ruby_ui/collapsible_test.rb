# frozen_string_literal: true

require "test_helper"

class RubyUI::CollapsibleTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Collapsible.new.is_a?(Phlex::HTML)
  end

  def test_default_attrs
    comp = RubyUI::Collapsible.new
    assert_equal "ruby-ui--collapsible", comp.attrs.dig(:data, :controller)
    assert_equal false, comp.attrs.dig(:data, :ruby_ui__collapsible_open_value)
  end

  def test_open_true
    comp = RubyUI::Collapsible.new(open: true)
    assert_equal true, comp.attrs.dig(:data, :ruby_ui__collapsible_open_value)
  end

  def test_extra_attrs_pass_through
    comp = RubyUI::Collapsible.new(id: "my-collapsible")
    assert_equal "my-collapsible", comp.attrs[:id]
  end
end

class RubyUI::CollapsibleContentTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CollapsibleContent.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::CollapsibleContent.new
    assert_includes comp.attrs[:class], "overflow-y-hidden"
  end

  def test_data_target
    comp = RubyUI::CollapsibleContent.new
    assert_equal "content", comp.attrs.dig(:data, :ruby_ui__collapsible_target)
  end

  def test_custom_class_merged
    comp = RubyUI::CollapsibleContent.new(class: "custom")
    assert_includes comp.attrs[:class], "custom"
    assert_includes comp.attrs[:class], "overflow-y-hidden"
  end
end

class RubyUI::CollapsibleTriggerTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CollapsibleTrigger.new.is_a?(Phlex::HTML)
  end

  def test_data_action
    comp = RubyUI::CollapsibleTrigger.new
    assert_includes comp.attrs.dig(:data, :action), "click->ruby-ui--collapsible#toggle"
  end

  def test_extra_attrs_pass_through
    comp = RubyUI::CollapsibleTrigger.new(id: "trigger-1")
    assert_equal "trigger-1", comp.attrs[:id]
  end
end
