# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/dropdown_menu (strings in content.yml).
  class DropdownMenu < Phlex::HTML
    include RubyUI

    def view_template
      DropdownMenu do
        DropdownMenuTrigger do
          Button(variant: :outline, class: "w-fit", data: {audit_trigger: true}) { "Open" }
        end
        DropdownMenuContent do
          DropdownMenuGroup do
            DropdownMenuLabel { "My Account" }
            DropdownMenuSeparator()
            DropdownMenuItem { "Profile" }
            DropdownMenuItem { "Billing" }
            DropdownMenuItem { "Team" }
            DropdownMenuItem { "Subscription" }
          end
        end
      end
    end
  end
end
