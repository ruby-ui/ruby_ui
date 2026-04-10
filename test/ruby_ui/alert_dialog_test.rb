# frozen_string_literal: true

require "test_helper"

class RubyUI::AlertDialogTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AlertDialog.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::AlertDialog.new.attrs[:class], "inline-block"
  end

  def test_controller
    comp = RubyUI::AlertDialog.new
    assert_equal "ruby-ui--alert-dialog", comp.attrs[:data][:controller]
  end

  def test_open_default
    comp = RubyUI::AlertDialog.new
    assert_equal "false", comp.attrs[:data][:ruby_ui__alert_dialog_open_value]
  end

  def test_open_true
    comp = RubyUI::AlertDialog.new(open: true)
    assert_equal "true", comp.attrs[:data][:ruby_ui__alert_dialog_open_value]
  end

  def test_extra_attrs_pass_through
    comp = RubyUI::AlertDialog.new(id: "my-dialog")
    assert_equal "my-dialog", comp.attrs[:id]
  end
end

class RubyUI::AlertDialogActionTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AlertDialogAction.new.is_a?(Phlex::HTML)
  end

  def test_has_button_primary_classes
    comp = RubyUI::AlertDialogAction.new
    assert_includes comp.attrs[:class], "bg-primary"
    assert_includes comp.attrs[:class], "text-primary-foreground"
  end
end

class RubyUI::AlertDialogCancelTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AlertDialogCancel.new.is_a?(Phlex::HTML)
  end

  def test_has_button_outline_classes
    comp = RubyUI::AlertDialogCancel.new
    assert_includes comp.attrs[:class], "border"
    assert_includes comp.attrs[:class], "bg-background"
  end

  def test_data_action
    comp = RubyUI::AlertDialogCancel.new
    assert_includes comp.attrs[:data][:action], "click->ruby-ui--alert-dialog#dismiss"
  end
end

class RubyUI::AlertDialogContentTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AlertDialogContent.new.is_a?(Phlex::HTML)
  end

  def test_data_target
    comp = RubyUI::AlertDialogContent.new
    assert_equal "content", comp.attrs[:data][:ruby_ui__alert_dialog_target]
  end
end

class RubyUI::AlertDialogDescriptionTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AlertDialogDescription.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::AlertDialogDescription.new.attrs[:class], "text-sm"
    assert_includes RubyUI::AlertDialogDescription.new.attrs[:class], "text-muted-foreground"
  end
end

class RubyUI::AlertDialogFooterTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AlertDialogFooter.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::AlertDialogFooter.new.attrs[:class], "flex"
    assert_includes RubyUI::AlertDialogFooter.new.attrs[:class], "sm:flex-row"
  end
end

class RubyUI::AlertDialogHeaderTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AlertDialogHeader.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::AlertDialogHeader.new.attrs[:class], "flex"
    assert_includes RubyUI::AlertDialogHeader.new.attrs[:class], "flex-col"
  end
end

class RubyUI::AlertDialogTitleTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AlertDialogTitle.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::AlertDialogTitle.new.attrs[:class], "text-lg"
    assert_includes RubyUI::AlertDialogTitle.new.attrs[:class], "font-semibold"
  end
end

class RubyUI::AlertDialogTriggerTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AlertDialogTrigger.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::AlertDialogTrigger.new.attrs[:class], "inline-block"
  end

  def test_data_action
    comp = RubyUI::AlertDialogTrigger.new
    assert_includes comp.attrs[:data][:action], "click->ruby-ui--alert-dialog#open"
  end
end
