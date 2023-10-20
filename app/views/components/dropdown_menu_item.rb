# frozen_string_literal: true

class DropdownMenuItem < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
        @href = @attributes.delete(:href)
    end

    def template(&)
        a(
            **@attributes,
            href: @href,
            role: "menuitem",
            class: tokens("relative flex cursor-pointer select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none transition-colors hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground aria-selected:bg-accent aria-selected:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50", @attributes[:class]),
            data_action: "click->popover#close",
            data_popover_target: "menuItem",
            tabindex: "-1",
            data_orientation: "vertical",
            &
        )
    end
end