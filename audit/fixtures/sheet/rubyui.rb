# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/sheet (strings in content.yml).
  class Sheet < Phlex::HTML
    include RubyUI

    def view_template
      Sheet do
        SheetTrigger do
          Button(variant: :outline, data: {audit_trigger: true}) { "Open sheet" }
        end
        SheetContent do
          SheetHeader do
            SheetTitle { "Edit profile" }
            SheetDescription { "Make changes to your profile here." }
          end
          SheetMiddle do
            p { "Your name and email are shown on your public profile." }
          end
          SheetFooter do
            Button(variant: :outline, data: {action: "click->ruby-ui--sheet-content#close"}) { "Cancel" }
            Button(type: "submit") { "Save changes" }
          end
        end
      end
    end
  end
end
