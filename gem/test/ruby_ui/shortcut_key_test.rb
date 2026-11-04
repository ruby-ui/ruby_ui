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

  def test_renders_kbd_with_vega_classes
    output = phlex { RubyUI.ShortcutKey { "Ctrl" } }

    assert_match(/\A<kbd data-slot="kbd"/, output)
    %w[h-5 w-fit min-w-5 justify-center rounded-sm px-1 font-sans text-xs bg-muted text-muted-foreground].each do |token|
      assert_includes output, token
    end
    refute_match(/\bborder\b|font-mono|text-\[10px\]/, output)
  end

  def test_merges_custom_class
    output = phlex { RubyUI.ShortcutKey(class: "px-2") { "K" } }

    assert_includes output, "px-2"
    refute_match(/\bpx-1\b/, output)
  end

  def test_group_wraps_keys_in_kbd
    output = phlex do
      RubyUI.ShortcutKeyGroup do
        RubyUI.ShortcutKey { "Ctrl" }
        RubyUI.ShortcutKey { "P" }
      end
    end

    assert_match(/\A<kbd data-slot="kbd-group" class="inline-flex items-center gap-1">/, output)
    assert_equal 3, output.scan("<kbd").size
  end
end
