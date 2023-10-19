# frozen_string_literal: true

class CommandItem < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
        @value = attributes.delete(:value)
        @text = attributes.delete(:text) || ""
        @href = attributes.delete(:href) || "#"
    end

    def template(&)
        a(
            **@attributes,
            class:
                tokens("relative flex cursor-pointer select-none items-center gap-x-2 rounded-sm px-2 py-1.5 text-sm outline-none hover:bg-accent hover:text-accent-foreground aria-selected:bg-accent aria-selected:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50", @attributes[:class]),
            href: @href,
            role: "option",
            data: { command_target: "item", value: @value, text: @text },
            # aria_selected: "true", # Toggles aria-selected="true" on keydown
        ) do
            yield
        end
    end
end