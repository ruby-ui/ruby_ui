# frozen_string_literal: true

class ContextMenuSeparator < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template
        div(
            **@attributes,
            role: "separator",
            aria_orientation: "horizontal",
            class: "-mx-1 my-1 h-px bg-border"
        )
    end
end