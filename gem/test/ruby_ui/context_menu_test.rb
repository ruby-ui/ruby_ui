# frozen_string_literal: true

require "test_helper"

class RubyUI::ContextMenuTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.ContextMenu do
        RubyUI.ContextMenuTrigger(class: "flex h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm") { "Right click here" }
        RubyUI.ContextMenuContent(class: "w-64") do
          RubyUI.ContextMenuItem(href: "#", shortcut: "⌘[") { "Back" }
          RubyUI.ContextMenuItem(href: "#", shortcut: "⌘]", disabled: true) { "Forward" }
          RubyUI.ContextMenuItem(href: "#", shortcut: "⌘R") { "Reload" }
          RubyUI.ContextMenuSeparator
          RubyUI.ContextMenuItem(href: "#", shortcut: "⌘⇧B", checked: true) { "Show Bookmarks Bar" }
          RubyUI.ContextMenuItem(href: "#") { "Show Full URLs" }
          RubyUI.ContextMenuSeparator
          RubyUI.ContextMenuLabel(inset: true) { "More Tools" }
          RubyUI.ContextMenuSeparator
          RubyUI.ContextMenuItem(href: "#") { "Developer Tools" }
          RubyUI.ContextMenuItem(href: "#") { "Task Manager" }
          RubyUI.ContextMenuItem(href: "#") { "Extensions" }
        end
      end
    end

    assert_match(/Right click here/, output)
  end

  # Floating UI positions a real element in the DOM (tippy used to clone a
  # <template>). Content must render as a hidden, absolutely-positioned div.
  def test_content_renders_hidden_positioned_div_not_template
    output = phlex do
      RubyUI.ContextMenuContent do
        RubyUI.ContextMenuItem(href: "#") { "Back" }
      end
    end

    refute_match(/<template/, output)
    assert_match(/hidden/, output)
    assert_match(/absolute/, output)
    assert_match(/Back/, output)
  end

  # `hidden` lands a frame after the animation ends; without a forwards fill mode that frame flashes.
  def test_content_holds_the_last_frame_of_the_exit_animation
    output = phlex do
      RubyUI.ContextMenuContent do
        RubyUI.ContextMenuItem(href: "#") { "Back" }
      end
    end

    assert_match(/data-\[state=closed\]:fill-mode-forwards/, output)
  end

  def test_context_menu_label_does_not_leak_a_hash_into_the_class_attribute
    output = phlex { RubyUI.ContextMenuLabel { "Label" } }

    refute_includes output, "inset?",
      "ContextMenuLabel serialized its conditional-class Hash into the class attribute"
  end

  def test_context_menu_label_applies_the_inset_class_only_when_inset
    inset = phlex { RubyUI.ContextMenuLabel(inset: true) { "Label" } }
    plain = phlex { RubyUI.ContextMenuLabel(inset: false) { "Label" } }

    assert_includes inset, "pl-8"
    refute_includes plain, "pl-8"
  end
end
