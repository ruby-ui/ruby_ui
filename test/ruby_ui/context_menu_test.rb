# frozen_string_literal: true

require "test_helper"

class RubyUI::ContextMenuTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::ContextMenu.new.is_a?(Phlex::HTML)
  end

  def test_data_controller
    comp = RubyUI::ContextMenu.new
    assert_equal "ruby-ui--context-menu", comp.attrs.dig(:data, :controller)
  end

  def test_options_value
    comp = RubyUI::ContextMenu.new(options: {placement: "right"})
    assert_includes comp.attrs.dig(:data, :ruby_ui__context_menu_options_value), "right"
  end
end

class RubyUI::ContextMenuContentTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::ContextMenuContent.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::ContextMenuContent.new
    assert_includes comp.attrs[:class], "z-50"
    assert_equal "menu", comp.attrs[:role]
  end
end

class RubyUI::ContextMenuItemTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::ContextMenuItem.new.is_a?(Phlex::HTML)
  end

  def test_href_default
    comp = RubyUI::ContextMenuItem.new
    assert_equal "#", comp.attrs[:href]
  end

  def test_custom_href
    comp = RubyUI::ContextMenuItem.new(href: "/path")
    assert_equal "/path", comp.attrs[:href]
  end

  def test_default_class
    comp = RubyUI::ContextMenuItem.new
    assert_includes comp.attrs[:class], "flex"
  end

  def test_checked_attr
    comp = RubyUI::ContextMenuItem.new(checked: true)
    assert comp.checked?
  end

  def test_shortcut_attr
    comp = RubyUI::ContextMenuItem.new(shortcut: "⌘K")
    assert_equal "⌘K", comp.shortcut
  end
end

class RubyUI::ContextMenuLabelTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::ContextMenuLabel.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::ContextMenuLabel.new
    assert_includes comp.attrs[:class], "px-2"
  end

  def test_inset_adds_pl8
    comp = RubyUI::ContextMenuLabel.new(inset: true)
    assert_includes comp.attrs[:class], "pl-8"
  end
end

class RubyUI::ContextMenuSeparatorTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::ContextMenuSeparator.new.is_a?(Phlex::HTML)
  end

  def test_role
    comp = RubyUI::ContextMenuSeparator.new
    assert_equal "separator", comp.attrs[:role]
  end
end

class RubyUI::ContextMenuTriggerTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::ContextMenuTrigger.new.is_a?(Phlex::HTML)
  end

  def test_data_action
    comp = RubyUI::ContextMenuTrigger.new
    assert_includes comp.attrs.dig(:data, :action).to_s, "contextmenu"
  end
end
