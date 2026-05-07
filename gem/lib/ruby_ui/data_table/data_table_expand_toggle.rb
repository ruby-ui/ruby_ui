# frozen_string_literal: true

module RubyUI
  class DataTableExpandToggle < Base
    def initialize(controls:, expanded: false, label: "Toggle row details", **attrs)
      @controls = controls
      @expanded = expanded
      @label = label
      super(**attrs)
    end

    def view_template
      button(
        type: "button",
        aria_expanded: @expanded.to_s,
        aria_controls: @controls,
        aria_label: @label,
        data: {
          action: "click->ruby-ui--data-table#toggleRowDetail"
        },
        **attrs
      ) do
        render_icon
      end
    end

    private

    def render_icon
      # inline chevron-right SVG (lucide)
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        width: "16",
        height: "16",
        viewBox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round",
        class: "h-4 w-4 transition-transform duration-150 group-aria-expanded:rotate-90"
      ) do |s|
        s.polyline(points: "9 18 15 12 9 6")
      end
    end

    def default_attrs
      {
        class: "group inline-flex items-center justify-center h-8 w-8 rounded-md hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
      }
    end
  end
end
