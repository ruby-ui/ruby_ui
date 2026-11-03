# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/masked_input (strings in content.yml).
  class MaskedInput < Phlex::HTML
    include RubyUI

    LABEL = "text-sm font-medium leading-none"
    PHONE = "(##) #####-####"
    DOCUMENT = "['###.###.###-##', '##.###.###/####-##']"

    def view_template
      div(class: "flex w-80 flex-col gap-6") do
        field("phone", "Phone") { MaskedInput(id: "phone", placeholder: "(11) 98765-4321", data: {maska: PHONE, audit_input: true, audit_trigger: true}) }
        field("phone_filled", "Phone (filled)") { MaskedInput(id: "phone_filled", value: "11987654321", data: {maska: PHONE, audit_input: true}) }
        field("document", "CPF / CNPJ") { MaskedInput(id: "document", value: "12345678000190", data: {maska: DOCUMENT, audit_input: true}) }
        field("disabled", "Disabled") { MaskedInput(id: "disabled", disabled: true, placeholder: "Disabled input", data: {maska: PHONE, audit_input: true}) }
        field("invalid", "Invalid") { MaskedInput(id: "invalid", aria: {invalid: "true"}, placeholder: "Invalid input", data: {maska: PHONE, audit_input: true}) }
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
