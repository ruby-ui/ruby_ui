# frozen_string_literal: true

module RubyUI
  class Popover < Base
    def initialize(options: {}, **attrs)
      @options = options
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          controller: "rbui--popover",
          rbui__popover_options_value: @options.to_json,
          rbui__popover_trigger_value: @options[:trigger] || "hover"
        }
      }
    end
  end
end
