# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/radio_button (strings in content.yml).
  class RadioButton < Phlex::HTML
    include RubyUI

    LABEL = "text-sm font-medium leading-none"

    def view_template
      div(class: "flex flex-col gap-6") do
        RadioGroup do
          div(class: "flex items-center gap-3") do
            RadioButton(id: "r-default", name: "density", value: "default")
            label(for: "r-default", class: LABEL) { "Default" }
          end
          div(class: "flex items-center gap-3") do
            RadioButton(id: "r-comfortable", name: "density", value: "comfortable", checked: true, data: {audit_trigger: true})
            label(for: "r-comfortable", class: LABEL) { "Comfortable" }
          end
          div(class: "flex items-center gap-3") do
            RadioButton(id: "r-compact", name: "density", value: "compact", disabled: true)
            label(for: "r-compact", class: LABEL) { "Compact" }
          end
        end
        RadioGroup do
          div(class: "flex items-center gap-3") do
            RadioButton(id: "r-invalid", name: "invalid", value: "invalid", aria: {invalid: "true"})
            label(for: "r-invalid", class: LABEL) { "Invalid option" }
          end
        end
      end
    end
  end
end
