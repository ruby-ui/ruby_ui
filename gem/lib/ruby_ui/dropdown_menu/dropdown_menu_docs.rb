# frozen_string_literal: true

class Views::Docs::DropdownMenu < Views::Base
  def view_template
    component = "DropdownMenu"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Dropdown Menu", description: "Displays a menu to the user — such as a set of actions or functions — triggered by a button.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Basic", description: "Click the button, or focus it and press Enter, Space, ArrowDown or ArrowUp: the menu opens and takes focus. Arrow keys, Home/End and typing a letter move through the items; Enter or Space picks one; Esc closes it and focus goes back to the button; Tab closes it and moves on to the next control, Shift+Tab stops on the button. While it is open the page behind is inert and doesn't scroll.", context: self) do
        <<~RUBY
          DropdownMenu do
            DropdownMenuTrigger do
              Button(variant: :outline) { "Open" }
            end
            DropdownMenuContent do
              DropdownMenuGroup do
                DropdownMenuLabel { "My Account" }
                DropdownMenuItem { "Profile" }
                DropdownMenuItem { "Billing" }
                DropdownMenuItem { "Settings" }
              end
              DropdownMenuSeparator()
              DropdownMenuItem { "GitHub" }
              DropdownMenuItem { "Support" }
              DropdownMenuItem(disabled: true) { "API" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With shortcuts", description: "DropdownMenuShortcut shows the key combination. It only displays the keys: binding them is up to you.", context: self) do
        <<~RUBY
          DropdownMenu do
            DropdownMenuTrigger do
              Button(variant: :outline) { "Open" }
            end
            DropdownMenuContent(class: "w-56") do
              DropdownMenuGroup do
                DropdownMenuLabel { "My Account" }
                DropdownMenuItem do
                  plain "Profile"
                  DropdownMenuShortcut { "⇧⌘P" }
                end
                DropdownMenuItem do
                  plain "Billing"
                  DropdownMenuShortcut { "⌘B" }
                end
                DropdownMenuItem do
                  plain "Settings"
                  DropdownMenuShortcut { "⌘S" }
                end
              end
              DropdownMenuSeparator()
              DropdownMenuItem do
                plain "Log out"
                DropdownMenuShortcut { "⇧⌘Q" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Submenu", description: "DropdownMenuSub pairs a DropdownMenuSubTrigger with its DropdownMenuSubContent. The submenu opens on hover, click, Enter, Space or ArrowRight; ArrowLeft or Esc closes it and goes back to its trigger.", context: self) do
        <<~RUBY
          DropdownMenu do
            DropdownMenuTrigger do
              Button(variant: :outline) { "Open" }
            end
            DropdownMenuContent do
              DropdownMenuGroup do
                DropdownMenuItem { "Team" }
                DropdownMenuSub do
                  DropdownMenuSubTrigger { "Invite users" }
                  DropdownMenuSubContent do
                    DropdownMenuItem { "Email" }
                    DropdownMenuItem { "Message" }
                    DropdownMenuSeparator()
                    DropdownMenuItem { "More..." }
                  end
                end
                DropdownMenuItem { "New Team" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Checkboxes", description: "DropdownMenuCheckboxItem toggles aria-checked and keeps the menu open. Listen to ruby-ui--dropdown-menu:change; event.detail.checked has the new state.", context: self) do
        <<~RUBY
          DropdownMenu do
            DropdownMenuTrigger do
              Button(variant: :outline) { "Open" }
            end
            DropdownMenuContent(class: "w-40") do
              DropdownMenuGroup do
                DropdownMenuLabel { "Appearance" }
                DropdownMenuCheckboxItem(checked: true) { "Status Bar" }
                DropdownMenuCheckboxItem(disabled: true) { "Activity Bar" }
                DropdownMenuCheckboxItem { "Panel" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Radio group", description: "DropdownMenuRadioItems in a DropdownMenuRadioGroup: checking one unchecks the rest. In ruby-ui--dropdown-menu:change, event.detail.value carries the item's value: argument.", context: self) do
        <<~RUBY
          DropdownMenu do
            DropdownMenuTrigger do
              Button(variant: :outline) { "Open" }
            end
            DropdownMenuContent(class: "w-32") do
              DropdownMenuRadioGroup do
                DropdownMenuLabel { "Panel Position" }
                DropdownMenuRadioItem(value: "top") { "Top" }
                DropdownMenuRadioItem(value: "bottom", checked: true) { "Bottom" }
                DropdownMenuRadioItem(value: "right") { "Right" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Destructive", description: "variant: :destructive marks an item that deletes or can't be undone.", context: self) do
        <<~RUBY
          DropdownMenu do
            DropdownMenuTrigger do
              Button(variant: :outline) { "Actions" }
            end
            DropdownMenuContent do
              DropdownMenuGroup do
                DropdownMenuItem { "Edit" }
                DropdownMenuItem { "Share" }
              end
              DropdownMenuSeparator()
              DropdownMenuItem(variant: :destructive) { "Delete" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Inset", description: "inset: indents an item or label (pl-8), e.g. to line it up with items that show an indicator.", context: self) do
        <<~RUBY
          DropdownMenu do
            DropdownMenuTrigger do
              Button(variant: :outline) { "Open" }
            end
            DropdownMenuContent(class: "w-44") do
              DropdownMenuGroup do
                DropdownMenuLabel(inset: true) { "Edit" }
                DropdownMenuItem(inset: true) { "Copy" }
                DropdownMenuItem(inset: true) { "Cut" }
              end
              DropdownMenuSeparator()
              DropdownMenuCheckboxItem(checked: true) { "Word Wrap" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Links", description: "Items render as divs; href: turns one into a link that navigates when picked.", context: self) do
        <<~RUBY
          DropdownMenu do
            DropdownMenuTrigger do
              Button(variant: :outline) { "Open" }
            end
            DropdownMenuContent do
              DropdownMenuItem(href: "#links") { "Documentation" }
              DropdownMenuItem(href: "#links") { "Changelog" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Opening a dialog", description: "An item can host its own interactive element, such as a DialogTrigger. Picking it opens the dialog and closes the menu.", context: self) do
        <<~RUBY
          DropdownMenu do
            DropdownMenuTrigger do
              Button(variant: :outline) { "Open" }
            end
            DropdownMenuContent do
              DropdownMenuItem { "Edit" }
              DropdownMenuItem(variant: :destructive) do
                Dialog do
                  DialogTrigger(class: "w-full text-left") { "Delete" }
                  DialogContent do
                    DialogHeader do
                      DialogTitle { "Are you absolutely sure?" }
                      DialogDescription { "This action cannot be undone." }
                    end
                    DialogFooter do
                      Button(variant: :destructive, data: {action: "click->ruby-ui--dialog#dismiss"}) { "Delete" }
                    end
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Side and align", description: "side: (top, right, bottom, left) and align: (start, center, end) place the menu next to the button; side_offset: and align_offset: set the gap. The defaults are bottom, start, 4 and 0. The menu flips and shifts to stay on screen, and is as wide as the button (at least 8rem).", context: self) do
        <<~RUBY
          div(class: "grid grid-cols-2 gap-4 sm:grid-cols-4") do
            %i[top right bottom left].each do |side|
              DropdownMenu do
                DropdownMenuTrigger do
                  Button(variant: :outline, class: "w-full") { side.to_s }
                end
                DropdownMenuContent(side: side, align: :center) do
                  DropdownMenuItem { "Profile" }
                  DropdownMenuItem { "Billing" }
                  DropdownMenuItem { "Settings" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Non-modal", description: "modal: false leaves the page scrollable and usable while the menu is open; a click outside still closes it.", context: self) do
        <<~RUBY
          DropdownMenu(modal: false) do
            DropdownMenuTrigger do
              Button(variant: :outline) { "Open" }
            end
            DropdownMenuContent do
              DropdownMenuItem { "Profile" }
              DropdownMenuItem { "Billing" }
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
