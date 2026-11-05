# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/toast (strings in content.yml).
  # duration: Infinity (RubyUI) / timeout: 0 (shadcn) keeps the toast up while collect observes it.
  class Toast < Phlex::HTML
    include RubyUI

    SHOW_TOAST = <<~JS
      document.querySelector("[data-audit-trigger]").addEventListener("click", () => {
        window.RubyUI.toast("Event created", {
          description: "Sunday, December 3 at 9:00 AM",
          duration: Infinity
        })
      })
    JS

    def view_template
      Button(variant: :outline, data: {audit_trigger: true}) { "Show Toast" }
      ToastRegion()
      script { raw(safe(SHOW_TOAST)) }
    end
  end
end
