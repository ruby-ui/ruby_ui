# frozen_string_literal: true

require "test_helper"

class RubyUI::NativeSelectTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::NativeSelect.new.is_a?(Phlex::HTML)
  end

  def test_default_size_has_h9
    ns = RubyUI::NativeSelect.new
    assert_includes ns.attrs[:class], "h-9"
    refute_includes ns.attrs[:class], "h-7"
  end

  def test_sm_size_has_h7
    ns = RubyUI::NativeSelect.new(size: :sm)
    assert_includes ns.attrs[:class], "h-7"
  end

  def test_has_data_attrs
    ns = RubyUI::NativeSelect.new
    assert_equal "input", ns.attrs.dig(:data, :ruby_ui__form_field_target)
  end

  def test_passes_through_name
    ns = RubyUI::NativeSelect.new(name: "department")
    assert_equal "department", ns.attrs[:name]
  end

  def test_native_select_icon_default_class
    icon = RubyUI::NativeSelectIcon.new
    assert_includes icon.attrs[:class], "text-muted-foreground"
    assert_includes icon.attrs[:class], "pointer-events-none"
  end

  def test_native_select_group_no_default_class
    group = RubyUI::NativeSelectGroup.new(label: "Engineering")
    assert_equal "Engineering", group.attrs[:label]
  end

  def test_native_select_option_passes_value
    opt = RubyUI::NativeSelectOption.new(value: "frontend")
    assert_equal "frontend", opt.attrs[:value]
  end
end
