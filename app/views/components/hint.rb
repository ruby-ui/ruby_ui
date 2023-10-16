# frozen_string_literal: true

class Hint < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        p(
            **@attributes,
            class:
                tokens("text-[0.8rem] text-muted-foreground", @attributes[:class]),
            &
        )
    end
end