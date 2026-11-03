# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/input (strings in content.yml).
  class Input < Phlex::HTML
    include RubyUI

    LABEL = "text-sm font-medium leading-none"

    def view_template
      div(class: "flex w-80 flex-col gap-6") do
        field("email", "Email") { Input(id: "email", type: "email", placeholder: "m@example.com", data: {audit_input: true, audit_trigger: true}) }
        field("plain", "Name") { Input(id: "plain", placeholder: "Your name", data: {audit_input: true}) }
        field("password", "Password") { Input(id: "password", type: "password", value: "secret", data: {audit_input: true}) }
        field("file", "Picture") { Input(id: "file", type: "file", data: {audit_input: true}) }
        field("disabled", "Disabled") { Input(id: "disabled", disabled: true, placeholder: "Disabled input", data: {audit_input: true}) }
        field("aria_disabled", "Aria disabled") { Input(id: "aria_disabled", aria: {disabled: "true"}, placeholder: "Aria disabled input", data: {audit_input: true}) }
        field("invalid", "Invalid") { Input(id: "invalid", aria: {invalid: "true"}, placeholder: "Invalid input", data: {audit_input: true}) }
      end
    end

    private

    def field(id, text, &)
      div(class: "flex flex-col gap-2") do
        label(for: id, class: LABEL) { text }
        yield
      end
    end
  end
end
