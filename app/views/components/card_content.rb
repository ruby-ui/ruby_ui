# frozen_string_literal: true

class CardContent < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(**@attributes, class: tokens("p-6 pt-0", @attributes[:class]), &)
    end
end