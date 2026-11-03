# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/link (strings in content.yml).
  class Link < Phlex::HTML
    include RubyUI

    def view_template
      div(class: "flex flex-wrap items-center gap-2") do
        Link(href: "#", data: {audit_trigger: true}) { "Button" }
        Link(href: "#", variant: :outline) { "Outline" }
        Link(href: "#", variant: :secondary) { "Secondary" }
        Link(href: "#", variant: :ghost) { "Ghost" }
        Link(href: "#", variant: :destructive) { "Destructive" }
        Link(href: "#", variant: :link) { "Link" }
        Link(href: "#", variant: :primary, size: :sm) { "Small" }
        Link(href: "#", variant: :primary, size: :lg) { "Large" }
        Link(href: "#", variant: :outline, icon: true, aria: {label: "Next"}) { lucide_icon { |s| s.path(d: "m9 18 6-6-6-6") } }
        Link(href: "#", variant: :primary) do
          lucide_icon(data: {icon: "inline-start"}) do |s|
            s.path(d: "m22 2-7 20-4-9-9-4Z")
            s.path(d: "M22 2 11 13")
          end
          plain "Send"
        end
        Link(href: "#", disabled: true) { "Disabled" }
      end
    end

    private

    def lucide_icon(**attrs, &)
      svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none",
        stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true", **attrs, &)
    end
  end
end
