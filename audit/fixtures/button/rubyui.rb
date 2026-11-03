# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/button (strings in content.yml).
  class Button < Phlex::HTML
    include RubyUI

    def view_template
      div(class: "flex flex-wrap items-center gap-2") do
        Button(data: {audit_trigger: true}) { "Button" }
        Button(variant: :outline) { "Outline" }
        Button(variant: :secondary) { "Secondary" }
        Button(variant: :ghost) { "Ghost" }
        Button(variant: :destructive) { "Destructive" }
        Button(variant: :link) { "Link" }
        Button(size: :sm) { "Small" }
        Button(size: :lg) { "Large" }
        Button(variant: :outline, icon: true, aria: {label: "Next"}) { lucide_icon { |s| s.path(d: "m9 18 6-6-6-6") } }
        Button do
          lucide_icon(data: {icon: "inline-start"}) do |s|
            s.path(d: "m22 2-7 20-4-9-9-4Z")
            s.path(d: "M22 2 11 13")
          end
          plain "Send"
        end
        Button(disabled: true) { "Disabled" }
        Button(href: "#") { "Open Link" }
        Button(disabled: true, focusable_when_disabled: true) { "Focusable" }
      end
    end

    private

    def lucide_icon(**attrs, &)
      svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none",
        stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true", **attrs, &)
    end
  end
end
