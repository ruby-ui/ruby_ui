# frozen_string_literal: true

class Dialog < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(**@attributes, data: { controller: "dialog"}, &)
    end
end