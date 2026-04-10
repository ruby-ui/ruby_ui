# frozen_string_literal: true

module RubyUI
  class CalendarPrev
    include ComponentBase

    private

    def default_attrs
      {
        name: "previous-month",
        aria_label: "Go to previous month",
        class: "rdp-button_reset rdp-button inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 border border-input hover:bg-accent hover:text-accent-foreground h-7 w-7 bg-transparent p-0 opacity-50 hover:opacity-100 absolute left-1",
        type: "button",
        data_action: "click->ruby-ui--calendar#prevMonth"
      }
    end
  end
end
