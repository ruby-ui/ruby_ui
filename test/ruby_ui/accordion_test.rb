# frozen_string_literal: true

require "test_helper"

class RubyUI::AccordionTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Accordion.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::Accordion.new.attrs[:class], "w-full"
  end

  def test_custom_class_merged
    comp = RubyUI::Accordion.new(class: "custom")
    assert_includes comp.attrs[:class], "w-full"
    assert_includes comp.attrs[:class], "custom"
  end

  def test_extra_attrs_pass_through
    comp = RubyUI::Accordion.new(id: "my-id")
    assert_equal "my-id", comp.attrs[:id]
  end
end

class RubyUI::AccordionContentTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AccordionContent.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::AccordionContent.new.attrs[:class], "overflow-y-hidden"
  end

  def test_data_target
    comp = RubyUI::AccordionContent.new
    assert_equal "content", comp.attrs[:data][:ruby_ui__accordion_target]
  end
end

class RubyUI::AccordionDefaultContentTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AccordionDefaultContent.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::AccordionDefaultContent.new.attrs[:class], "pb-4"
  end
end

class RubyUI::AccordionDefaultTriggerTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AccordionDefaultTrigger.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::AccordionDefaultTrigger.new.attrs[:class], "w-full"
  end

  def test_data_action
    comp = RubyUI::AccordionDefaultTrigger.new
    assert_includes comp.attrs[:data][:action], "click->ruby-ui--accordion#toggle"
  end
end

class RubyUI::AccordionIconTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AccordionIcon.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::AccordionIcon.new.attrs[:class], "opacity-50"
  end

  def test_data_target
    comp = RubyUI::AccordionIcon.new
    assert_equal "icon", comp.attrs[:data][:ruby_ui__accordion_target]
  end
end

class RubyUI::AccordionItemTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AccordionItem.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::AccordionItem.new.attrs[:class], "border-b"
  end

  def test_controller
    comp = RubyUI::AccordionItem.new
    assert_equal "ruby-ui--accordion", comp.attrs[:data][:controller]
  end

  def test_open_default
    comp = RubyUI::AccordionItem.new
    assert_equal false, comp.attrs[:data][:ruby_ui__accordion_open_value]
  end

  def test_open_true
    comp = RubyUI::AccordionItem.new(open: true)
    assert_equal true, comp.attrs[:data][:ruby_ui__accordion_open_value]
  end

  def test_rotate_icon_default
    comp = RubyUI::AccordionItem.new
    assert_equal 180, comp.attrs[:data][:ruby_ui__accordion_rotate_icon_value]
  end
end

class RubyUI::AccordionTriggerTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AccordionTrigger.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::AccordionTrigger.new.attrs[:class], "w-full"
  end

  def test_type_button
    comp = RubyUI::AccordionTrigger.new
    assert_equal "button", comp.attrs[:type]
  end

  def test_data_action
    comp = RubyUI::AccordionTrigger.new
    assert_includes comp.attrs[:data][:action], "click->ruby-ui--accordion#toggle"
  end
end
