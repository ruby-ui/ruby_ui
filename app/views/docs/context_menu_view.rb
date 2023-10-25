# frozen_string_literal: true

class Docs::ContextMenuView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-8") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Context Menu" }
        render Typography::P.new { "Displays a menu to the user — such as a set of actions or functions — triggered by a right click." }
      end

      render Docs::VisualCodeExample.new(title: "Default") do
        render ContextMenu.new do
          render ContextMenuTrigger.new(class: 'flex h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm') { "Right click here" }
          context_menu_content
        end
      end

      render Docs::VisualCodeExample.new(title: "Placement right") do
        div(class: 'space-y-4') do
          render ContextMenu.new(options: { placement: 'right' }) do
            render ContextMenuTrigger.new(class: 'flex flex-col items-center gap-y-2 h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm') do
              plain "Right click here"
              render Badge.new(variant: :secondary) { "right" }
            end
            context_menu_content
          end
          render ContextMenu.new(options: { placement: 'left' }) do
            render ContextMenuTrigger.new(class: 'flex flex-col items-center gap-y-2 h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm') do
              plain "Right click here"
              render Badge.new(variant: :secondary) { "left" }
            end
            context_menu_content
          end
        end
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end

  def context_menu_content
    render ContextMenuContent.new(class: 'w-64') do
      # render ContextMenuLabel.new { "My Account" }
      render ContextMenuItem.new(href: '#', shortcut: "⌘[") do
        plain "Back"
      end
      render ContextMenuItem.new(href: '#', shortcut: "⌘]", disabled: true) do
        plain "Forward"
      end
      render ContextMenuItem.new(href: '#', shortcut: "⌘R") do
        plain "Reload"
      end
      render ContextMenuSeparator.new
      render ContextMenuItem.new(href: '#', shortcut: "⌘⇧B", checked: true) do
        plain "Show Bookmarks Bar"
      end
      render ContextMenuItem.new(href: '#') do
        plain "Show Full URLs"
      end
      render ContextMenuSeparator.new
      render ContextMenuLabel.new(inset: true) { "More Tools" }
      render ContextMenuSeparator.new
      render ContextMenuItem.new(href: '#') do
        plain "Developer Tools"
      end
      render ContextMenuItem.new(href: '#') do
        plain "Task Manager"
      end
      render ContextMenuItem.new(href: '#') do
        plain "Extensions"
      end
    end
  end
end
