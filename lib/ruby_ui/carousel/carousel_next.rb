# frozen_string_literal: true

module RubyUI
  class CarouselNext < Base
    ORIENTATION_CLASSES = {
      horizontal: "-right-12 top-1/2 -translate-y-1/2",
      vertical: "-bottom-12 left-1/2 -translate-x-1/2 rotate-90"
    }

    def initialize(**attrs)
      @orientation = CarouselContext.orientation || :horizontal

      super
    end

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
        class: ["absolute h-8 w-8 rounded-full", ORIENTATION_CLASSES[@orientation]],
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
