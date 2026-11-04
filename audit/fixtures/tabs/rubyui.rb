# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/tabs (strings in content.yml).
  class Tabs < Phlex::HTML
    include RubyUI

    def view_template
      Tabs(default_value: "account", class: "w-96") do
        TabsList do
          TabsTrigger(value: "account") { "Account" }
          TabsTrigger(value: "password", data: {audit_trigger: true}) { "Password" }
          TabsTrigger(value: "billing", disabled: true) { "Billing" }
        end
        TabsContent(value: "account") { "Make changes to your account here." }
        TabsContent(value: "password") { "Change your password here." }
        TabsContent(value: "billing") { "Manage your billing details here." }
      end
    end
  end
end
