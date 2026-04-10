# frozen_string_literal: true

require "test_helper"

class RubyUI::FormTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Form.new.is_a?(Phlex::HTML)
  end

  def test_default_attrs
    comp = RubyUI::Form.new
    assert_equal({}, comp.attrs)
  end

  def test_extra_attrs_pass_through
    comp = RubyUI::Form.new(id: "my-form", action: "/submit")
    assert_equal "my-form", comp.attrs[:id]
    assert_equal "/submit", comp.attrs[:action]
  end
end

class RubyUI::FormFieldTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::FormField.new.is_a?(Phlex::HTML)
  end

  def test_data_controller
    comp = RubyUI::FormField.new
    assert_equal "ruby-ui--form-field", comp.attrs.dig(:data, :controller)
  end

  def test_default_class
    comp = RubyUI::FormField.new
    assert_includes comp.attrs[:class], "flex"
  end
end

class RubyUI::FormFieldErrorTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::FormFieldError.new.is_a?(Phlex::HTML)
  end

  def test_data_target
    comp = RubyUI::FormFieldError.new
    assert_equal "error", comp.attrs.dig(:data, :ruby_ui__form_field_target)
  end

  def test_default_class
    comp = RubyUI::FormFieldError.new
    assert_includes comp.attrs[:class], "text-destructive"
  end
end

class RubyUI::FormFieldHintTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::FormFieldHint.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::FormFieldHint.new
    assert_includes comp.attrs[:class], "text-muted-foreground"
  end
end

class RubyUI::FormFieldLabelTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::FormFieldLabel.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::FormFieldLabel.new
    assert_includes comp.attrs[:class], "text-sm"
    assert_includes comp.attrs[:class], "font-medium"
  end
end
