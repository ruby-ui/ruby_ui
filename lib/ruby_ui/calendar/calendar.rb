# frozen_string_literal: true

module RubyUI
  class Calendar < Base
    def initialize(selected_date: nil, input_id: nil, date_format: 'yyyy-MM-dd', **attrs)
      @selected_date = selected_date
      @input_id = input_id
      @date_format = date_format
      super(**attrs)
    end

    def view_template
      div(**attrs) do
        RubyUI.CalendarHeader do
          RubyUI.CalendarTitle
          RubyUI.CalendarPrev
          RubyUI.CalendarNext
        end
        RubyUI.CalendarBody # Where the calendar is rendered (Weekdays and Days)
        RubyUI.CalendarWeekdays # Template for the weekdays
        RubyUI.CalendarDays # Template for the days
      end
    end

    private

    def default_attrs
      {
        class: 'p-3 space-y-4',
        data: {
          controller: 'ruby-ui--calendar',
          ruby_ui__calendar_selected_date_value: @selected_date&.to_s,
          ruby_ui__calendar_format_value: @date_format,
          ruby_ui__calendar_ruby_ui__calendar_input_outlet: @input_id
        }
      }
    end
  end
end
