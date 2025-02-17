# frozen_string_literal: true

module RubyUI
  class CarouselNext < Base
    def view_template(&)
      Button(**attrs) do
        icon
      end
    end

    private

    def default_attrs
      {
        variant: :outline,
        icon: true,
        class: [
          "absolute h-8 w-8 rounded-full",
          "group-[.is-horizontal]:-right-12 group-[.is-horizontal]:top-1/2 group-[.is-horizontal]:-translate-y-1/2",
          "group-[.is-vertical]:-bottom-12 group-[.is-vertical]:left-1/2 group-[.is-vertical]:-translate-x-1/2 group-[.is-vertical]:rotate-90"
        ],
        disabled: true,
        data: {
          action: "click->ruby-ui--carousel#scrollNext",
          ruby_ui__carousel_target: "nextButton"
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
        s.path(d: "M5 12h14")
        s.path(d: "m12 5 7 7-7 7")
      end
    end
  end
end
