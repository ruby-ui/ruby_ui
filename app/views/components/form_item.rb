# frozen_string_literal: true

class FormItem < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(
            **@attributes,
            class:
                tokens("space-y-2", @attributes[:class]),
            &
        )
    end
end