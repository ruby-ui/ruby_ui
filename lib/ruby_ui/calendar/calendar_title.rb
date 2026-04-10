# frozen_string_literal: true

module RubyUI
  class CalendarTitle
    include ComponentBase

    def initialize(default: "Month Year", **attrs)
      @default = default
      super(**attrs)
    end

    def default_text
      @default
    end

    private

    def default_attrs
      {
        class: "text-sm font-medium",
        aria_live: "polite",
        role: "presentation",
        data: {
          ruby_ui__calendar_target: "title"
        }
      }
    end
  end
end
