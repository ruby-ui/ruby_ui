# frozen_string_literal: true

require "test_helper"

class RubyUI::ShortcutKeyTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.ShortcutKey do |shortcut|
        shortcut.span(class: "text-xs") { "⌘" }
        shortcut.plain "K"
      end
    end

    assert_match(/K/, output)
  end
end
