# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/form (strings in content.yml).
  class Form < Phlex::HTML
    include RubyUI

    def view_template
      Form(class: "flex w-96 flex-col gap-6") do
        FormFieldGroup do
          FormField do
            FormFieldLabel(for: "username") { "Username" }
            Input(id: "username", required: true, minlength: 3)
            FormFieldHint { "Choose a public username." }
            FormFieldError()
          end
          FormField(data: {invalid: "true"}) do
            FormFieldLabel(for: "email") { "Email" }
            Input(id: "email", type: "email", aria: {invalid: "true"})
            FormFieldError(errors: ["is too short", "is invalid"])
          end
        end
        FormFieldSet do
          FormFieldLegend { "Notifications" }
          FormFieldHint { "Pick how we reach you." }
          FormFieldGroup do
            FormField(orientation: :horizontal) do
              Checkbox(id: "newsletter")
              FormFieldContent do
                FormFieldLabel(for: "newsletter") { "Email me updates" }
                FormFieldHint { "One email a month." }
              end
            end
            FormFieldSeparator { "Or" }
            FormField(orientation: :responsive) do
              FormFieldLabel(for: "phone") { "Phone" }
              Input(id: "phone", type: "tel")
            end
          end
        end
        FormField(data: {disabled: "true"}) do
          FormFieldLabel(for: "company") { "Company" }
          Input(id: "company", disabled: true)
        end
        Button(type: "submit", data: {audit_trigger: true}) { "Save" }
      end
    end
  end
end
