# frozen_string_literal: true

module RubyUI
  class CalendarPrev < Base
    NAV_CLASS = "group/button inline-flex size-8 shrink-0 items-center justify-center rounded-md border border-transparent " \
      "bg-clip-padding p-0 text-sm font-medium whitespace-nowrap transition-all outline-none select-none " \
      "focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50 active:not-aria-[haspopup]:translate-y-px " \
      "disabled:pointer-events-none disabled:opacity-50 aria-disabled:opacity-50 " \
      "hover:bg-muted hover:text-foreground dark:hover:bg-muted/50 [&_svg]:pointer-events-none [&_svg]:shrink-0"

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
        s.path(d: "m15 18-6-6 6-6")
      end
    end

    # shadcn's ghost Button at the calendar cell size.
    def default_attrs
      {
        name: "previous-month",
        aria_label: "Go to the Previous Month",
        class: NAV_CLASS,
        type: "button",
        data_action: "click->ruby-ui--calendar#prevMonth"
      }
    end
  end
end
