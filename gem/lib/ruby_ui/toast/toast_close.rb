# frozen_string_literal: true

module RubyUI
  class ToastClose < Base
    def view_template
      button(**attrs) do
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          width: "14",
          height: "14",
          viewbox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          stroke_width: "2",
          stroke_linecap: "round",
          stroke_linejoin: "round",
          class: "size-3.5"
        ) do |s|
          s.path(d: "M18 6 6 18")
          s.path(d: "m6 6 12 12")
        end
        span(class: "sr-only") { "Close" }
      end
    end

    private

    def default_attrs
      {
        type: "button",
        aria_label: "Close toast",
        data: {
          slot: "close",
          action: "click->ruby-ui--toast#dismiss"
        },
        class: "absolute right-2 top-2 size-6 cursor-pointer rounded-md text-foreground/60 p-0 flex items-center justify-center transition-colors hover:bg-muted hover:text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
      }
    end
  end
end
