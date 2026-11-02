# frozen_string_literal: true

module RubyUI
  class CarouselPrevious < Base
    ORIENTATION_CLASSES = {
      horizontal: "-left-12 top-1/2 -translate-y-1/2",
      vertical: "-top-12 left-1/2 -translate-x-1/2 rotate-90"
    }.freeze

    def view_template
      # slot! overrides Button's data-slot="button" instead of appending to it.
      Button(**attrs, class: [ORIENTATION_CLASSES.fetch(orientation), attrs[:class]], data: {**attrs[:data], slot!: "carousel-previous"}) do
        icon
        span(class: "sr-only") { "Previous slide" }
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
          action: "click->ruby-ui--carousel#scrollPrev",
          ruby_ui__carousel_target: "prevButton"
        }
      }
    end

    # lucide chevron-left, mirrored in RTL when horizontal.
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
        # Mirrored in RTL only when horizontal: the vertical axis doesn't
        # depend on reading direction.
        class: (orientation == :horizontal) ? "rtl:rotate-180" : nil
      ) do |s|
        s.path(d: "m15 18-6-6 6-6")
      end
    end
  end
end
