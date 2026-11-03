# frozen_string_literal: true

module RubyUI
  class CalendarHeader < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "relative mb-4 flex h-8 w-full items-center justify-center px-8"
      }
    end
  end
end
