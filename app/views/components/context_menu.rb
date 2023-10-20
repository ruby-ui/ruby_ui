# frozen_string_literal: true

class ContextMenu < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
        @options = @attributes.delete(:options) || {}
        @options[:trigger] ||= "manual"
    end

    def template(&)
        div(**@attributes, data: { controller: "popover", popover_options_value: @options.to_json }, &)
    end
end