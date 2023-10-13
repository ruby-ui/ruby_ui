# frozen_string_literal: true

class CardHeader < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(**@attributes, class: tokens("flex flex-col space-y-1.5 p-6", @attributes[:class]), &)
    end
end