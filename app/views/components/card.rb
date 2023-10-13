# frozen_string_literal: true

class Card < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(**@attributes, class: tokens("rounded-xl border bg-card text-card-foreground shadow", @attributes[:class]), &)
    end
end