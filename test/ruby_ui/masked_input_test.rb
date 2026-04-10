# frozen_string_literal: true

require "test_helper"

class RubyUI::MaskedInputTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::MaskedInput.new.is_a?(Phlex::HTML)
  end

  def test_type_is_text
    mi = RubyUI::MaskedInput.new
    assert_equal :text, mi.attrs[:type]
  end

  def test_has_masked_input_controller
    mi = RubyUI::MaskedInput.new
    assert_includes mi.attrs.dig(:data, :controller), "ruby-ui--masked-input"
  end

  def test_has_input_classes
    mi = RubyUI::MaskedInput.new
    assert_includes mi.attrs[:class], "flex"
    assert_includes mi.attrs[:class], "h-9"
    assert_includes mi.attrs[:class], "rounded-md"
  end

  def test_custom_data_attrs_merged
    mi = RubyUI::MaskedInput.new(data: {maska: "#####-###"})
    assert_includes mi.attrs.dig(:data, :controller), "ruby-ui--masked-input"
    assert_equal "#####-###", mi.attrs.dig(:data, :maska)
  end

  def test_user_class_merges
    mi = RubyUI::MaskedInput.new(class: "extra-class")
    assert_includes mi.attrs[:class], "extra-class"
    assert_includes mi.attrs[:class], "h-9"
  end

  def test_extra_attrs_pass_through
    mi = RubyUI::MaskedInput.new(placeholder: "Enter value")
    assert_equal "Enter value", mi.attrs[:placeholder]
  end
end
