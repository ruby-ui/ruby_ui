# frozen_string_literal: true

require "test_helper"

class RubyUI::DropdownMenuItemTest < ComponentTest
  def test_renders_as_div_by_default
    output = phlex { RubyUI.DropdownMenuItem { "Delete" } }

    assert_match(/\A<div/, output)
    assert_match(/role="menuitem"/, output)
    assert_match(/data-slot="dropdown-menu-item"/, output)
    refute_match(/href=/, output)
  end

  def test_renders_as_anchor_with_href
    output = phlex { RubyUI.DropdownMenuItem(href: "/edit") { "Edit" } }

    assert_match(/\A<a href="\/edit"/, output)
    assert_match(/role="menuitem"/, output)
  end

  def test_as_div_drops_href
    output = phlex { RubyUI.DropdownMenuItem(as: :div, href: "/edit") { "Delete" } }

    assert_match(/\A<div/, output)
    refute_match(/href=/, output)
  end

  def test_unexpected_as_value_still_renders_an_anchor_with_href
    output = phlex { RubyUI.DropdownMenuItem(as: :anchor, href: "/edit") { "Edit" } }

    assert_match(/\A<a/, output)
    assert_match(/href="\/edit"/, output)
  end

  def test_variant_inset_and_disabled
    output = phlex { RubyUI.DropdownMenuItem(variant: :destructive, inset: true, disabled: true) { "Delete" } }

    assert_match(/aria-disabled="true"/, output)
    assert_match(/data-variant="destructive"/, output)
    assert_match(/data-inset/, output)
    assert_match(/data-disabled/, output)
  end

  def test_unknown_variant_falls_back_to_default
    output = phlex { RubyUI.DropdownMenuItem(variant: :loud) { "Edit" } }

    assert_match(/data-variant="default"/, output)
  end

  def test_uses_vega_item_classes
    output = phlex { RubyUI.DropdownMenuItem { "Edit" } }

    %w[gap-2 cursor-default focus:bg-accent [&_svg]:shrink-0].each { |token| assert_includes output, token }
    refute_includes output, "cursor-pointer"
    refute_includes output, "aria-selected"
  end
end
