# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/alert (strings in content.yml).
  # Icons are lucide's info / circle-alert as lucide-react renders them
  # (24x24, aria-hidden, no size class), so both sides get the same SVG.
  class Alert < Phlex::HTML
    include RubyUI

    def view_template
      div(class: "flex w-96 flex-col gap-4") do
        Alert do
          lucide_icon { |s| info_paths(s) }
          AlertTitle { "Heads up!" }
          AlertDescription { "You can add components to your app using the CLI." }
          AlertAction { button(type: "button", data: {audit_trigger: true}) { "Undo" } }
        end
        Alert(variant: :destructive) do
          lucide_icon { |s| circle_alert_paths(s) }
          AlertTitle { "Something went wrong" }
          AlertDescription { "Your session has expired. Please log in again." }
        end
      end
    end

    private

    def lucide_icon(&)
      svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none",
        stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true", &)
    end

    def info_paths(s)
      s.circle(cx: "12", cy: "12", r: "10")
      s.path(d: "M12 16v-4")
      s.path(d: "M12 8h.01")
    end

    def circle_alert_paths(s)
      s.circle(cx: "12", cy: "12", r: "10")
      s.line(x1: "12", x2: "12", y1: "8", y2: "12")
      s.line(x1: "12", x2: "12.01", y1: "16", y2: "16")
    end
  end
end
