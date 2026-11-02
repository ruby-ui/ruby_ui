# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/card (strings in content.yml).
  class Card < Phlex::HTML
    include RubyUI

    def view_template
      Card(class: "w-96") do
        CardHeader do
          CardTitle { "Login to your account" }
          CardDescription { "Enter your email below to login to your account" }
          CardAction { button(type: "button") { "Sign up" } }
        end
        CardContent do
          p { "Your account details stay private." }
        end
        CardFooter do
          button(type: "button", data: {audit_trigger: true}) { "Login" }
        end
      end
    end
  end
end
