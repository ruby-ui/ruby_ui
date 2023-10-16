# frozen_string_literal: true

class FormSpacer < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(
            **@attributes,
            class:
                tokens("space-y-6", @attributes[:class]),
            &
        )
    end
end