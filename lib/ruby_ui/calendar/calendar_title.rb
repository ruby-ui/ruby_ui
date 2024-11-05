# frozen_string_literal: true

module RubyUI
  class CalendarTitle < Base
    def initialize(default: "Month Year", **attrs)
      @default = default
      super(**attrs)
    end

    def view_template
      div(**attrs) { @default }
    end

    private

    def default_attrs
      {
        class: "text-sm font-medium",
        aria_live: "polite",
        role: "presentation",
        data: {
          rbui__calendar_target: "title"
        }
      }
    end
  end
end
