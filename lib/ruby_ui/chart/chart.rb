# frozen_string_literal: true

module RubyUI
  class Chart
    include ComponentBase

    def initialize(options: {}, **attrs)
      @options = options.to_json
      super(**attrs)
    end

    private

    def default_attrs
      {
        data_controller: "ruby-ui--chart",
        data_ruby_ui__chart_options_value: @options
      }
    end
  end
end
