# frozen_string_literal: true

module RubyUI
  # Mustache templates the ruby-ui--calendar controller renders each day with.
  # Placeholders: {{date}} (yyyy-mm-dd), {{dayDate}} (day of month),
  # {{label}} (full date, e.g. "Monday, March 16th, 2026") and {{tabindex}}
  # (0 on the one day in the Tab sequence, -1 elsewhere).
  class CalendarDays < Base
    BASE_CLASS = "inline-flex size-8 items-center justify-center rounded-md border-0 border-transparent p-0 text-sm leading-none font-normal whitespace-nowrap " \
      "transition-all outline-none select-none focus-visible:relative focus-visible:z-10 " \
      "focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50"
    HOVER_CLASS = "hover:bg-muted hover:text-foreground dark:hover:bg-muted/50"
    CELL_CLASS = "relative rounded-md p-0 text-center select-none"

    def view_template
      render_disabled_date_template
      render_selected_date_template
      render_today_date_template
      render_current_month_date_template
      render_other_month_date_template
    end

    private

    def render_disabled_date_template
      date_template("disabledDateTemplate") do
        day_button([BASE_CLASS, "text-muted-foreground"], disabled: true, tabindex: "-1", data: {action: nil})
      end
    end

    def render_selected_date_template
      date_template("selectedDateTemplate", aria_selected: "true") do
        day_button([BASE_CLASS, "bg-primary text-primary-foreground hover:bg-primary hover:text-primary-foreground"])
      end
    end

    def render_today_date_template
      date_template("todayDateTemplate", cell_class: [CELL_CLASS, "rounded-md bg-muted text-foreground"]) do
        day_button([BASE_CLASS, "text-foreground", HOVER_CLASS])
      end
    end

    def render_current_month_date_template
      date_template("currentMonthDateTemplate") do
        day_button([BASE_CLASS, "text-foreground", HOVER_CLASS])
      end
    end

    def render_other_month_date_template
      date_template("otherMonthDateTemplate") do
        day_button([BASE_CLASS, "text-muted-foreground", HOVER_CLASS])
      end
    end

    def day_button(classes, tabindex: "{{tabindex}}", **options)
      data = {day: "{{date}}", action: "click->ruby-ui--calendar#selectDay"}.merge(options.delete(:data) || {}).compact
      button(
        type: "button",
        name: "day",
        class: classes,
        tabindex: tabindex,
        aria_label: "{{label}}",
        data: data,
        **options
      ) { "{{dayDate}}" }
    end

    def date_template(target, cell_class: CELL_CLASS, **cell_attrs, &block)
      template(data: {ruby_ui__calendar_target: target}) do
        td(class: cell_class, role: "gridcell", **cell_attrs, &block)
      end
    end

    def default_attrs
      {}
    end
  end
end
