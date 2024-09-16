# frozen_string_literal: true

module RBUI
  class ContextMenuPreview < Lookbook::Preview
    # Default ContextMenu
    # ---------------
    def default
      render(TestView.new) do
        ContextMenu do
          ContextMenuTrigger(class: "flex h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm") { "Right click here" }
          ContextMenuContent(class: "w-64") do
            ContextMenuItem(href: "#", shortcut: "⌘[") { "Back" }
            ContextMenuItem(href: "#", shortcut: "⌘]", disabled: true) { "Forward" }
            ContextMenuItem(href: "#", shortcut: "⌘R") { "Reload" }
            ContextMenuSeparator()
            ContextMenuItem(href: "#", shortcut: "⌘⇧B", checked: true) { "Show Bookmarks Bar" }
            ContextMenuItem(href: "#") { "Show Full URLs" }
            ContextMenuSeparator()
            ContextMenuLabel(inset: true) { "More Tools" }
            ContextMenuSeparator()
            ContextMenuItem(href: "#") { "Developer Tools" }
            ContextMenuItem(href: "#") { "Task Manager" }
            ContextMenuItem(href: "#") { "Extensions" }
          end
        end
      end
    end
  end
end
