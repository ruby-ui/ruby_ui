# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/tooltip (strings in content.yml).
  # close_on_click: false matches the shadcn side, so collect's click leaves it open.
  class Tooltip < Phlex::HTML
    include RubyUI

    def view_template
      Tooltip do
        TooltipTrigger(close_on_click: false) do
          Button(variant: :outline, class: "w-fit", data: {audit_trigger: true}) { "Show Tooltip" }
        end
        TooltipContent do
          p { "Add to library" }
        end
      end
    end
  end
end
