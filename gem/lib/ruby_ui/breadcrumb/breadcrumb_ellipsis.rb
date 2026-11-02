# frozen_string_literal: true

module RubyUI
  class BreadcrumbEllipsis < Base
    def view_template(&)
      span(**attrs) do
        icon
        span(class: "sr-only") { "More" }
      end
    end

    private

    def icon
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round",
        aria_hidden: "true"
      ) do |s|
        s.circle(cx: "12", cy: "12", r: "1")
        s.circle(cx: "19", cy: "12", r: "1")
        s.circle(cx: "5", cy: "12", r: "1")
      end
    end

    def default_attrs
      {
        aria: {hidden: "true"},
        data: {slot: "breadcrumb-ellipsis"},
        class: "flex size-5 items-center justify-center [&>svg]:size-4",
        role: "presentation"
      }
    end
  end
end
