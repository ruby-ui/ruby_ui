# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/checkbox (strings in content.yml).
  class Checkbox < Phlex::HTML
    include RubyUI

    LABEL = "text-sm font-medium leading-none"

    def view_template
      div(class: "flex flex-col gap-6") do
        div(class: "flex items-center gap-3") do
          Checkbox(id: "terms", data: {audit_trigger: true})
          label(for: "terms", class: LABEL) { "Accept terms and conditions" }
        end
        div(class: "flex items-center gap-3") do
          Checkbox(id: "notifications", checked: true)
          label(for: "notifications", class: LABEL) { "Enable notifications" }
        end
        div(class: "flex items-center gap-3") do
          Checkbox(id: "disabled", disabled: true)
          label(for: "disabled", class: LABEL) { "Disabled option" }
        end
        div(class: "flex items-center gap-3") do
          Checkbox(id: "invalid", aria: {invalid: "true"})
          label(for: "invalid", class: LABEL) { "Invalid option" }
        end
      end
    end
  end
end
