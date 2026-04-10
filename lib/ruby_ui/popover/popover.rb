# frozen_string_literal: true

module RubyUI
  class Popover
    include ComponentBase

    def initialize(options: {}, **attrs)
      @options = options
      super(**attrs)
    end

    private

    def default_attrs
      {
        data: {
          controller: "ruby-ui--popover",
          ruby_ui__popover_options_value: @options.to_json,
          ruby_ui__popover_trigger_value: @options[:trigger] || "hover"
        }
      }
    end
  end
end
