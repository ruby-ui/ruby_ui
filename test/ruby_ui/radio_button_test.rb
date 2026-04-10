# frozen_string_literal: true

require "test_helper"

class RubyUI::RadioButtonTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::RadioButton.new.is_a?(Phlex::HTML)
  end

  def test_type
    assert_equal "radio", RubyUI::RadioButton.new.attrs[:type]
  end

  def test_has_default_class
    assert_includes RubyUI::RadioButton.new.attrs[:class], "rounded-full"
  end

  def test_data_action
    assert RubyUI::RadioButton.new.attrs[:data][:action]
  end

  def test_extra_attrs_pass_through
    rb = RubyUI::RadioButton.new(id: "opt1", name: "choice", value: "1")
    assert_equal "opt1", rb.attrs[:id]
  end
end
