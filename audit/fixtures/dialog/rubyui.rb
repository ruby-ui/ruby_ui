# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/dialog (strings in content.yml).
  class Dialog < Phlex::HTML
    include RubyUI

    def view_template
      Dialog do
        DialogTrigger do
          Button(variant: :outline, data: {audit_trigger: true}) { "Open dialog" }
        end
        DialogContent do
          DialogHeader do
            DialogTitle { "Edit profile" }
            DialogDescription { "Make changes to your profile here." }
          end
          DialogMiddle do
            p { "Your name and email are shown on your public profile." }
          end
          DialogFooter do
            Button(variant: :outline, data: {action: "click->ruby-ui--dialog#dismiss"}) { "Cancel" }
            Button(type: "submit") { "Save changes" }
          end
        end
      end
    end
  end
end
