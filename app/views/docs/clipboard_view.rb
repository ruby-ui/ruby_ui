# frozen_string_literal: true

class Docs::ClipboardView < ApplicationView
  def view_template
    component = "Clipboard"
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

      render Docs::ComponentsTable.new(component_references(component, Docs::VisualCodeExample.collected_code), component_files(component))
    end
  end
end
