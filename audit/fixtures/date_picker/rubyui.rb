# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/date_picker (values in content.yml).
  class DatePicker < Phlex::HTML
    include RubyUI

    def view_template
      div(class: "p-6") do
        DatePicker(
          id: "date",
          label: "Date",
          selected_date: "2026-03-12",
          placeholder: "Select a date",
          class: "w-48",
          trigger_attrs: {data: {audit_trigger: true}}
        )
      end
    end
  end
end
