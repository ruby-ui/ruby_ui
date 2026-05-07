# frozen_string_literal: true

module RubyUI
  class HoverCard < Base
    def initialize(option: {}, **attrs)
      @options = option
      @options[:delay] ||= [500, 250]
      @options[:trigger] ||= "mouseenter focus click"
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          controller: "ruby-ui--hover-card",
          ruby_ui__hover_card_options_value: @options.to_json
        }
      }
    end
  end
end
