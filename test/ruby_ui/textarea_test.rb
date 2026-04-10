# frozen_string_literal: true

require "test_helper"

class RubyUI::TextareaTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Textarea.new.is_a?(Phlex::HTML)
  end

  def test_default_rows
    assert_equal 4, RubyUI::Textarea.new.attrs[:rows]
  end

  def test_custom_rows
    assert_equal 8, RubyUI::Textarea.new(rows: 8).attrs[:rows]
  end

  def test_has_default_class
    assert_includes RubyUI::Textarea.new.attrs[:class], "rounded-md"
  end

  def test_user_class_merged
    ta = RubyUI::Textarea.new(class: "mt-4")
    assert_includes ta.attrs[:class], "mt-4"
    assert_includes ta.attrs[:class], "rounded-md"
  end
end
