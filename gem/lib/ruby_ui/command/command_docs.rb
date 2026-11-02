# frozen_string_literal: true

class Views::Docs::Command < Views::Base
  def view_template
    component = "Command"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: component, description: "Fast, composable command menu for Phlex.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Inline", description: "Command works on the page too. Typing filters the items, the first match is active, the arrow keys, Home and End move through them and Enter selects. CommandSeparator hides while searching.", context: self) do
        <<~RUBY
          div(class: "w-full max-w-md rounded-xl ring-1 ring-foreground/10") do
            Command do
              CommandInput(placeholder: "Type a command or search...")
              CommandList do
                CommandEmpty { "No results found." }
                CommandGroup(title: "Suggestions") do
                  CommandItem(value: "Calendar") do
                    svg(xmlns: "http://www.w3.org/2000/svg", viewbox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true") do |s|
                      s.path(d: "M8 2v4"); s.path(d: "M16 2v4"); s.rect(width: "18", height: "18", x: "3", y: "4", rx: "2"); s.path(d: "M3 10h18")
                    end
                    span { "Calendar" }
                  end
                  CommandItem(value: "Search Emoji") do
                    svg(xmlns: "http://www.w3.org/2000/svg", viewbox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true") do |s|
                      s.circle(cx: "12", cy: "12", r: "10"); s.path(d: "M8 14s1.5 2 4 2 4-2 4-2"); s.line(x1: "9", x2: "9.01", y1: "9", y2: "9"); s.line(x1: "15", x2: "15.01", y1: "9", y2: "9")
                    end
                    span { "Search Emoji" }
                  end
                  CommandItem(value: "Calculator", disabled: true) do
                    svg(xmlns: "http://www.w3.org/2000/svg", viewbox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true") do |s|
                      s.rect(width: "16", height: "20", x: "4", y: "2", rx: "2"); s.line(x1: "8", x2: "16", y1: "6", y2: "6"); s.path(d: "M16 14v4"); s.path(d: "M8 10h.01"); s.path(d: "M12 10h.01"); s.path(d: "M16 10h.01"); s.path(d: "M8 14h.01"); s.path(d: "M12 14h.01"); s.path(d: "M8 18h.01"); s.path(d: "M12 18h.01")
                    end
                    span { "Calculator" }
                  end
                end
                CommandSeparator()
                CommandGroup(title: "Settings") do
                  CommandItem(value: "Profile") do
                    span { "Profile" }
                    CommandShortcut { "⌘P" }
                  end
                  CommandItem(value: "Billing") do
                    span { "Billing" }
                    CommandShortcut { "⌘B" }
                  end
                  CommandItem(value: "Settings") do
                    span { "Settings" }
                    CommandShortcut { "⌘S" }
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Dialog", description: "CommandDialog opens the Command in a modal dialog from its trigger, and with ⌘K / Ctrl+K by default. This site's search already takes ⌘K, so the example turns the shortcut off with keybindings: []. title: and description: name the dialog for screen readers (they are visually hidden); show_close_button: adds a close button.", context: self) do
        <<~RUBY
          CommandDialog do
            CommandDialogTrigger(keybindings: []) do
              Button(variant: :outline) { "Open Menu" }
            end
            CommandDialogContent do
              Command do
                CommandInput(placeholder: "Type a command or search...")
                CommandList do
                  CommandEmpty { "No results found." }
                  CommandGroup(title: "Suggestions") do
                    CommandItem { "Calendar" }
                    CommandItem { "Search Emoji" }
                    CommandItem { "Calculator" }
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With shortcuts", description: "CommandShortcut shows a keyboard hint at the end of an item.", context: self) do
        <<~RUBY
          CommandDialog do
            CommandDialogTrigger(keybindings: ["keydown.ctrl+j@window", "keydown.meta+j@window"]) do
              Button(variant: :outline) { "Open Menu (⌘J)" }
            end
            CommandDialogContent do
              Command do
                CommandInput(placeholder: "Type a command or search...")
                CommandList do
                  CommandEmpty { "No results found." }
                  CommandGroup(title: "Settings") do
                    CommandItem(value: "Profile") do
                      span { "Profile" }
                      CommandShortcut { "⌘P" }
                    end
                    CommandItem(value: "Billing") do
                      span { "Billing" }
                      CommandShortcut { "⌘B" }
                    end
                    CommandItem(value: "Settings") do
                      span { "Settings" }
                      CommandShortcut { "⌘S" }
                    end
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Navigation", description: "An item with href: visits that page when selected (Turbo.visit when Turbo is loaded; ⌘/Ctrl opens a new tab). keywords: adds search terms beyond the value.", context: self) do
        <<~RUBY
          CommandDialog(title: "Search documentation", description: "Find a page in the docs") do
            CommandDialogTrigger(keybindings: []) do
              Button(variant: :outline) { "Search docs" }
            end
            CommandDialogContent do
              Command do
                CommandInput(placeholder: "Search documentation...")
                CommandList do
                  CommandEmpty { "No results found." }
                  CommandGroup(title: "Components") do
                    CommandItem(value: "Accordion", href: docs_accordion_path) { "Accordion" }
                    CommandItem(value: "Alert", href: docs_alert_path) { "Alert" }
                    CommandItem(value: "Alert Dialog", href: docs_alert_dialog_path, keywords: ["confirm", "modal"]) { "Alert Dialog" }
                    CommandItem(value: "Badge", href: docs_badge_path) { "Badge" }
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Handling selection", description: "Selecting an item dispatches a cancelable ruby-ui--command:select event with the item's value and href in its detail. Listen to it from your own Stimulus controller; call preventDefault() to skip the href visit.", context: self) do
        <<~RUBY
          div(class: "w-full max-w-md rounded-xl ring-1 ring-foreground/10") do
            Command(loop: true, data: {action: "ruby-ui--command:select->my-palette#run"}) do
              CommandInput(placeholder: "Run an action...")
              CommandList do
                CommandEmpty { "No results found." }
                CommandGroup(title: "Actions") do
                  CommandItem(value: "new-file") { "New file" }
                  CommandItem(value: "new-folder") { "New folder" }
                  CommandItem(value: "rename") { "Rename" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Scrollable", description: "CommandList scrolls past 18rem; the active item stays in view.", context: self) do
        <<~RUBY
          CommandDialog do
            CommandDialogTrigger(keybindings: []) do
              Button(variant: :outline) { "Open Menu" }
            end
            CommandDialogContent do
              Command do
                CommandInput(placeholder: "Type a command or search...")
                CommandList do
                  CommandEmpty { "No results found." }
                  CommandGroup(title: "Navigation") do
                    %w[Home Inbox Documents Downloads Desktop Pictures Music Videos].each { |name| CommandItem { name } }
                  end
                  CommandSeparator()
                  CommandGroup(title: "Tools") do
                    %w[Calculator Calendar Clock Notes Terminal Weather].each { |name| CommandItem { name } }
                  end
                  CommandSeparator()
                  CommandGroup(title: "Settings") do
                    %w[Profile Billing Notifications Privacy Appearance Language].each { |name| CommandItem { name } }
                  end
                end
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
