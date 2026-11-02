# frozen_string_literal: true

module RubyUI
  class CalendarNext < Base
    def view_template
      button(**attrs) do
        icon
      end
    end

    private

    # lucide chevron, as in shadcn.
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
        class: "size-4",
        aria_hidden: "true"
      ) do |s|
        s.path(d: "m9 18 6-6-6-6")
      end
    end

    # shadcn's ghost Button at the calendar cell size.
    def default_attrs
      {
        name: "next-month",
        aria_label: "Go to the Next Month",
        class: CalendarPrev::NAV_CLASS,
        type: "button",
        data_action: "click->ruby-ui--calendar#nextMonth"
      }
    end
  end
end
