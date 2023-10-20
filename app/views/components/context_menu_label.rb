# frozen_string_literal: true

class ContextMenuLabel < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
        @inset = attributes.delete(:inset) || false
    end

    def template(&)
        div(
            **@attributes,
            class: tokens("px-2 py-1.5 text-sm font-semibold text-foreground", @attributes[:class], inset?: "pl-8"),
            &
        )
    end

    private

    def inset? = @inset
end