# frozen_string_literal: true

require "test_helper"

class RubyUI::LinkTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Link.new.is_a?(Phlex::HTML)
  end

  def test_default_href
    lnk = RubyUI::Link.new
    assert_equal "#", lnk.attrs[:href]
  end

  def test_custom_href
    lnk = RubyUI::Link.new(href: "/dashboard")
    assert_equal "/dashboard", lnk.attrs[:href]
  end

  def test_default_variant_link_classes
    lnk = RubyUI::Link.new
    assert_includes lnk.attrs[:class], "underline-offset-4"
    assert_includes lnk.attrs[:class], "text-primary"
  end

  def test_variant_primary
    lnk = RubyUI::Link.new(variant: :primary)
    assert_includes lnk.attrs[:class], "bg-primary"
    assert_includes lnk.attrs[:class], "text-primary-foreground"
  end

  def test_variant_secondary
    lnk = RubyUI::Link.new(variant: :secondary)
    assert_includes lnk.attrs[:class], "bg-secondary"
  end

  def test_variant_destructive
    lnk = RubyUI::Link.new(variant: :destructive)
    assert_includes lnk.attrs[:class], "bg-destructive"
  end

  def test_variant_outline
    lnk = RubyUI::Link.new(variant: :outline)
    assert_includes lnk.attrs[:class], "border"
    assert_includes lnk.attrs[:class], "bg-background"
  end

  def test_variant_ghost
    lnk = RubyUI::Link.new(variant: :ghost)
    assert_includes lnk.attrs[:class], "hover:bg-accent"
    refute_includes lnk.attrs[:class], "bg-primary"
  end

  def test_size_sm
    lnk = RubyUI::Link.new(size: :sm)
    assert_includes lnk.attrs[:class], "h-8"
    assert_includes lnk.attrs[:class], "text-xs"
  end

  def test_size_lg
    lnk = RubyUI::Link.new(size: :lg)
    assert_includes lnk.attrs[:class], "h-10"
  end

  def test_icon_mode
    lnk = RubyUI::Link.new(icon: true, size: :md)
    assert_includes lnk.attrs[:class], "h-9"
    assert_includes lnk.attrs[:class], "w-9"
    refute_includes lnk.attrs[:class], "px-4"
  end

  def test_user_classes_merged
    lnk = RubyUI::Link.new(class: "w-full mt-4")
    assert_includes lnk.attrs[:class], "w-full"
    assert_includes lnk.attrs[:class], "mt-4"
  end

  def test_extra_attrs_pass_through
    lnk = RubyUI::Link.new(target: "_blank", data: {turbo: false})
    assert_equal "_blank", lnk.attrs[:target]
    assert_equal({turbo: false}, lnk.attrs[:data])
  end
end
