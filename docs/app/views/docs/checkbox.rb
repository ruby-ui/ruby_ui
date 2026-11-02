# frozen_string_literal: true

class Views::Docs::Checkbox < Views::Base
  def view_template
    component = "Checkbox"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Checkbox", description: "A control that allows the user to toggle between checked and not checked.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-3") do
            Checkbox(id: "terms")
            FormFieldLabel(for: "terms") { "Accept terms and conditions" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Checked", context: self) do
        <<~RUBY
          div(class: "flex items-start gap-3") do
            Checkbox(id: "terms_checked", checked: true)
            div(class: "grid gap-2") do
              FormFieldLabel(for: "terms_checked") { "Accept terms and conditions" }
              p(class: "text-sm text-muted-foreground") { "By clicking this checkbox, you agree to the terms and conditions." }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Indeterminate", description: 'The mixed state, for example a "select all" box. The browser clears it on the first click.', context: self) do
        <<~RUBY
          div(class: "flex items-center gap-3") do
            Checkbox(id: "select_all", indeterminate: true)
            FormFieldLabel(for: "select_all") { "Select all" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-3") do
            Checkbox(id: "toggle_disabled", disabled: true)
            FormFieldLabel(for: "toggle_disabled") { "Enable notifications" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Invalid", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-3") do
            Checkbox(id: "terms_invalid", aria: {invalid: "true"})
            FormFieldLabel(for: "terms_invalid") { "Accept terms and conditions" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Read only", description: "Keeps its value and is submitted with the form, but can't be toggled.", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-3") do
            Checkbox(id: "terms_readonly", name: "terms_accepted", value: "1", checked: true, readonly: true)
            FormFieldLabel(for: "terms_readonly") { "Accepted on sign up" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Unchecked value", description: "unchecked_value: renders a hidden input with the same name before the checkbox, so the form also sends a value when the box is unchecked (like Rails' check_box).", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-3") do
            Checkbox(id: "user_admin", name: "user[admin]", value: "1", unchecked_value: "0")
            FormFieldLabel(for: "user_admin") { "Admin" }
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
