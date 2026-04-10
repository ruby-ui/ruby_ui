# frozen_string_literal: true

require "test_helper"

class RubyUI::InputTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Input.new.is_a?(Phlex::HTML)
  end

  def test_default_type
    assert_equal :string, RubyUI::Input.new.attrs[:type]
  end

  def test_custom_type
    assert_equal :email, RubyUI::Input.new(type: :email).attrs[:type]
  end

  def test_has_default_class
    assert RubyUI::Input.new.attrs[:class]
    assert_includes RubyUI::Input.new.attrs[:class], "h-9"
  end

  def test_file_type_adds_pt_class
    assert_includes RubyUI::Input.new(type: :file).attrs[:class], "pt-[7px]"
  end

  def test_non_file_type_no_pt_class
    refute_includes RubyUI::Input.new(type: :text).attrs[:class], "pt-[7px]"
  end

  def test_data_attrs
    assert RubyUI::Input.new.attrs[:data]
  end

  def test_user_class_merged
    i = RubyUI::Input.new(class: "mt-4")
    assert_includes i.attrs[:class], "mt-4"
    assert_includes i.attrs[:class], "h-9"
  end
end
