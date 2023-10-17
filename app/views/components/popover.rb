# frozen_string_literal: true

class Popover < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
        @options = @attributes.delete(:options) || {}
    end

    def template(&)
        div(**@attributes, data: { controller: "popover", popover_options_value: @options.to_json }, &)
    end
end