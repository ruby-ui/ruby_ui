# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/progress (strings in content.yml).
  class Progress < Phlex::HTML
    include RubyUI

    def view_template
      div(id: "progress-fixture", class: "flex w-96 flex-col gap-4") do
        Progress(value: 0)
        Progress(value: 25)
        Progress(value: 50, data: {audit_trigger: true})
        Progress(value: 75)
        Progress(value: 100)
        Progress(value: 56) do
          ProgressLabel { "Upload progress" }
          ProgressValue()
        end
      end
    end
  end
end
