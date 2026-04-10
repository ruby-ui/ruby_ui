# frozen_string_literal: true

require "test_helper"

class RubyUI::ComboboxTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Combobox.new.is_a?(Phlex::HTML)
  end

  def test_default_attrs
    comp = RubyUI::Combobox.new
    assert_equal "combobox", comp.attrs[:role]
    assert_equal "ruby-ui--combobox", comp.attrs.dig(:data, :controller)
  end

  def test_term_value
    comp = RubyUI::Combobox.new(term: "fruits")
    assert_equal "fruits", comp.attrs.dig(:data, :ruby_ui__combobox_term_value)
  end

  def test_extra_attrs_pass_through
    comp = RubyUI::Combobox.new(id: "my-combobox")
    assert_equal "my-combobox", comp.attrs[:id]
  end
end

class RubyUI::ComboboxCheckboxTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::ComboboxCheckbox.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::ComboboxCheckbox.new
    assert_includes comp.attrs[:class], "peer"
  end

  def test_data_target
    comp = RubyUI::ComboboxCheckbox.new
    assert_equal "input", comp.attrs.dig(:data, :ruby_ui__combobox_target)
  end
end

class RubyUI::ComboboxEmptyStateTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::ComboboxEmptyState.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::ComboboxEmptyState.new
    assert_includes comp.attrs[:class], "hidden"
    assert_equal "presentation", comp.attrs[:role]
  end

  def test_data_target
    comp = RubyUI::ComboboxEmptyState.new
    assert_equal "emptyState", comp.attrs.dig(:data, :ruby_ui__combobox_target)
  end
end

class RubyUI::ComboboxItemTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::ComboboxItem.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::ComboboxItem.new
    assert_includes comp.attrs[:class], "flex"
    assert_equal "option", comp.attrs[:role]
  end
end

class RubyUI::ComboboxListTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::ComboboxList.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::ComboboxList.new
    assert_includes comp.attrs[:class], "flex"
    assert_equal "listbox", comp.attrs[:role]
  end
end

class RubyUI::ComboboxListGroupTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::ComboboxListGroup.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::ComboboxListGroup.new
    assert_includes comp.attrs[:class], "hidden"
    assert_equal "group", comp.attrs[:role]
  end
end

class RubyUI::ComboboxPopoverTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::ComboboxPopover.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::ComboboxPopover.new
    assert_includes comp.attrs[:class], "absolute"
    assert_equal "popover", comp.attrs[:role]
  end

  def test_data_target
    comp = RubyUI::ComboboxPopover.new
    assert_equal "popover", comp.attrs.dig(:data, :ruby_ui__combobox_target)
  end
end

class RubyUI::ComboboxRadioTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::ComboboxRadio.new.is_a?(Phlex::HTML)
  end

  def test_data_target
    comp = RubyUI::ComboboxRadio.new
    assert_equal "input", comp.attrs.dig(:data, :ruby_ui__combobox_target)
  end
end

class RubyUI::ComboboxSearchInputTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::ComboboxSearchInput.new(placeholder: "Search").is_a?(Phlex::HTML)
  end

  def test_placeholder
    comp = RubyUI::ComboboxSearchInput.new(placeholder: "Find something")
    assert_equal "Find something", comp.attrs[:placeholder]
  end
end

class RubyUI::ComboboxToggleAllCheckboxTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::ComboboxToggleAllCheckbox.new.is_a?(Phlex::HTML)
  end

  def test_data_target
    comp = RubyUI::ComboboxToggleAllCheckbox.new
    assert_equal "toggleAll", comp.attrs.dig(:data, :ruby_ui__combobox_target)
  end
end

class RubyUI::ComboboxTriggerTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::ComboboxTrigger.new.is_a?(Phlex::HTML)
  end

  def test_placeholder
    comp = RubyUI::ComboboxTrigger.new(placeholder: "Pick a value")
    assert_equal "Pick a value", comp.attrs.dig(:data, :placeholder)
  end

  def test_default_class
    comp = RubyUI::ComboboxTrigger.new
    assert_includes comp.attrs[:class], "flex"
  end

  def test_extra_attrs_pass_through
    comp = RubyUI::ComboboxTrigger.new(id: "trigger")
    assert_equal "trigger", comp.attrs[:id]
  end
end
