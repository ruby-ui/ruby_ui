# frozen_string_literal: true

class Views::Docs::Textarea < Views::Base
  def view_template
    component = "Textarea"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Textarea", description: "Displays a textarea field.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Textarea", context: self) do
        <<~RUBY
          div(class: "grid w-full max-w-sm items-center gap-1.5") do
            Textarea(placeholder: "Textarea")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          div(class: "grid w-full max-w-sm items-center gap-1.5") do
            Textarea(disabled: true, placeholder: "Disabled")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Aria Disabled", context: self) do
        <<~RUBY
          div(class: "grid w-full max-w-sm items-center gap-1.5") do
            Textarea(aria: {disabled: "true"}, placeholder: "Aria Disabled")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With FormField", context: self) do
        <<~RUBY
          div(class: "grid w-full max-w-sm items-center gap-1.5") do
            FormField do
              FormFieldLabel(for: "textarea") { "Textarea" }
              FormFieldHint { "This is a textarea" }
              Textarea(placeholder: "Textarea", id: "textarea")
              FormFieldError()
            end
          end
        RUBY
      end
    end

    render Components::ComponentSetup::Tabs.new(component_name: component)

    render Docs::ComponentsTable.new(component_files(component))
  end
end
