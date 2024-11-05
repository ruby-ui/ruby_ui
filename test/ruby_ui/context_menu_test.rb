# frozen_string_literal: true

require "test_helper"

class RubyUI::ContextMenuTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_all_items
    output = phlex_context do
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
end
