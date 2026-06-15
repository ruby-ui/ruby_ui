# frozen_string_literal: true

require "test_helper"

class RubyUI::DropdownMenuItemTest < ComponentTest
  def test_renders_as_anchor_by_default
    output = phlex { RubyUI.DropdownMenuItem(href: "/edit") { "Edit" } }

    assert_match(/\A<a/, output)
    assert_match(/href="\/edit"/, output)
    assert_match(/role="menuitem"/, output)
    assert_match(/Edit/, output)
  end

  def test_renders_as_div_when_as_div_keeping_role_and_dropping_href
    output = phlex { RubyUI.DropdownMenuItem(as: :div) { "Delete" } }

    assert_match(/\A<div/, output)
    assert_match(/role="menuitem"/, output)
    assert_match(/Delete/, output)
    refute_match(/<a[\s>]/, output)
    refute_match(/href=/, output)
  end

  def test_unexpected_as_value_still_renders_an_anchor_with_href
    output = phlex { RubyUI.DropdownMenuItem(as: :anchor, href: "/edit") { "Edit" } }

    assert_match(/\A<a/, output)
    assert_match(/href="\/edit"/, output)
  end
end
