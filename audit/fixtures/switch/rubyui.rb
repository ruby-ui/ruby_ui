# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/switch (strings in content.yml).
  class Switch < Phlex::HTML
    include RubyUI

    LABEL = "text-sm font-medium leading-none"

    def view_template
      div(class: "flex flex-col gap-6") do
        div(class: "flex items-center gap-3") do
          Switch(id: "airplane", name: "airplane", data: {audit_trigger: true})
          label(for: "airplane", class: LABEL) { "Airplane mode" }
        end
        div(class: "flex items-center gap-3") do
          Switch(id: "notifications", name: "notifications", checked: true)
          label(for: "notifications", class: LABEL) { "Enable notifications" }
        end
        div(class: "flex items-center gap-3") do
          Switch(id: "disabled", name: "disabled", disabled: true)
          label(for: "disabled", class: LABEL) { "Disabled option" }
        end
        div(class: "flex items-center gap-3") do
          Switch(id: "invalid", name: "invalid", aria: {invalid: "true"})
          label(for: "invalid", class: LABEL) { "Invalid option" }
        end
      end
    end
  end
end
