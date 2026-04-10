# frozen_string_literal: true

require "test_helper"

class RubyUI::AlertTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Alert.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::Alert.new.attrs[:class], "rounded-lg"
    assert_includes RubyUI::Alert.new.attrs[:class], "ring-border"
  end

  def test_variant_warning
    comp = RubyUI::Alert.new(variant: :warning)
    assert_includes comp.attrs[:class], "ring-warning/20"
    assert_includes comp.attrs[:class], "text-warning"
  end

  def test_variant_success
    comp = RubyUI::Alert.new(variant: :success)
    assert_includes comp.attrs[:class], "ring-success/20"
    assert_includes comp.attrs[:class], "text-success"
  end

  def test_variant_destructive
    comp = RubyUI::Alert.new(variant: :destructive)
    assert_includes comp.attrs[:class], "ring-destructive/20"
    assert_includes comp.attrs[:class], "text-destructive"
  end

  def test_custom_class_merged
    comp = RubyUI::Alert.new(class: "custom")
    assert_includes comp.attrs[:class], "rounded-lg"
    assert_includes comp.attrs[:class], "custom"
  end

  def test_extra_attrs_pass_through
    comp = RubyUI::Alert.new(id: "my-alert")
    assert_equal "my-alert", comp.attrs[:id]
  end
end

class RubyUI::AlertDescriptionTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AlertDescription.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::AlertDescription.new.attrs[:class], "text-sm"
  end
end

class RubyUI::AlertTitleTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AlertTitle.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::AlertTitle.new.attrs[:class], "font-medium"
  end
end
