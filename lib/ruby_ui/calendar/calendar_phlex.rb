# frozen_string_literal: true

module RubyUI
  class Calendar < Base
    def initialize(selected_date: nil, input_id: nil, date_format: "yyyy-MM-dd", **attrs)
      @selected_date = selected_date
      @input_id = input_id
      @date_format = date_format
      super(**attrs)
    end

    def view_template(&)
      div(**attrs) do
        render RubyUI::CalendarHeader.new do
          render RubyUI::CalendarTitle.new

          render RubyUI::CalendarPrev.new

          render RubyUI::CalendarNext.new
        end

        render RubyUI::CalendarBody.new

        render RubyUI::CalendarWeekdays.new

        render RubyUI::CalendarDays.new
      end
    end

    private

    def default_attrs
      {
        class: "p-3 space-y-4",
        data: {
          controller: "ruby-ui--calendar",
          ruby_ui__calendar_selected_date_value: @selected_date&.to_s,
          ruby_ui__calendar_format_value: @date_format,
          ruby_ui__calendar_ruby_ui__calendar_input_outlet: @input_id
        }
      }
    end
  end
end
