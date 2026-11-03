# frozen_string_literal: true

require "test_helper"

class RubyUI::LinkTest < ComponentTest
  def test_default_is_a_vega_primary_link
    output = phlex { RubyUI.Link(href: "/docs") { "Docs" } }

    assert_match(/\A<a /, output)
    assert_includes output, 'href="/docs"'
    assert_includes output, 'data-slot="button"'
    assert_includes output, "bg-primary text-primary-foreground hover:bg-primary/80"
    assert_includes output, "h-9 gap-1.5 px-2.5"
    assert_includes output, "focus-visible:ring-3 focus-visible:ring-ring/50"
    assert_includes output, "transition-all"
  end

  def test_keeps_native_link_semantics
    output = phlex { RubyUI.Link(href: "/docs") { "Docs" } }

    refute_includes output, "role="
    refute_includes output, "type="
    refute_includes output, "data-controller"
  end

  def test_uses_the_same_classes_as_button
    %i[primary outline secondary ghost destructive link].each do |variant|
      %i[xs sm md lg].each do |size|
        link = phlex { RubyUI.Link(variant: variant, size: size) { "A" } }
        button = phlex { RubyUI.Button(variant: variant, size: size) { "A" } }
        assert_equal button[/class="([^"]*)"/, 1].split - ["disabled:pointer-events-none", "disabled:opacity-50"],
          link[/class="([^"]*)"/, 1].split - RubyUI::Link::DISABLED.split - ["disabled:pointer-events-none", "disabled:opacity-50"],
          "#{variant}/#{size}"
      end
    end
  end

  def test_shadcn_aliases_and_fallbacks
    assert_equal phlex { RubyUI.Link { "A" } }, phlex { RubyUI.Link(variant: :default, size: :default) { "A" } }
    assert_equal phlex { RubyUI.Link { "A" } }, phlex { RubyUI.Link(variant: :nope, size: :huge) { "A" } }
    assert_equal phlex { RubyUI.Link(icon: true, size: :sm) { "A" } }, phlex { RubyUI.Link(size: :icon_sm) { "A" } }
  end

  def test_link_variant_is_a_text_link
    output = phlex { RubyUI.Link(href: "#", variant: :link) { "More" } }

    assert_includes output, "text-primary underline-offset-4 hover:underline"
    refute_includes output, "bg-primary"
  end

  def test_icon_link
    output = phlex { RubyUI.Link(href: "#", variant: :outline, icon: true) { "→" } }

    assert_includes output, "h-9 w-9"
  end

  def test_disabled_drops_the_href
    output = phlex { RubyUI.Link(href: "/docs", disabled: true) { "Docs" } }

    refute_includes output, "href="
    assert_includes output, 'role="link"'
    assert_includes output, 'aria-disabled="true"'
    refute_includes output, "tabindex"
    assert_includes output, "aria-disabled:opacity-50"
  end

  def test_focusable_when_disabled_stays_in_the_tab_order
    output = phlex { RubyUI.Link(href: "/docs", disabled: true, focusable_when_disabled: true) { "Docs" } }

    refute_includes output, "href="
    assert_includes output, 'tabindex="0"'
    assert_includes output, 'aria-disabled="true"'
  end

  def test_callers_aria_disabled_is_not_doubled
    output = phlex { RubyUI.Link(disabled: true, aria: {disabled: "true"}) { "A" } }

    assert_includes output, 'aria-disabled="true"'
  end

  def test_focusable_when_disabled_alone_does_nothing
    output = phlex { RubyUI.Link(href: "/docs", focusable_when_disabled: true) { "Docs" } }

    assert_includes output, 'href="/docs"'
    refute_includes output, "tabindex"
  end
end
