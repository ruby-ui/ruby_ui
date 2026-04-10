# frozen_string_literal: true

require "test_helper"

class RubyUI::CheckboxTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Checkbox.new.is_a?(Phlex::HTML)
  end

  def test_type
    assert_equal "checkbox", RubyUI::Checkbox.new.attrs[:type]
  end

  def test_has_default_class
    assert_includes RubyUI::Checkbox.new.attrs[:class], "rounded-sm"
  end

  def test_data_controller_target
    assert_equal "checkbox", RubyUI::Checkbox.new.attrs[:data][:ruby_ui__checkbox_group_target]
  end

  def test_extra_attrs_pass_through
    cb = RubyUI::Checkbox.new(id: "terms", name: "terms")
    assert_equal "terms", cb.attrs[:id]
  end
end

class RubyUI::CheckboxGroupTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CheckboxGroup.new.is_a?(Phlex::HTML)
  end

  def test_role
    assert_equal "group", RubyUI::CheckboxGroup.new.attrs[:role]
  end

  def test_controller
    assert_equal "ruby-ui--checkbox-group", RubyUI::CheckboxGroup.new.attrs[:data][:controller]
  end
end
