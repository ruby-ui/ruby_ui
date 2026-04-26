# frozen_string_literal: true

module RubyUI
  class CalendarDays < Base
    BASE_CLASS = "inline-flex items-center justify-center rounded-md text-sm ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 h-8 w-8 p-0 font-normal aria-selected:opacity-100"

    def view_template
      render_selected_date_template
      render_today_date_template
      render_current_month_date_template
      render_other_month_date_template
    end

    private

    def render_selected_date_template
      date_template("selectedDateTemplate") do
        button(
          data_day: "{{day}}",
          data_action: "click->ruby-ui--calendar#selectDay",
          name: "day",
          class:
                [
                  BASE_CLASS,
                  "bg-primary text-primary-foreground hover:bg-primary hover:text-primary-foreground focus:bg-primary focus:text-primary-foreground"
                ],
          role: "gridcell",
          tabindex: "0",
          type: "button",
          aria_selected: "true"
        ) { "{{dayDate}}" }
      end
    end

    def render_today_date_template
      date_template("todayDateTemplate") do
        button(
          data_day: "{{day}}",
          data_action: "click->ruby-ui--calendar#selectDay",
          name: "day",
          class:
                [
                  BASE_CLASS,
                  "bg-accent text-accent-foreground hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground"
                ],
          role: "gridcell",
          tabindex: "-1",
          type: "button"
        ) { "{{dayDate}}" }
      end
    end

    def render_current_month_date_template
      date_template("currentMonthDateTemplate") do
        button(
          data_day: "{{day}}",
          data_action: "click->ruby-ui--calendar#selectDay",
          name: "day",
          class:
                [
                  BASE_CLASS,
                  "bg-background text-foreground hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground"
                ],
          role: "gridcell",
          tabindex: "-1",
          type: "button"
        ) { "{{dayDate}}" }
      end
    end

    def render_other_month_date_template
      date_template("otherMonthDateTemplate") do
        button(
          data_day: "{{day}}",
          data_action: " click->ruby-ui--calendar#selectDay",
          name: "day",
          class:
                [
                  BASE_CLASS,
                  "bg-background text-muted-foreground hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground"
                ],
          role: "gridcell",
          tabindex: "-1",
          type: "button"
        ) { "{{dayDate}}" }
      end
    end

    def date_template(target, &block)
      template(data: {ruby_ui__calendar_target: target}) do
        td(
          class:
                "relative p-0 text-center text-sm focus-within:relative focus-within:z-20 [&:has([aria-selected])]:bg-accent [&:has([aria-selected])]:rounded-md",
          role: "presentation",
          &block
        )
      end
    end

    def default_attrs
      {}
    end
  end
end
