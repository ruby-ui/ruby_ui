# frozen_string_literal: true

module RubyUI
  class CalendarBody < Base
    def view_template
      table(**attrs)
    end

    private

    # The controller fills the grid and sets aria-label to the month and year.
    def default_attrs
      {
        role: "grid",
        class: "w-full border-collapse",
        data: {
          ruby_ui__calendar_target: "calendar",
          action: "keydown->ruby-ui--calendar#navigate"
        }
      }
    end
  end
end
