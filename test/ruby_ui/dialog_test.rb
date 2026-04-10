# frozen_string_literal: true

require "test_helper"

class RubyUI::DialogTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Dialog.new.is_a?(Phlex::HTML)
  end

  def test_data_controller
    comp = RubyUI::Dialog.new
    assert_equal "ruby-ui--dialog", comp.attrs.dig(:data, :controller)
  end

  def test_open_false_by_default
    comp = RubyUI::Dialog.new
    assert_equal false, comp.attrs.dig(:data, :ruby_ui__dialog_open_value)
  end

  def test_open_true
    comp = RubyUI::Dialog.new(open: true)
    assert_equal true, comp.attrs.dig(:data, :ruby_ui__dialog_open_value)
  end
end

class RubyUI::DialogContentTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::DialogContent.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::DialogContent.new
    assert_includes comp.attrs[:class], "fixed"
    assert_includes comp.attrs[:class], "z-50"
    assert_includes comp.attrs[:class], "max-w-lg"
  end

  def test_size_lg
    comp = RubyUI::DialogContent.new(size: :lg)
    assert_includes comp.attrs[:class], "max-w-2xl"
  end
end

class RubyUI::DialogDescriptionTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::DialogDescription.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::DialogDescription.new
    assert_includes comp.attrs[:class], "text-sm"
    assert_includes comp.attrs[:class], "text-muted-foreground"
  end
end

class RubyUI::DialogFooterTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::DialogFooter.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::DialogFooter.new
    assert_includes comp.attrs[:class], "flex"
  end
end

class RubyUI::DialogHeaderTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::DialogHeader.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::DialogHeader.new
    assert_includes comp.attrs[:class], "flex"
  end
end

class RubyUI::DialogMiddleTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::DialogMiddle.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::DialogMiddle.new
    assert_includes comp.attrs[:class], "py-4"
  end
end

class RubyUI::DialogTitleTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::DialogTitle.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    comp = RubyUI::DialogTitle.new
    assert_includes comp.attrs[:class], "font-semibold"
  end
end

class RubyUI::DialogTriggerTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::DialogTrigger.new.is_a?(Phlex::HTML)
  end

  def test_data_action
    comp = RubyUI::DialogTrigger.new
    assert_includes comp.attrs.dig(:data, :action).to_s, "click->ruby-ui--dialog#open"
  end

  def test_default_class
    comp = RubyUI::DialogTrigger.new
    assert_includes comp.attrs[:class], "inline-block"
  end
end
