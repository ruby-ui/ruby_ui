# frozen_string_literal: true

require "test_helper"

class RubyUI::ShortcutKeyTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::ShortcutKey.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    assert_includes RubyUI::ShortcutKey.new.attrs[:class], "pointer-events-none"
  end

  def test_user_class_merged
    sk = RubyUI::ShortcutKey.new(class: "custom")
    assert_includes sk.attrs[:class], "custom"
    assert_includes sk.attrs[:class], "pointer-events-none"
  end
end
