# frozen_string_literal: true

class TooltipContent < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        template_tag(data: { popover_target: "content" }) do
            div(**@attributes, data: { state: :open }, class: tokens("z-50 rounded-md text-sm border bg-popover px-2 py-0.5 text-popover-foreground shadow-md outline-none data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2", @attributes[:class]), &)
        end
    end
end