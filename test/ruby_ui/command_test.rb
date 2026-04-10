# frozen_string_literal: true

require "test_helper"

class RubyUI::CommandTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Command.new.is_a?(Phlex::HTML)
  end

  def test_default_attrs
    comp = RubyUI::Command.new
    assert_equal({}, comp.attrs)
  end

  def test_extra_attrs_pass_through
    comp = RubyUI::Command.new(id: "cmd")
    assert_equal "cmd", comp.attrs[:id]
  end
end

class RubyUI::CommandDialogTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CommandDialog.new.is_a?(Phlex::HTML)
  end

  def test_data_controller
    comp = RubyUI::CommandDialog.new
    assert_equal "ruby-ui--command", comp.attrs.dig(:data, :controller)
  end
end

class RubyUI::CommandDialogTriggerTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CommandDialogTrigger.new.is_a?(Phlex::HTML)
  end

  def test_data_action_contains_open
    comp = RubyUI::CommandDialogTrigger.new
    action = comp.attrs.dig(:data, :action)
    assert_includes action.to_s, "ruby-ui--command#open"
  end

  def test_custom_keybindings
    comp = RubyUI::CommandDialogTrigger.new(keybindings: ["keydown.ctrl+j@window"])
    assert_includes comp.attrs.dig(:data, :action).to_s, "ruby-ui--command#open"
  end
end

class RubyUI::CommandDialogContentTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CommandDialogContent.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::CommandDialogContent.new
    assert_includes comp.attrs[:class], "fixed"
    assert_includes comp.attrs[:class], "z-50"
  end

  def test_size_md_default
    comp = RubyUI::CommandDialogContent.new
    assert_includes comp.attrs[:class], "max-w-lg"
  end

  def test_size_lg
    comp = RubyUI::CommandDialogContent.new(size: :lg)
    assert_includes comp.attrs[:class], "max-w-2xl"
  end
end

class RubyUI::CommandEmptyTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CommandEmpty.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::CommandEmpty.new
    assert_includes comp.attrs[:class], "py-6"
    assert_equal "presentation", comp.attrs[:role]
  end
end

class RubyUI::CommandGroupTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CommandGroup.new.is_a?(Phlex::HTML)
  end

  def test_title
    comp = RubyUI::CommandGroup.new(title: "Settings")
    assert_equal "Settings", comp.title
  end
end

class RubyUI::CommandInputTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CommandInput.new.is_a?(Phlex::HTML)
  end

  def test_default_placeholder
    comp = RubyUI::CommandInput.new
    assert_includes comp.attrs[:placeholder], "Type a command"
  end

  def test_custom_placeholder
    comp = RubyUI::CommandInput.new(placeholder: "Search...")
    assert_equal "Search...", comp.attrs[:placeholder]
  end
end

class RubyUI::CommandItemTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CommandItem.new(value: "test").is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::CommandItem.new(value: "test")
    assert_includes comp.attrs[:class], "flex"
    assert_equal "option", comp.attrs[:role]
  end

  def test_href
    comp = RubyUI::CommandItem.new(value: "test", href: "/path")
    assert_equal "/path", comp.attrs[:href]
  end
end

class RubyUI::CommandListTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CommandList.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::CommandList.new
    assert_includes comp.attrs[:class], "divide-y"
  end
end
