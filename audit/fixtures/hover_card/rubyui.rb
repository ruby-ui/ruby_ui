# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/hover_card (strings in content.yml).
  class HoverCard < Phlex::HTML
    include RubyUI

    def view_template
      # Delays are 0 so collect's click reaches the open state; the shadcn
      # fixture does the same.
      HoverCard do
        HoverCardTrigger(delay: 0, close_delay: 0) do
          Button(variant: :outline, data: {audit_trigger: true}) { "Hover me" }
        end
        HoverCardContent do
          div(class: "flex flex-col gap-2") do
            h4(class: "font-medium") { "Hover Card" }
            p { "This hover card appears on the bottom side of the trigger." }
          end
        end
      end
    end
  end
end
