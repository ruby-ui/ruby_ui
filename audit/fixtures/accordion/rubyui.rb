# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/accordion (strings in content.yml).
  class Accordion < Phlex::HTML
    include RubyUI

    ITEMS = [
      ["Is it accessible?", "Yes. It adheres to the WAI-ARIA design pattern."],
      ["Is it styled?", "Yes. It comes with default styles that match the other components."],
      ["Is it animated?", "Yes. It's animated by default, but you can disable it if you prefer."]
    ].freeze

    def view_template
      Accordion(class: "w-96") do
        ITEMS.each_with_index do |(trigger, content), index|
          AccordionItem do
            AccordionTrigger(data: (index.zero? ? {audit_trigger: true} : {})) { trigger }
            AccordionContent { content }
          end
        end
      end
    end
  end
end
