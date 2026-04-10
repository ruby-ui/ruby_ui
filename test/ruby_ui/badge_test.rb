# frozen_string_literal: true

require "test_helper"

class RubyUI::BadgeTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Badge.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::Badge.new.attrs[:class], "inline-flex"
    assert_includes RubyUI::Badge.new.attrs[:class], "rounded-md"
    assert_includes RubyUI::Badge.new.attrs[:class], "text-primary"
  end

  def test_variant_secondary
    comp = RubyUI::Badge.new(variant: :secondary)
    assert_includes comp.attrs[:class], "text-secondary"
    assert_includes comp.attrs[:class], "bg-secondary/10"
  end

  def test_variant_destructive
    comp = RubyUI::Badge.new(variant: :destructive)
    assert_includes comp.attrs[:class], "text-destructive"
  end

  def test_variant_success
    comp = RubyUI::Badge.new(variant: :success)
    assert_includes comp.attrs[:class], "text-success"
  end

  def test_size_sm
    comp = RubyUI::Badge.new(size: :sm)
    assert_includes comp.attrs[:class], "text-xs"
    assert_includes comp.attrs[:class], "px-1.5"
  end

  def test_size_lg
    comp = RubyUI::Badge.new(size: :lg)
    assert_includes comp.attrs[:class], "text-sm"
    assert_includes comp.attrs[:class], "px-3"
  end

  def test_custom_class_merged
    comp = RubyUI::Badge.new(class: "custom")
    assert_includes comp.attrs[:class], "rounded-md"
    assert_includes comp.attrs[:class], "custom"
  end

  def test_extra_attrs_pass_through
    comp = RubyUI::Badge.new(id: "my-badge")
    assert_equal "my-badge", comp.attrs[:id]
  end
end
