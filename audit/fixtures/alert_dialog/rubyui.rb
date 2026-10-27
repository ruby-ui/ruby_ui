# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/alert_dialog (strings in content.yml).
  class AlertDialog < Phlex::HTML
    include RubyUI

    def view_template
      AlertDialog do
        AlertDialogTrigger do
          Button(variant: :outline, data: {audit_trigger: true}) { "Delete account" }
        end
        AlertDialogContent do
          AlertDialogHeader do
            AlertDialogTitle { "Are you absolutely sure?" }
            AlertDialogDescription { "This action cannot be undone." }
          end
          AlertDialogFooter do
            AlertDialogCancel { "Cancel" }
            AlertDialogAction { "Continue" }
          end
        end
      end
    end
  end
end
