# frozen_string_literal: true

class HoverCard < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
        @options = @attributes.delete(:options) || {}
        @options[:delay] ||= [500, 250]
        @options[:trigger] ||= 'mouseenter focus'
    end

    def template(&)
        div(**@attributes, data: { controller: "popover", popover_options_value: @options.to_json }, &)
    end
end