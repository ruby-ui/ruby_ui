# frozen_string_literal: true

require "test_helper"

class RubyUI::InlineCodeTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::InlineCode.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    ic = RubyUI::InlineCode.new
    assert_includes ic.attrs[:class], "bg-muted"
    assert_includes ic.attrs[:class], "font-mono"
    assert_includes ic.attrs[:class], "text-sm"
    assert_includes ic.attrs[:class], "font-semibold"
    assert_includes ic.attrs[:class], "rounded"
  end

  def test_user_class_merges
    ic = RubyUI::InlineCode.new(class: "extra")
    assert_includes ic.attrs[:class], "extra"
    assert_includes ic.attrs[:class], "bg-muted"
  end
end
