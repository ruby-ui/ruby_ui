# frozen_string_literal: true

class Views::Docs::Switch < Views::Base
  def view_template
    component = "Switch"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Switch", description: "A control that allows the user to toggle between checked and not checked.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", description: "A native checkbox with role=\"switch\": Tab focuses it, Space toggles it, and a label with for= names it.", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-3") do
            Switch(id: "airplane_mode", name: "airplane_mode")
            FormFieldLabel(for: "airplane_mode") { "Airplane Mode" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Checked", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-3") do
            Switch(id: "notifications", name: "notifications", checked: true)
            FormFieldLabel(for: "notifications") { "Enable notifications" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Size", description: "size: :sm renders a smaller switch.", context: self) do
        <<~RUBY
          div(class: "flex flex-col gap-4") do
            div(class: "flex items-center gap-3") do
              Switch(id: "size_sm", size: :sm)
              FormFieldLabel(for: "size_sm") { "Small" }
            end
            div(class: "flex items-center gap-3") do
              Switch(id: "size_default")
              FormFieldLabel(for: "size_default") { "Default" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-3") do
            Switch(id: "switch_disabled", name: "switch_disabled", disabled: true)
            FormFieldLabel(for: "switch_disabled") { "Disabled" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Aria Disabled", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-3") do
            Switch(id: "switch_aria_disabled", name: "switch_aria_disabled", aria: {disabled: "true"})
            FormFieldLabel(for: "switch_aria_disabled") { "Aria disabled" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Invalid", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-3") do
            Switch(id: "switch_invalid", name: "terms", aria: {invalid: "true"})
            FormFieldLabel(for: "switch_invalid") { "Accept terms and conditions" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With flag include_hidden false", description: "By default a hidden input with the same name sends unchecked_value (\"0\") when the switch is off, like Rails' check_box. include_hidden: false skips it.", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-3") do
            Switch(id: "switch_no_hidden", name: "switch", include_hidden: false)
            FormFieldLabel(for: "switch_no_hidden") { "Without hidden input" }
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
