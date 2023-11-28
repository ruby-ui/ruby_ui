# frozen_string_literal: true

class Docs::ContextMenuView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Context Menu", description: "Displays a menu to the user — such as a set of actions or functions — triggered by a right click.")

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
                render PhlexUI::Badge.new(variant: :secondary) { "right" }
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
                render PhlexUI::Badge.new(variant: :secondary) { "left" }
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

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
