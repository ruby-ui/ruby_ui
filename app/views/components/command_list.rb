# frozen_string_literal: true

class CommandList < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(**@attributes, &)
    end
end