# frozen_string_literal: true

module RubyUI
  # "More pages" marker. Renders its own <li> (shadcn wraps it in
  # PaginationItem) and is hidden from assistive tech, as in shadcn.
  class PaginationEllipsis < Base
    def view_template
      li(data: {slot: "pagination-item"}) do
        span(**attrs) do
          icon
          span(class: "sr-only") { "More pages" }
        end
      end
    end

    private

    def icon
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        width: "24",
        height: "24",
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

    # aria-hidden needs the string: Phlex renders true as an empty value,
    # which doesn't hide the element.
    def default_attrs
      {
        aria: {hidden: "true"},
        data: {slot: "pagination-ellipsis"},
        class: "flex size-9 items-center justify-center [&_svg:not([class*='size-'])]:size-4"
      }
    end
  end
end
