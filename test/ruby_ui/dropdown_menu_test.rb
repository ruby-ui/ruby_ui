# frozen_string_literal: true

require "test_helper"

class RubyUI::DropdownMenuTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::DropdownMenu.new.is_a?(Phlex::HTML)
  end

  def test_data_controller
    comp = RubyUI::DropdownMenu.new
    assert_equal "ruby-ui--dropdown-menu", comp.attrs.dig(:data, :controller)
  end

  def test_strategy_absolute_default
    comp = RubyUI::DropdownMenu.new
    assert_includes comp.attrs[:class], "is-absolute"
  end

  def test_strategy_fixed
    comp = RubyUI::DropdownMenu.new(options: {strategy: "fixed"})
    assert_includes comp.attrs[:class], "is-fixed"
  end
end

class RubyUI::DropdownMenuContentTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::DropdownMenuContent.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::DropdownMenuContent.new
    assert_includes comp.attrs[:class], "z-50"
  end
end

class RubyUI::DropdownMenuItemTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::DropdownMenuItem.new.is_a?(Phlex::HTML)
  end

  def test_href_default
    comp = RubyUI::DropdownMenuItem.new
    assert_equal "#", comp.attrs[:href]
  end

  def test_custom_href
    comp = RubyUI::DropdownMenuItem.new(href: "/path")
    assert_equal "/path", comp.attrs[:href]
  end
end

class RubyUI::DropdownMenuLabelTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::DropdownMenuLabel.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::DropdownMenuLabel.new
    assert_includes comp.attrs[:class], "font-semibold"
  end
end

class RubyUI::DropdownMenuSeparatorTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::DropdownMenuSeparator.new.is_a?(Phlex::HTML)
  end

  def test_role
    comp = RubyUI::DropdownMenuSeparator.new
    assert_equal "separator", comp.attrs[:role]
  end
end

class RubyUI::DropdownMenuTriggerTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::DropdownMenuTrigger.new.is_a?(Phlex::HTML)
  end

  def test_data_action
    comp = RubyUI::DropdownMenuTrigger.new
    assert_includes comp.attrs.dig(:data, :action).to_s, "toggle"
  end

  def test_default_class
    comp = RubyUI::DropdownMenuTrigger.new
    assert_includes comp.attrs[:class], "inline-block"
  end
end
