# frozen_string_literal: true

class DropdownMenuSeparator < ApplicationComponent
    def template(&)
        div(
            role: "separator",
            aria_orientation: "horizontal",
            class: "-mx-1 my-1 h-px bg-muted"
        )
    end
end