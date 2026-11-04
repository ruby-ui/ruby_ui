# frozen_string_literal: true

class Views::Docs::ShortcutKey < Views::Base
  def view_template
    component = "ShortcutKey"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Shortcut Key", description: "Displays a keyboard key or shortcut.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          div(class: "flex items-center justify-center gap-2") do
            ShortcutKey { "Ctrl" }
            ShortcutKey { "⌘K" }
            ShortcutKey { "Ctrl + B" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Modifier Keys", context: self) do
        <<~RUBY
          div(class: "flex items-center justify-center gap-2") do
            ShortcutKey { "⌘" }
            ShortcutKey { "C" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Group", description: "Wrap the keys of a combination in ShortcutKeyGroup.", context: self) do
        <<~RUBY
          div(class: "flex justify-center") do
            ShortcutKeyGroup do
              ShortcutKey { "Ctrl" }
              ShortcutKey { "Shift" }
              ShortcutKey { "P" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Arrow Keys", context: self) do
        <<~RUBY
          div(class: "flex items-center justify-center gap-2") do
            ShortcutKey { "↑" }
            ShortcutKey { "↓" }
            ShortcutKey { "←" }
            ShortcutKey { "→" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "In Text", context: self) do
        <<~RUBY
          p(class: "text-muted-foreground text-sm text-center") do
            plain "Press "
            ShortcutKeyGroup do
              ShortcutKey { "⌘" }
              ShortcutKey { "K" }
            end
            plain " to open the command menu."
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
