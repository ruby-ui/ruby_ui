# frozen_string_literal: true

require "test_helper"

class RubyUI::ButtonTest < ComponentTest
  def test_default_is_a_vega_button
    output = phlex { RubyUI.Button { "Save" } }

    assert_match(/\A<button /, output)
    assert_includes output, 'type="button"'
    assert_includes output, 'data-slot="button"'
    assert_includes output, "bg-primary text-primary-foreground hover:bg-primary/80"
    assert_includes output, "border border-transparent bg-clip-padding"
    assert_includes output, "h-9 gap-1.5 px-2.5"
    assert_includes output, "focus-visible:ring-3 focus-visible:ring-ring/50"
    assert_includes output, "active:not-aria-[haspopup]:translate-y-px"
    refute_includes output, "shadow"
  end

  def test_default_is_an_alias_of_primary
    assert_equal phlex { RubyUI.Button(variant: :primary) { "A" } },
      phlex { RubyUI.Button(variant: :default, size: :default) { "A" } }
  end

  def test_unknown_variant_and_size_fall_back_to_defaults
    assert_equal phlex { RubyUI.Button { "A" } },
      phlex { RubyUI.Button(variant: :nope, size: :huge) { "A" } }
  end

  def test_destructive_is_soft
    output = phlex { RubyUI.Button(variant: :destructive) { "Delete" } }

    assert_includes output, "bg-destructive/10 text-destructive hover:bg-destructive/20"
    refute_includes output, "text-white"
  end

  def test_outline_uses_input_tint_in_dark_mode
    output = phlex { RubyUI.Button(variant: :outline) { "Outline" } }

    assert_includes output, "shadow-xs"
    assert_includes output, "dark:bg-input/30"
    assert_includes output, "aria-expanded:bg-muted"
  end

  def test_secondary_has_a_hover
    output = phlex { RubyUI.Button(variant: :secondary) { "Secondary" } }

    assert_includes output, "hover:bg-[color-mix(in_oklch,var(--secondary),var(--foreground)_5%)]"
  end

  def test_every_size_uses_text_sm_except_xs
    %i[sm md lg xl].each do |size|
      output = phlex { RubyUI.Button(size: size) { "A" } }
      refute_match(/\btext-(xs|base)\b/, output, "size #{size}")
    end
    assert_includes phlex { RubyUI.Button(size: :xs) { "A" } }, "h-6 gap-1"
  end

  def test_icon_sizes_follow_shadcn
    {xs: "h-6 w-6", sm: "h-8 w-8", md: "h-9 w-9", lg: "h-10 w-10"}.each do |size, classes|
      assert_includes phlex { RubyUI.Button(icon: true, size: size) { "A" } }, classes, "icon #{size}"
    end
  end

  def test_shadcn_icon_size_names
    assert_equal phlex { RubyUI.Button(icon: true) { "A" } }, phlex { RubyUI.Button(size: :icon) { "A" } }
    assert_equal phlex { RubyUI.Button(icon: true, size: :sm) { "A" } }, phlex { RubyUI.Button(size: "icon-sm") { "A" } }
  end

  def test_disabled
    output = phlex { RubyUI.Button(disabled: true) { "A" } }

    assert_match(/<button [^>]*\bdisabled\b/, output)
    assert_includes output, "data-disabled"
    refute_includes output, "aria-disabled=\""
  end

  def test_focusable_when_disabled_uses_aria_disabled_and_blocks_clicks
    output = phlex { RubyUI.Button(disabled: true, focusable_when_disabled: true, data: {action: "click->x#go"}) { "A" } }

    refute_match(/<button [^>]*\sdisabled[\s>]/, output)
    assert_includes output, 'aria-disabled="true"'
    assert_includes output, "data-disabled"
    assert_includes output, 'data-controller="ruby-ui--button"'
    # The controller blocks clicks with a capture listener, so the caller's
    # action stays untouched.
    assert_includes output, 'data-action="click->x#go"'
  end

  def test_focusable_when_disabled_keeps_a_single_aria_disabled_value
    output = phlex { RubyUI.Button(disabled: true, focusable_when_disabled: true, aria: {disabled: "true"}) { "A" } }

    assert_includes output, 'aria-disabled="true"'
  end

  def test_caller_aria_disabled_is_left_alone_when_not_disabled_by_button
    output = phlex { RubyUI.Button(aria: {disabled: "false"}) { "A" } }

    assert_includes output, 'aria-disabled="false"'
  end

  def test_focusable_disabled_link_stays_in_tab_order
    output = phlex { RubyUI.Button(href: "/docs", disabled: true, focusable_when_disabled: true) { "Docs" } }

    assert_includes output, 'role="link"'
    assert_includes output, 'tabindex="0"'
    assert_includes output, 'data-controller="ruby-ui--button"'
    refute_includes output, "href="
  end

  def test_focusable_when_disabled_does_nothing_while_enabled
    output = phlex { RubyUI.Button(focusable_when_disabled: true) { "A" } }

    refute_includes output, "ruby-ui--button"
    refute_match(/\s(data-)?disabled[\s>=]/, output)
  end

  def test_href_renders_a_link
    output = phlex { RubyUI.Button(href: "/docs", variant: :outline) { "Docs" } }

    assert_match(/\A<a /, output)
    assert_includes output, 'href="/docs"'
    assert_includes output, 'data-slot="button"'
    refute_includes output, "type="
  end

  def test_disabled_link_drops_href
    output = phlex { RubyUI.Button(href: "/docs", disabled: true) { "Docs" } }

    refute_includes output, "href="
    assert_includes output, 'aria-disabled="true"'
    assert_includes output, 'role="link"'
    refute_includes output, "tabindex"
    refute_includes output, "ruby-ui--button"
  end

  def test_caller_classes_win
    output = phlex { RubyUI.Button(size: :icon, class: "h-8 w-8") { "A" } }

    assert_includes output, "h-8 w-8"
    refute_includes output, "h-9"
  end
end
