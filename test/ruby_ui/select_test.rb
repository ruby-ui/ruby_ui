# frozen_string_literal: true

require "test_helper"

class RubyUI::SelectTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Select.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    assert_includes RubyUI::Select.new.attrs[:class], "relative"
  end

  def test_controller
    assert_equal "ruby-ui--select", RubyUI::Select.new.attrs[:data][:controller]
  end
end

class RubyUI::SelectContentTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::SelectContent.new.is_a?(Phlex::HTML)
  end

  def test_has_content_id
    assert RubyUI::SelectContent.new.content_id
    assert RubyUI::SelectContent.new.content_id.start_with?("content")
  end

  def test_has_default_class
    assert_includes RubyUI::SelectContent.new.attrs[:class], "hidden"
  end

  def test_role
    assert_equal "listbox", RubyUI::SelectContent.new.attrs[:role]
  end
end

class RubyUI::SelectGroupTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::SelectGroup.new.is_a?(Phlex::HTML)
  end
end

class RubyUI::SelectInputTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::SelectInput.new.is_a?(Phlex::HTML)
  end

  def test_has_hidden_class
    assert_includes RubyUI::SelectInput.new.attrs[:class], "hidden"
  end
end

class RubyUI::SelectItemTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::SelectItem.new.is_a?(Phlex::HTML)
  end

  def test_value
    assert_equal "foo", RubyUI::SelectItem.new(value: "foo").value
  end

  def test_has_default_class
    assert_includes RubyUI::SelectItem.new.attrs[:class], "cursor-pointer"
  end

  def test_role
    assert_equal "option", RubyUI::SelectItem.new.attrs[:role]
  end
end

class RubyUI::SelectLabelTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::SelectLabel.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    assert_includes RubyUI::SelectLabel.new.attrs[:class], "font-semibold"
  end
end

class RubyUI::SelectTriggerTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::SelectTrigger.new.is_a?(Phlex::HTML)
  end

  def test_type
    assert_equal "button", RubyUI::SelectTrigger.new.attrs[:type]
  end

  def test_role
    assert_equal "combobox", RubyUI::SelectTrigger.new.attrs[:role]
  end

  def test_has_default_class
    assert_includes RubyUI::SelectTrigger.new.attrs[:class], "rounded-md"
  end
end

class RubyUI::SelectValueTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::SelectValue.new.is_a?(Phlex::HTML)
  end

  def test_placeholder
    assert_equal "Pick one", RubyUI::SelectValue.new(placeholder: "Pick one").placeholder
  end

  def test_has_default_class
    assert_includes RubyUI::SelectValue.new.attrs[:class], "truncate"
  end
end
