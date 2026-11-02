# frozen_string_literal: true

class Views::Docs::ContextMenu < Views::Base
  def view_template
    component = "ContextMenu"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Context Menu", description: "Displays a menu to the user — such as a set of actions or functions — triggered by a right click.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Basic", description: "Right click (or press the ContextMenu key) on the trigger: the menu opens at the pointer and takes focus. Arrow keys, Home/End and typing a letter move through the items; Enter or Space picks one, Esc closes. While it is open the page behind is inert and doesn't scroll.", context: self) do
        <<~RUBY
          ContextMenu do
            ContextMenuTrigger(class: "flex h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm") { "Right click here" }
            ContextMenuContent do
              ContextMenuGroup do
                ContextMenuItem { "Back" }
                ContextMenuItem(disabled: true) { "Forward" }
                ContextMenuItem { "Reload" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With shortcuts", description: "ContextMenuShortcut shows the key combination; shortcut: on ContextMenuItem is a shorthand for it. It only displays the keys: binding them is up to you.", context: self) do
        <<~RUBY
          ContextMenu do
            ContextMenuTrigger(class: "flex h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm") { "Right click here" }
            ContextMenuContent(class: "w-64") do
              ContextMenuGroup do
                ContextMenuItem do
                  plain "Back"
                  ContextMenuShortcut { "⌘[" }
                end
                ContextMenuItem(shortcut: "⌘]", disabled: true) { "Forward" }
                ContextMenuItem(shortcut: "⌘R") { "Reload" }
              end
              ContextMenuSeparator()
              ContextMenuGroup do
                ContextMenuItem(shortcut: "⌘S") { "Save Page As…" }
                ContextMenuItem(shortcut: "⇧⌘I") { "Developer Tools" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With groups", description: "ContextMenuGroup groups items; a ContextMenuLabel inside it names the group for assistive tech.", context: self) do
        <<~RUBY
          ContextMenu do
            ContextMenuTrigger(class: "flex h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm") { "Right click here" }
            ContextMenuContent(class: "w-48") do
              ContextMenuGroup do
                ContextMenuLabel { "File" }
                ContextMenuItem { "New File" }
                ContextMenuItem { "Open File" }
              end
              ContextMenuSeparator()
              ContextMenuGroup do
                ContextMenuLabel { "Edit" }
                ContextMenuItem { "Undo" }
                ContextMenuItem { "Redo" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Links", description: "Items render as divs; href: turns one into a link that navigates when picked.", context: self) do
        <<~RUBY
          ContextMenu do
            ContextMenuTrigger(class: "flex h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm") { "Right click here" }
            ContextMenuContent do
              ContextMenuItem(href: "#links") { "Copy link" }
              ContextMenuItem(href: "#links") { "Open in new tab" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Checkboxes", description: "ContextMenuCheckboxItem toggles aria-checked and keeps the menu open. Listen to ruby-ui--context-menu:change; event.detail.checked has the new state.", context: self) do
        <<~RUBY
          ContextMenu do
            ContextMenuTrigger(class: "flex h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm") { "Right click here" }
            ContextMenuContent(class: "w-64") do
              ContextMenuCheckboxItem(checked: true) { "Show Bookmarks Bar" }
              ContextMenuCheckboxItem { "Show Full URLs" }
              ContextMenuCheckboxItem(shortcut: "⌘⇧D") { "Show Developer Tools" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Radio group", description: "ContextMenuRadioItems in a ContextMenuRadioGroup: checking one unchecks the rest. event.detail.value of ruby-ui--context-menu:change carries the value:.", context: self) do
        <<~RUBY
          ContextMenu do
            ContextMenuTrigger(class: "flex h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm") { "Right click here" }
            ContextMenuContent(class: "w-48") do
              ContextMenuRadioGroup do
                ContextMenuLabel(inset: true) { "People" }
                ContextMenuRadioItem(value: "pedro", checked: true) { "Pedro Duarte" }
                ContextMenuRadioItem(value: "colm") { "Colm Tuite" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Destructive", description: "variant: :destructive marks an item that deletes or can't be undone.", context: self) do
        <<~RUBY
          ContextMenu do
            ContextMenuTrigger(class: "flex h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm") { "Right click here" }
            ContextMenuContent do
              ContextMenuGroup do
                ContextMenuItem { "Edit" }
                ContextMenuItem { "Share" }
              end
              ContextMenuSeparator()
              ContextMenuGroup do
                ContextMenuItem(variant: :destructive) { "Delete" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Inset", description: "inset: indents an item or label (pl-8), e.g. to line it up with items that start with an icon.", context: self) do
        <<~RUBY
          ContextMenu do
            ContextMenuTrigger(class: "flex h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm") { "Right click here" }
            ContextMenuContent(class: "w-52") do
              ContextMenuGroup do
                ContextMenuItem(inset: true) { "Copy" }
                ContextMenuItem(inset: true) { "Cut" }
              end
              ContextMenuSeparator()
              ContextMenuCheckboxItem(checked: true) { "Show Bookmarks Bar" }
              ContextMenuSeparator()
              ContextMenuGroup do
                ContextMenuLabel(inset: true) { "More Tools" }
                ContextMenuItem(inset: true) { "Developer Tools" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Side", description: "side: (top, right, bottom, left) and align: (start, center, end) place the menu relative to the pointer; side_offset: and align_offset: set the gap. The defaults are right, start, 0 and 4.", context: self) do
        <<~RUBY
          div(class: "grid gap-4 sm:grid-cols-2") do
            ContextMenu do
              ContextMenuTrigger(class: "flex h-[100px] items-center justify-center rounded-md border border-dashed text-sm") { "Right click (top)" }
              ContextMenuContent(side: :top) do
                ContextMenuItem { "Back" }
                ContextMenuItem { "Forward" }
                ContextMenuItem { "Reload" }
              end
            end
            ContextMenu do
              ContextMenuTrigger(class: "flex h-[100px] items-center justify-center rounded-md border border-dashed text-sm") { "Right click (right)" }
              ContextMenuContent(side: :right) do
                ContextMenuItem { "Back" }
                ContextMenuItem { "Forward" }
                ContextMenuItem { "Reload" }
              end
            end
            ContextMenu do
              ContextMenuTrigger(class: "flex h-[100px] items-center justify-center rounded-md border border-dashed text-sm") { "Right click (bottom)" }
              ContextMenuContent(side: :bottom) do
                ContextMenuItem { "Back" }
                ContextMenuItem { "Forward" }
                ContextMenuItem { "Reload" }
              end
            end
            ContextMenu do
              ContextMenuTrigger(class: "flex h-[100px] items-center justify-center rounded-md border border-dashed text-sm") { "Right click (left)" }
              ContextMenuContent(side: :left) do
                ContextMenuItem { "Back" }
                ContextMenuItem { "Forward" }
                ContextMenuItem { "Reload" }
              end
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
