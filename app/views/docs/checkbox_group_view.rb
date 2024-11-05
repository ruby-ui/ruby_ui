# frozen_string_literal: true

class Docs::CheckboxGroupView < ApplicationView
  def view_template
    component = "CheckboxGroup"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "CheckboxGroup", description: "A control that allows the user to toggle between checked and not checked.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          CheckboxGroup(data_required: true) do
            div(class: "flex flex-col gap-2") do
              div(class: "flex flex-row items-center gap-2") do
                Checkbox(value: "FOO", id: "FOO")
                FormFieldLabel(for: "FOO") { "FOO" }
              end

              div(class: "flex flex-row items-center gap-2") do
                Checkbox(value: "BAR", id: "BAR")
                FormFieldLabel(for: "BAR") { "BAR" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With Form", context: self) do
        <<~RUBY
          form(class: "flex flex-col gap-2") do
            FormField do
              FormFieldLabel { "CHECKBOX_GROUP" }

              FormFieldHint { "HINT_FOR_CHECKBOX_GROUP" }

              CheckboxGroup(data_required: true) do
                div(class: "flex flex-col gap-2") do
                  div(class: "flex flex-row items-center gap-2") do
                    Checkbox(
                      id: "FOO",
                      value: "FOO",
                      checked: false,
                      name: "CHECKBOX_GROUP[]",
                      data: {value_missing: "CUSTOM_MESSAGE"}
                    )

                    FormFieldLabel(for: "FOO") { "FOO" }
                  end

                  div(class: "flex flex-row items-center gap-2") do
                    Checkbox(
                      id: "BAR",
                      value: "BAR",
                      checked: true,
                      name: "CHECKBOX_GROUP[]",
                      data: {value_missing: "CUSTOM_MESSAGE"}
                    )

                    FormFieldLabel(for: "BAR") { "BAR" }
                  end
                end
              end

              FormFieldError()
            end

            Button(type: "submit") { "SUBMIT_BUTTON" }
          end
        RUBY
      end

      render Docs::ComponentsTable.new(component_references(component, Docs::VisualCodeExample.collected_code), component_files(component))
    end
  end
end
