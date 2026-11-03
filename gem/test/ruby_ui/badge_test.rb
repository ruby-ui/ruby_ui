# frozen_string_literal: true

require "test_helper"

class RubyUI::BadgeTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Badge { "Badge" }
    end

    assert_match(/Badge/, output)
  end

  def test_renders_span_with_slot_and_default_variant
    output = phlex { RubyUI.Badge { "New" } }

    assert_match(/\A<span /, output)
    assert_includes output, 'data-slot="badge"'
    assert_includes output, 'data-variant="default"'
    assert_includes output, "bg-primary text-primary-foreground"
    assert_includes output, "rounded-4xl"
    assert_includes output, "h-5"
  end

  def test_primary_is_an_alias_of_default
    output = phlex { RubyUI.Badge(variant: :primary) { "New" } }

    assert_includes output, 'data-variant="default"'
    assert_includes output, "bg-primary text-primary-foreground"
  end

  def test_nil_or_unknown_variant_falls_back_to_default
    [nil, :nope, "nope"].each do |variant|
      output = phlex { RubyUI.Badge(variant: variant) { "New" } }

      assert_includes output, 'data-variant="default"', "variant #{variant.inspect}"
      assert_includes output, "bg-primary", "variant #{variant.inspect}"
    end
  end

  def test_string_variant
    output = phlex { RubyUI.Badge(variant: "secondary") { "New" } }

    assert_includes output, 'data-variant="secondary"'
    assert_includes output, "bg-secondary text-secondary-foreground"
  end

  def test_shadcn_variants
    {
      secondary: "bg-secondary text-secondary-foreground",
      destructive: "bg-destructive/10 text-destructive dark:bg-destructive/20",
      outline: "border-border text-foreground",
      ghost: "hover:bg-muted hover:text-muted-foreground",
      link: "text-primary underline-offset-4 hover:underline"
    }.each do |variant, classes|
      output = phlex { RubyUI.Badge(variant: variant) { "x" } }

      assert_includes output, %(data-variant="#{variant}")
      classes.split.each { |c| assert_includes output, c, "#{variant}: #{c}" }
    end
  end

  def test_outline_keeps_border_color_over_transparent_base
    output = phlex { RubyUI.Badge(variant: :outline) { "x" } }

    assert_includes output, "border-border"
    refute_includes output, "border-transparent"
  end

  def test_removed_color_variants_fall_back_to_default
    %i[success warning blue amber].each do |variant|
      output = phlex { RubyUI.Badge(variant: variant) { "x" } }

      assert_includes output, 'data-variant="default"', variant.inspect
      assert_includes output, "bg-primary text-primary-foreground", variant.inspect
    end
  end

  def test_custom_colors_replace_the_variant_colors
    output = phlex { RubyUI.Badge(class: "bg-green-50 text-green-700 dark:bg-green-950 dark:text-green-300") { "x" } }

    assert_includes output, "bg-green-50 text-green-700"
    refute_match(/\sbg-primary\s/, output)
    refute_includes output, "text-primary-foreground"
  end

  def test_sizes
    sm = phlex { RubyUI.Badge(size: :sm) { "x" } }
    lg = phlex { RubyUI.Badge(size: :lg) { "x" } }
    md = phlex { RubyUI.Badge(size: :unknown) { "x" } }

    assert_includes sm, "h-4"
    assert_includes sm, "px-1.5"
    refute_includes sm, "h-5"
    assert_includes lg, "h-6"
    assert_includes lg, "text-sm"
    refute_includes lg, "text-xs"
    assert_includes md, "h-5"
  end

  def test_href_renders_link
    output = phlex { RubyUI.Badge(href: "/docs") { "Docs" } }

    assert_match(/\A<a /, output)
    assert_includes output, 'href="/docs"'
    assert_includes output, 'data-slot="badge"'
    assert_includes output, "[a]:hover:bg-primary/80"
    assert_includes output, "focus-visible:ring-[3px]"
  end

  def test_outline_link_keeps_anchor_hover
    output = phlex { RubyUI.Badge(variant: :outline, href: "/docs") { "Docs" } }

    assert_match(/\A<a /, output)
    assert_includes output, "[a]:hover:bg-muted"
    assert_includes output, "[a]:hover:text-muted-foreground"
  end

  def test_user_class_and_data_merge
    output = phlex { RubyUI.Badge(class: "ml-2", data: {test: "x"}) { "x" } }

    assert_includes output, "ml-2"
    assert_includes output, "bg-primary text-primary-foreground"
    assert_includes output, 'data-test="x"'
    assert_includes output, 'data-slot="badge"'
    assert_includes output, 'data-variant="default"'
  end
end
