# frozen_string_literal: true

class Label < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        label(
            **@attributes,
            class:
                tokens("text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70", @attributes[:class]),
            &
        )
    end
end