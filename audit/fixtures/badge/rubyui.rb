# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/badge (strings in content.yml).
  class Badge < Phlex::HTML
    include RubyUI

    def view_template
      div(class: "flex flex-wrap items-center gap-2") do
        Badge { "Badge" }
        Badge(variant: :secondary) { "Secondary" }
        Badge(variant: :destructive) { "Destructive" }
        Badge(variant: :outline) { "Outline" }
        Badge(variant: :ghost) { "Ghost" }
        Badge(variant: :link) { "Link" }
        Badge(href: "#", data: {audit_trigger: true}) { "Open Link" }
      end
    end
  end
end
