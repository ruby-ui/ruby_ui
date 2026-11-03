# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/calendar (values in content.yml).
  # shadcn disabled={{ before }} maps to RubyUI's min_date; the selected date
  # also sets the month on view (shadcn's defaultMonth).
  class Calendar < Phlex::HTML
    include RubyUI

    def view_template
      div(class: "p-6") do
        Calendar(selected_date: "2026-03-12", min_date: "2026-03-05", data: {audit_trigger: true})
      end
    end
  end
end
