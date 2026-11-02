# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/collapsible (strings in content.yml).
  class Collapsible < Phlex::HTML
    include RubyUI

    ROW = "rounded-md border px-4 py-2 font-mono text-sm"

    def view_template
      Collapsible(class: "w-[350px] flex flex-col gap-2") do
        div(class: "flex items-center justify-between gap-4 px-4") do
          h4(class: "text-sm font-semibold") { "@peduarte starred 3 repositories" }
          CollapsibleTrigger(variant: :ghost, icon: true, class: "size-8", data: {audit_trigger: true}) do
            svg(xmlns: "http://www.w3.org/2000/svg", viewbox: "0 0 24 24", fill: "none", stroke: "currentColor",
              stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", class: "size-4") do |s|
              s.path(d: "m7 15 5 5 5-5")
              s.path(d: "m7 9 5-5 5 5")
            end
            span(class: "sr-only") { "Toggle" }
          end
        end
        div(class: ROW) { "@radix-ui/primitives" }
        CollapsibleContent(class: "flex flex-col gap-2") do
          div(class: ROW) { "@radix-ui/colors" }
          div(class: ROW) { "@stitches/react" }
        end
      end
    end
  end
end
