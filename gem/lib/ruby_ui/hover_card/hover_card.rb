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
        class: [
          "group/hover-card",
          (strategy == "absolute") ? "is-absolute" : "is-fixed"
        ],
        data: {
          controller: "ruby-ui--hover-card",
          ruby_ui__hover_card_options_value: @options.to_json
        }
      }
    end

    # An ancestor with `overflow: hidden` clips an absolutely positioned card;
    # `strategy: "fixed"` positions it against the viewport instead.
    def strategy
      @_strategy ||= @options[:strategy] || "absolute"
    end
  end
end
