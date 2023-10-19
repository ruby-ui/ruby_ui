# frozen_string_literal: true

class CommandEmpty < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(
            **@attributes,
            class:
                tokens("py-6 text-center text-sm", @attributes[:class]),
            role: "presentation",
            data: { command_target: "empty" },
            &
        )
    end
end