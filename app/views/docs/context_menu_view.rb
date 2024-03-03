# frozen_string_literal: true

class Docs::ContextMenuView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Context Menu", description: "Displays a menu to the user — such as a set of actions or functions — triggered by a right click.")

      render PhlexUI::Typography::H2.new { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          render PhlexUI::ContextMenu.new do
            render PhlexUI::ContextMenu::Trigger.new(class: 'flex h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm') { "Right click here" }
            render PhlexUI::ContextMenu::Content.new(class: 'w-64') do
              render PhlexUI::ContextMenu::Item.new(href: '#', shortcut: "⌘[") { "Back" }
              render PhlexUI::ContextMenu::Item.new(href: '#', shortcut: "⌘]", disabled: true) { "Forward" }
              render PhlexUI::ContextMenu::Item.new(href: '#', shortcut: "⌘R") { "Reload" }
              render PhlexUI::ContextMenu::Separator.new
              render PhlexUI::ContextMenu::Item.new(href: '#', shortcut: "⌘⇧B", checked: true) { "Show Bookmarks Bar" }
              render PhlexUI::ContextMenu::Item.new(href: '#') { "Show Full URLs" }
              render PhlexUI::ContextMenu::Separator.new
              render PhlexUI::ContextMenu::Label.new(inset: true) { "More Tools" }
              render PhlexUI::ContextMenu::Separator.new
              render PhlexUI::ContextMenu::Item.new(href: '#') { "Developer Tools" }
              render PhlexUI::ContextMenu::Item.new(href: '#') { "Task Manager" }
              render PhlexUI::ContextMenu::Item.new(href: '#') { "Extensions" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Placement", context: self) do
        <<~RUBY
          div(class: 'space-y-4') do
            render PhlexUI::ContextMenu.new(options: { placement: 'right' }) do
              render PhlexUI::ContextMenu::Trigger.new(class: 'flex flex-col items-center gap-y-2 h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm') do
                plain "Right click here"
                render PhlexUI::Badge.new(variant: :primary) { "right" }
              end
              render PhlexUI::ContextMenu::Content.new(class: 'w-64') do
                render PhlexUI::ContextMenu::Item.new(href: '#', shortcut: "⌘[") { "Back" }
                render PhlexUI::ContextMenu::Item.new(href: '#', shortcut: "⌘]", disabled: true) { "Forward" }
                render PhlexUI::ContextMenu::Item.new(href: '#', shortcut: "⌘R") { "Reload" }
                render PhlexUI::ContextMenu::Separator.new
                render PhlexUI::ContextMenu::Item.new(href: '#', shortcut: "⌘⇧B", checked: true) { "Show Bookmarks Bar" }
                render PhlexUI::ContextMenu::Item.new(href: '#') { "Show Full URLs" }
                render PhlexUI::ContextMenu::Separator.new
                render PhlexUI::ContextMenu::Label.new(inset: true) { "More Tools" }
                render PhlexUI::ContextMenu::Separator.new
                render PhlexUI::ContextMenu::Item.new(href: '#') { "Developer Tools" }
                render PhlexUI::ContextMenu::Item.new(href: '#') { "Task Manager" }
                render PhlexUI::ContextMenu::Item.new(href: '#') { "Extensions" }
              end
            end
            render PhlexUI::ContextMenu.new(options: { placement: 'left' }) do
              render PhlexUI::ContextMenu::Trigger.new(class: 'flex flex-col items-center gap-y-2 h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm') do
                plain "Right click here"
                render PhlexUI::Badge.new(variant: :primary) { "left" }
              end
              render PhlexUI::ContextMenu::Content.new(class: 'w-64') do
                render PhlexUI::ContextMenu::Item.new(href: '#', shortcut: "⌘[") { "Back" }
                render PhlexUI::ContextMenu::Item.new(href: '#', shortcut: "⌘]", disabled: true) { "Forward" }
                render PhlexUI::ContextMenu::Item.new(href: '#', shortcut: "⌘R") { "Reload" }
                render PhlexUI::ContextMenu::Separator.new
                render PhlexUI::ContextMenu::Item.new(href: '#', shortcut: "⌘⇧B", checked: true) { "Show Bookmarks Bar" }
                render PhlexUI::ContextMenu::Item.new(href: '#') { "Show Full URLs" }
                render PhlexUI::ContextMenu::Separator.new
                render PhlexUI::ContextMenu::Label.new(inset: true) { "More Tools" }
                render PhlexUI::ContextMenu::Separator.new
                render PhlexUI::ContextMenu::Item.new(href: '#') { "Developer Tools" }
                render PhlexUI::ContextMenu::Item.new(href: '#') { "Task Manager" }
                render PhlexUI::ContextMenu::Item.new(href: '#') { "Extensions" }
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
      Docs::ComponentStruct.new(name: "PhlexUI::ContextMenu", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/context_menu.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::ContextMenu::Trigger", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/context_menu/trigger.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::ContextMenu::Content", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/context_menu/content.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::ContextMenu::Item", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/context_menu/item.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::ContextMenu::Separator", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/context_menu/separator.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::ContextMenu::Label", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/context_menu/label.rb", built_using: :phlex)
    ]
  end
end
