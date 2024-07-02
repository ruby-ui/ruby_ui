# frozen_string_literal: true

class Docs::ContextMenuView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Context Menu", description: "Displays a menu to the user — such as a set of actions or functions — triggered by a right click.")

      TypographyH2 { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          ContextMenu do
            ContextMenuTrigger(class: 'flex h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm') { "Right click here" }
            ContextMenuContent(class: 'w-64') do
              ContextMenuItem(href: '#', shortcut: "⌘[") { "Back" }
              ContextMenuItem(href: '#', shortcut: "⌘]", disabled: true) { "Forward" }
              ContextMenuItem(href: '#', shortcut: "⌘R") { "Reload" }
              ContextMenuSeparator
              ContextMenuItem(href: '#', shortcut: "⌘⇧B", checked: true) { "Show Bookmarks Bar" }
              ContextMenuItem(href: '#') { "Show Full URLs" }
              ContextMenuSeparator
              ContextMenuLabel(inset: true) { "More Tools" }
              ContextMenuSeparator
              ContextMenuItem(href: '#') { "Developer Tools" }
              ContextMenuItem(href: '#') { "Task Manager" }
              ContextMenuItem(href: '#') { "Extensions" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Placement", context: self) do
        <<~RUBY
          div(class: 'space-y-4') do
            ContextMenu(options: { placement: 'right' }) do
              ContextMenuTrigger(class: 'flex flex-col items-center gap-y-2 h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm') do
                plain "Right click here"
                Badge(variant: :primary) { "right" }
              end
              ContextMenuContent(class: 'w-64') do
                ContextMenuItem(href: '#', shortcut: "⌘[") { "Back" }
                ContextMenuItem(href: '#', shortcut: "⌘]", disabled: true) { "Forward" }
                ContextMenuItem(href: '#', shortcut: "⌘R") { "Reload" }
                ContextMenuSeparator
                ContextMenuItem(href: '#', shortcut: "⌘⇧B", checked: true) { "Show Bookmarks Bar" }
                ContextMenuItem(href: '#') { "Show Full URLs" }
                ContextMenuSeparator
                ContextMenuLabel(inset: true) { "More Tools" }
                ContextMenuSeparator
                ContextMenuItem(href: '#') { "Developer Tools" }
                ContextMenuItem(href: '#') { "Task Manager" }
                ContextMenuItem(href: '#') { "Extensions" }
              end
            end
            ContextMenu(options: { placement: 'left' }) do
              ContextMenuTrigger(class: 'flex flex-col items-center gap-y-2 h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm') do
                plain "Right click here"
                Badge(variant: :primary) { "left" }
              end
              ContextMenuContent(class: 'w-64') do
                ContextMenuItem(href: '#', shortcut: "⌘[") { "Back" }
                ContextMenuItem(href: '#', shortcut: "⌘]", disabled: true) { "Forward" }
                ContextMenuItem(href: '#', shortcut: "⌘R") { "Reload" }
                ContextMenuSeparator
                ContextMenuItem(href: '#', shortcut: "⌘⇧B", checked: true) { "Show Bookmarks Bar" }
                ContextMenuItem(href: '#') { "Show Full URLs" }
                ContextMenuSeparator
                ContextMenuLabel(inset: true) { "More Tools" }
                ContextMenuSeparator
                ContextMenuItem(href: '#') { "Developer Tools" }
                ContextMenuItem(href: '#') { "Task Manager" }
                ContextMenuItem(href: '#') { "Extensions" }
              end
            end
          end
        RUBY
      end

      render Docs::ComponentsTable.new(components)
    end
  end

  private

  def components
    [
      Docs::ComponentStruct.new(name: "PopoverController", source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/popover_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "ContextMenu", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/context_menu.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "ContextMenuTrigger", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/context_menu/trigger.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "ContextMenuContent", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/context_menu/content.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "ContextMenuItem", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/context_menu/item.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "ContextMenuSeparator", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/context_menu/separator.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "ContextMenuLabel", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/context_menu/label.rb", built_using: :phlex)
    ]
  end
end
