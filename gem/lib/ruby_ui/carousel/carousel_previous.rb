# frozen_string_literal: true

module RubyUI
  class CarouselPrevious < Base
    def view_template(&)
      Button(**attrs) do
        icon
        span(class: "sr-only") { "Next slide" }
      end
    end

    private

    def default_attrs
      {
        variant: :outline,
        icon: true,
        class: [
          "absolute h-8 w-8 rounded-full",
          "group-[.is-horizontal]:-left-12 group-[.is-horizontal]:top-1/2 group-[.is-horizontal]:-translate-y-1/2",
          "group-[.is-vertical]:-top-12 group-[.is-vertical]:left-1/2 group-[.is-vertical]:-translate-x-1/2 group-[.is-vertical]:rotate-90"
        ],
        disabled: true,
        data: {
          action: "click->ruby-ui--carousel#scrollPrev",
          ruby_ui__carousel_target: "prevButton"
        }
      }
    end

    def icon
      svg(
        width: "24",
        height: "24",
        viewBox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round",
        xmlns: "http://www.w3.org/2000/svg",
        class: "w-4 h-4"
      ) do |s|
        s.path(d: "m12 19-7-7 7-7")
        s.path(d: "M19 12H5")
      end
    end
  end
end
