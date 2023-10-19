# frozen_string_literal: true

class CommandItem < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
        @value = attributes.delete(:value)
    end

    def template(&)
        div(
            class:
                "relative flex cursor-default select-none items-center gap-x-2 rounded-sm px-2 py-1.5 text-sm outline-none hover:bg-accent hover:text-accent-foreground aria-selected:bg-accent aria-selected:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
            cmdk_item: "",
            role: "option",
            data: { command_target: "item", value: @value },
            # aria_selected: "true",
            data_selected: "true",
            &
        )
    end
end