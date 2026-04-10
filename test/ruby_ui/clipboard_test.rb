# frozen_string_literal: true

require "test_helper"

class RubyUI::ClipboardTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Clipboard.new.is_a?(Phlex::HTML)
  end

  def test_default_success_message
    cb = RubyUI::Clipboard.new
    assert_equal "Copied!", cb.success_message
  end

  def test_default_error_message
    cb = RubyUI::Clipboard.new
    assert_equal "Copy Failed!", cb.error_message
  end

  def test_custom_messages
    cb = RubyUI::Clipboard.new(success: "Done!", error: "Failed!")
    assert_equal "Done!", cb.success_message
    assert_equal "Failed!", cb.error_message
  end

  def test_has_data_controller
    cb = RubyUI::Clipboard.new
    assert_equal "ruby-ui--clipboard", cb.attrs.dig(:data, :controller)
  end

  def test_success_value_in_data
    cb = RubyUI::Clipboard.new(success: "Copied!")
    assert_equal "Copied!", cb.attrs.dig(:data, :ruby_ui__clipboard_success_value)
  end

  def test_popover_success_target
    pop = RubyUI::ClipboardPopover.new(type: :success)
    assert_equal "successPopover", pop.wrapper_data[:ruby_ui__clipboard_target]
  end

  def test_popover_error_target
    pop = RubyUI::ClipboardPopover.new(type: :error)
    assert_equal "errorPopover", pop.wrapper_data[:ruby_ui__clipboard_target]
  end

  def test_popover_has_default_class
    pop = RubyUI::ClipboardPopover.new(type: :success)
    assert_includes pop.attrs[:class], "z-50"
    assert_includes pop.attrs[:class], "rounded-md"
  end

  def test_source_target
    src = RubyUI::ClipboardSource.new
    assert_equal "source", src.attrs.dig(:data, :ruby_ui__clipboard_target)
  end

  def test_trigger_target
    trg = RubyUI::ClipboardTrigger.new
    assert_equal "trigger", trg.attrs.dig(:data, :ruby_ui__clipboard_target)
    assert_includes trg.attrs.dig(:data, :action), "copy"
  end
end
