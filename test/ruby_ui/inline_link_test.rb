# frozen_string_literal: true

require "test_helper"

class RubyUI::InlineLinkTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::InlineLink.new(href: "#").is_a?(Phlex::HTML)
  end

  def test_href_in_attrs
    il = RubyUI::InlineLink.new(href: "/about")
    assert_equal "/about", il.attrs[:href]
  end

  def test_default_class
    il = RubyUI::InlineLink.new(href: "#")
    assert_includes il.attrs[:class], "text-primary"
    assert_includes il.attrs[:class], "font-medium"
    assert_includes il.attrs[:class], "hover:underline"
    assert_includes il.attrs[:class], "underline-offset-4"
  end

  def test_user_class_merges
    il = RubyUI::InlineLink.new(href: "#", class: "extra")
    assert_includes il.attrs[:class], "extra"
    assert_includes il.attrs[:class], "text-primary"
  end
end
