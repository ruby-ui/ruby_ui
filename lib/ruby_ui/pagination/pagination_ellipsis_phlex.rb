# frozen_string_literal: true

module RubyUI
  class PaginationEllipsis < Base
    def view_template(&)
      li do
        span(**attrs) do
          svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", class: "h-4 w-4") do |s|
            s.circle(cx: "12", cy: "12", r: "1")

            s.circle(cx: "19", cy: "12", r: "1")

            s.circle(cx: "5", cy: "12", r: "1")
          end

          span(class: "sr-only") do
            plain "More pages"
          end
        end
      end
    end

    private

    def default_attrs
      {
        aria: {hidden: true},
        class: "flex h-9 w-9 items-center justify-center"
      }
    end
  end
end
