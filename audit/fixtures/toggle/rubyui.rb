# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/toggle (strings in content.yml).
  class Toggle < Phlex::HTML
    include RubyUI

    def view_template
      div(class: "flex flex-wrap items-center gap-2") do
        Toggle(aria: {label: "Toggle bold"}, data: {audit_trigger: true}) { bold_icon }
        Toggle(aria: {label: "Toggle italic"}, pressed: true) { italic_icon }
        Toggle(variant: :outline) do
          italic_icon
          plain "Italic"
        end
        Toggle(variant: :outline, pressed: true) do
          bold_icon
          plain "Bold"
        end
        Toggle(variant: :outline) do
          underline_icon
          plain "Underline"
        end
        Toggle(variant: :outline, size: :sm) { "Small" }
        Toggle(variant: :outline, size: :default) { "Default" }
        Toggle(variant: :outline, size: :lg) { "Large" }
        Toggle(disabled: true) { "Disabled" }
        Toggle(variant: :outline, aria: {invalid: "true"}) { "Invalid" }
      end
    end

    private

    def bold_icon
      lucide_icon { |s| s.path(d: "M6 12h9a4 4 0 0 1 0 8H7a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1h7a4 4 0 0 1 0 8") }
    end

    def underline_icon
      lucide_icon(data: {icon: "inline-start"}) do |s|
        s.path(d: "M6 4v6a6 6 0 0 0 12 0V4")
        s.line(x1: "4", x2: "20", y1: "20", y2: "20")
      end
    end

    def italic_icon
      lucide_icon do |s|
        s.line(x1: "19", x2: "10", y1: "4", y2: "4")
        s.line(x1: "14", x2: "5", y1: "20", y2: "20")
        s.line(x1: "15", x2: "9", y1: "4", y2: "20")
      end
    end

    def lucide_icon(**attrs, &)
      svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none",
        stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true", **attrs, &)
    end
  end
end
