# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/empty (strings in content.yml).
  # The icon is lucide's folder as lucide-react renders it (24x24, aria-hidden,
  # no size class), so both sides get the same SVG.
  class Empty < Phlex::HTML
    include RubyUI

    def view_template
      div(class: "flex w-[32rem]") do
        Empty do
          EmptyHeader do
            EmptyMedia(variant: :icon) do
              svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none",
                stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true") do |s|
                s.path(d: "M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z")
              end
            end
            EmptyTitle { "No projects yet" }
            EmptyDescription do
              plain "You haven't created any projects yet. "
              a(href: "#") { "Learn more" }
            end
          end
          EmptyContent do
            button(type: "button", data: {audit_trigger: true}) { "Create project" }
          end
        end
      end
    end
  end
end
