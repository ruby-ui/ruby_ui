# frozen_string_literal: true

class CardTitle < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        h3(**@attributes, class: tokens("font-semibold leading-none tracking-tight", @attributes[:class]), &)
    end
end