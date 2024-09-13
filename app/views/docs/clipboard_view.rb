# frozen_string_literal: true

class Docs::ClipboardView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Clipboard", description: "A control to allow you to copy content to the clipboard.")

      TypographyH2 { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          Clipboard(success: "Copied!", error: "Copy failed!", class: "relative", options: {placement: "top"}) do
            ClipboardSource(class: "hidden") { span { "Born rich!!!" } }

            ClipboardTrigger do
              Link(href: "#", class: "gap-1") do
                TypographyP(size: :small, class: "text-primary") { "Copy the secret of success!!!" }
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
      Docs::ComponentStruct.new(name: "ClipboarController", source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/clipboard_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "ClipboardPopover", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/clipboard_popover.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "ClipboardSource", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/clipboard_source.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "ClipboardTrigger", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/clipboard_trigger.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "Clipboard", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/clipboard.rb", built_using: :phlex)
    ]
  end
end
