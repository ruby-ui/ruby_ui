# frozen_string_literal: true

class ContextMenuContent < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        template_tag(data: { popover_target: "content" }) do
            div(
                **@attributes,
                role: "menu",
                aria_orientation: "vertical",
                data_state: "open",
                class:
                    tokens("z-50 min-w-[8rem] overflow-hidden rounded-md border bg-popover p-1 text-popover-foreground shadow-md data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2", @attributes[:class]),
                tabindex: "-1",
                data_orientation: "vertical",
                style:
                    "outline: none; pointer-events: auto;",
                &
            )
        end
    end
end