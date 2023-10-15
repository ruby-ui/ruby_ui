# frozen_string_literal: true

class Checkbox < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        input(
            **@attributes,
            type: "checkbox",
            class: tokens("peer h-4 w-4 shrink-0 rounded-sm border border-primary ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 accent-primary", @attributes[:class])
        )
    end
end