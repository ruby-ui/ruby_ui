# frozen_string_literal: true

module RubyUI
  class Tabs < Base
    def initialize(default: nil, **attrs)
      @default = default
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          controller: "rbui--tabs",
          rbui__tabs_active_value: @default
        }
      }
    end
  end
end
