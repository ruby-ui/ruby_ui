# frozen_string_literal: true

module RubyUI
  class CarouselNext < Base
    ORIENTATION_CLASSES = {
      horizontal: "-right-12 top-1/2 -translate-y-1/2",
      vertical: "-bottom-12 left-1/2 -translate-x-1/2 rotate-90"
    }.freeze

    def view_template
      # slot! overrides Button's data-slot="button" instead of appending to it.
      Button(**attrs, class: [ORIENTATION_CLASSES.fetch(orientation), attrs[:class]], data: {**attrs[:data], slot!: "carousel-next"}) do
        icon
        span(class: "sr-only") { "Next slide" }
      end
    end

    private

    def orientation
      context.dig(:ruby_ui_carousel, :orientation) || :horizontal
    end

    def default_attrs
      {
        variant: :outline,
        icon: true,
        class: "absolute h-8 w-8 rounded-full touch-manipulation",
        disabled: true,
        data: {
          action: "click->ruby-ui--carousel#scrollNext",
          ruby_ui__carousel_target: "nextButton"
        }
      }
    end

    # lucide chevron-right, mirrored in RTL.
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
        aria_hidden: "true",
        class: "rtl:rotate-180"
      ) do |s|
        s.path(d: "m9 18 6-6-6-6")
      end
    end
  end
end
