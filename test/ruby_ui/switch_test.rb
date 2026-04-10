# frozen_string_literal: true

require "test_helper"

class RubyUI::SwitchTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Switch.new.is_a?(Phlex::HTML)
  end

  def test_include_hidden_true_by_default
    sw = RubyUI::Switch.new(name: "toggle")
    assert sw.include_hidden?
    assert_equal "toggle", sw.hidden_input_attrs[:name]
    assert_equal "0", sw.hidden_input_attrs[:value]
  end

  def test_include_hidden_false
    sw = RubyUI::Switch.new(name: "toggle", include_hidden: false)
    refute sw.include_hidden?
  end

  def test_checkbox_attrs_type_and_value
    sw = RubyUI::Switch.new(name: "toggle")
    assert_equal "checkbox", sw.checkbox_attrs[:type]
    assert_equal "1", sw.checkbox_attrs[:value]
    assert_equal "toggle", sw.checkbox_attrs[:name]
  end

  def test_custom_checked_value
    sw = RubyUI::Switch.new(checked_value: "true", unchecked_value: "false")
    assert_equal "true", sw.checkbox_attrs[:value]
    assert_equal "false", sw.hidden_input_attrs[:value]
  end

  def test_label_classes_include_rounded_full
    sw = RubyUI::Switch.new
    assert_includes sw.label_classes, "rounded-full"
    assert_includes sw.label_classes, "bg-input"
  end

  def test_thumb_classes_include_translate
    sw = RubyUI::Switch.new
    assert_includes sw.thumb_classes, "peer-checked:translate-x-5"
  end

  def test_checked_attr_passes_through
    sw = RubyUI::Switch.new(name: "toggle", checked: true)
    assert sw.checkbox_attrs[:checked]
  end

  def test_extra_attrs_pass_through
    sw = RubyUI::Switch.new(name: "foo", data: {controller: "bar"})
    assert_equal({controller: "bar"}, sw.checkbox_attrs[:data])
  end
end
