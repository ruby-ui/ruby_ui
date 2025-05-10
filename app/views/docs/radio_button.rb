# frozen_string_literal: true

class Views::Docs::RadioButton < Views::Base
  def view_template
    component = "RadioButton"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Radio Button", description: "A control that allows users to make a single selection from a list of options.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          div(class: "flex items-center space-x-2") do
            RadioButton(id: "default")
            FormFieldLabel(for: "default") { "Default" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Checked", context: self) do
        <<~RUBY
          div(class: "flex items-center space-x-2") do
            RadioButton(id: "checked", checked: true)
            FormFieldLabel(for: "checked") { "Checked" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          div(class: "flex flex-row items-center gap-2") do
            RadioButton(class: "peer",id: "disabled", disabled: true)
            FormFieldLabel(for: "disabled") { "Disabled" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Aria Disabled", context: self) do
        <<~RUBY
          div(class: "flex flex-row items-center gap-2") do
            RadioButton(class: "peer", id: "aria-disabled", aria: {disabled: "true"})
            FormFieldLabel(for: "aria-disabled") { "Aria Disabled" }
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
