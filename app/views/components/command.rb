# frozen_string_literal: true

class Command < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(**@attributes, data: { controller: "command" }, &)
    end
end