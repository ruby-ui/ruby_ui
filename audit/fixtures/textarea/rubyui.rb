# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/textarea (strings in content.yml).
  class Textarea < Phlex::HTML
    include RubyUI

    LABEL = "text-sm font-medium leading-none"

    def view_template
      div(class: "flex w-80 flex-col gap-6") do
        field("message", "Message") { Textarea(id: "message", placeholder: "Type your message here.", data: {audit_textarea: true, audit_trigger: true}) }
        field("bio", "Bio") { Textarea(id: "bio", data: {audit_textarea: true}) { ["Line one", "Line two", "Line three"].join("\n") } }
        field("disabled", "Disabled") { Textarea(id: "disabled", disabled: true, placeholder: "Disabled textarea", data: {audit_textarea: true}) }
        field("aria_disabled", "Aria disabled") { Textarea(id: "aria_disabled", aria: {disabled: "true"}, placeholder: "Aria disabled textarea", data: {audit_textarea: true}) }
        field("invalid", "Invalid") { Textarea(id: "invalid", aria: {invalid: "true"}, placeholder: "Invalid textarea", data: {audit_textarea: true}) }
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
