# frozen_string_literal: true

module RubyUI
  # Chevron down while closed, chevron up while open (lucide icons, swapped
  # with CSS on the parent <details open>). Pass a block to render your own.
  class AccordionIcon < Base
    CHEVRONS = {down: "m6 9 6 6 6-6", up: "m18 15-6-6-6 6"}.freeze

    def view_template(&block)
      if block
        span(**attrs, &block)
      else
        chevron(:down, "group-open/accordion-item:hidden")
        chevron(:up, "hidden group-open/accordion-item:inline")
      end
    end

    private

    def chevron(direction, visibility)
      svg(
        **mix(attrs, class: visibility),
        xmlns: "http://www.w3.org/2000/svg",
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round"
      ) { |s| s.path(d: CHEVRONS[direction]) }
    end

    def default_attrs
      {
        aria: {hidden: "true"},
        data: {slot: "accordion-trigger-icon"},
        class: "pointer-events-none ml-auto size-4 shrink-0 text-muted-foreground"
      }
    end
  end
end
