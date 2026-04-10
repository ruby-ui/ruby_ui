# frozen_string_literal: true

require "test_helper"

class RubyUI::ButtonTest < Minitest::Test
  def test_default_attrs
    btn = RubyUI::Button.new
    assert_equal :button, btn.attrs[:type]
    assert_includes btn.attrs[:class], "bg-primary"
    assert_includes btn.attrs[:class], "text-primary-foreground"
  end

  def test_variant_primary
    btn = RubyUI::Button.new(variant: :primary)
    assert_includes btn.attrs[:class], "bg-primary"
  end

  def test_variant_secondary
    btn = RubyUI::Button.new(variant: :secondary)
    assert_includes btn.attrs[:class], "bg-secondary"
    refute_includes btn.attrs[:class], "bg-primary"
  end

  def test_variant_destructive
    btn = RubyUI::Button.new(variant: :destructive)
    assert_includes btn.attrs[:class], "bg-destructive"
  end

  def test_variant_outline
    btn = RubyUI::Button.new(variant: :outline)
    assert_includes btn.attrs[:class], "border"
    assert_includes btn.attrs[:class], "bg-background"
  end

  def test_variant_ghost
    btn = RubyUI::Button.new(variant: :ghost)
    refute_includes btn.attrs[:class], "bg-primary"
    assert_includes btn.attrs[:class], "hover:bg-accent"
  end

  def test_variant_link
    btn = RubyUI::Button.new(variant: :link)
    assert_includes btn.attrs[:class], "underline-offset-4"
  end

  def test_size_sm
    btn = RubyUI::Button.new(size: :sm)
    assert_includes btn.attrs[:class], "h-8"
    assert_includes btn.attrs[:class], "text-xs"
  end

  def test_size_lg
    btn = RubyUI::Button.new(size: :lg)
    assert_includes btn.attrs[:class], "h-10"
  end

  def test_icon_mode
    btn = RubyUI::Button.new(icon: true, size: :md)
    assert_includes btn.attrs[:class], "h-9"
    assert_includes btn.attrs[:class], "w-9"
    refute_includes btn.attrs[:class], "px-4"
  end

  def test_type_submit
    btn = RubyUI::Button.new(type: :submit)
    assert_equal :submit, btn.attrs[:type]
  end

  def test_user_classes_merged
    btn = RubyUI::Button.new(class: "w-full mt-4")
    assert_includes btn.attrs[:class], "w-full"
    assert_includes btn.attrs[:class], "mt-4"
    assert_includes btn.attrs[:class], "bg-primary"
  end

  def test_extra_attrs_pass_through
    btn = RubyUI::Button.new(disabled: true, data: {turbo: false})
    assert_equal true, btn.attrs[:disabled]
    assert_equal({turbo: false}, btn.attrs[:data])
  end

  def test_visitor_generates_phlex_from_template
    template = File.read("lib/ruby_ui/button/button.html.erb")
    body = RubyUI::Herb::PhlexGenerator.generate_view_template(template)
    assert_includes body, "button("
    assert_includes body, "**attrs"
  end
end
