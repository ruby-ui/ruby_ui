# frozen_string_literal: true

module RubyUI
  class CalendarDays
    include ComponentBase

    BASE_CLASS = "inline-flex items-center justify-center rounded-md text-sm ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 h-8 w-8 p-0 font-normal aria-selected:opacity-100"

    TD_CLASS = "relative p-0 text-center text-sm focus-within:relative focus-within:z-20 [&:has([aria-selected])]:bg-accent [&:has([aria-selected])]:rounded-md"

    def selected_date_button_class
      "#{BASE_CLASS} bg-primary text-primary-foreground hover:bg-primary hover:text-primary-foreground focus:bg-primary focus:text-primary-foreground"
    end

    def today_date_button_class
      "#{BASE_CLASS} bg-accent text-accent-foreground hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground"
    end

    def current_month_button_class
      "#{BASE_CLASS} bg-background text-foreground hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground"
    end

    def other_month_button_class
      "#{BASE_CLASS} bg-background text-muted-foreground hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground"
    end

    def td_class
      TD_CLASS
    end
  end
end
