# frozen_string_literal: true

module RubyUI
  # An inline month calendar, styled after shadcn's Calendar (Base UI + vega).
  # The days are rendered by the ruby-ui--calendar Stimulus controller from the
  # templates in CalendarWeekdays and CalendarDays.
  #
  # week_starts_on: :sunday (default, as in shadcn) through :saturday, or 0-6.
  class Calendar < Base
    WEEKDAYS = %i[sunday monday tuesday wednesday thursday friday saturday].freeze

    def initialize(selected_date: nil, min_date: nil, input_id: nil, date_format: "yyyy-MM-dd", week_starts_on: :sunday, **attrs)
      @selected_date = selected_date
      @min_date = min_date
      @input_id = input_id
      @date_format = date_format
      @week_starts_on = self.class.week_start_index(week_starts_on)
      super(**attrs)
    end

    def self.week_start_index(value)
      index = value.is_a?(Integer) ? value : WEEKDAYS.index(value.to_s.to_sym)
      raise ArgumentError, "week_starts_on must be one of #{WEEKDAYS.join(", ")} or 0-6, got #{value.inspect}" unless index&.between?(0, 6)

      index
    end

    def view_template
      div(**attrs) do
        RubyUI.CalendarHeader do
          nav(aria_label: "Navigation bar", class: "absolute inset-x-0 top-0 flex w-full items-center justify-between gap-1") do
            RubyUI.CalendarPrev
            RubyUI.CalendarNext
          end
          RubyUI.CalendarTitle
        end
        RubyUI.CalendarBody # Where the calendar is rendered (Weekdays and Days)
        RubyUI.CalendarWeekdays(week_starts_on: @week_starts_on) # Template for the weekdays
        RubyUI.CalendarDays # Template for the days
      end
    end

    private

    def default_attrs
      {
        class: "w-fit bg-background p-3 in-data-[slot=card-content]:bg-transparent in-data-[slot=popover-content]:bg-transparent",
        data: {
          controller: "ruby-ui--calendar",
          ruby_ui__calendar_selected_date_value: @selected_date&.to_s,
          ruby_ui__calendar_min_date_value: @min_date&.to_s,
          ruby_ui__calendar_format_value: @date_format,
          ruby_ui__calendar_week_starts_on_value: @week_starts_on,
          ruby_ui__calendar_ruby_ui__calendar_input_outlet: @input_id
        }
      }
    end
  end
end
