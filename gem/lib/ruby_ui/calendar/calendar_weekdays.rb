# frozen_string_literal: true

module RubyUI
  class CalendarWeekdays < Base
    DAYS = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze

    def initialize(week_starts_on: 0, **attrs)
      @week_starts_on = RubyUI::Calendar.week_start_index(week_starts_on)
      super(**attrs)
    end

    def view_template
      template(data: {ruby_ui__calendar_target: "weekdaysTemplate"}) do
        # As in shadcn, the column headers are hidden: each day button carries
        # its full date as its accessible name.
        thead(**attrs) do
          tr(class: "flex") do
            DAYS.rotate(@week_starts_on).each do |day|
              render_day(day)
            end
          end
        end
      end
    end

    private

    def render_day(day)
      th(
        scope: "col",
        class: "w-8 rounded-md text-[0.8rem] font-normal text-muted-foreground select-none",
        aria_label: day
      ) { day[0..1] }
    end

    def default_attrs
      {aria_hidden: "true"}
    end
  end
end
