# frozen_string_literal: true

module RubyUI
  class TooltipContent < Base
    def initialize(**attrs)
      @id = "tooltip#{SecureRandom.hex(4)}"
      super
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        id: @id,
        data: {
          ruby_ui__tooltip_target: "content"
        },
        class: "invisible peer-hover:visible peer-focus:visible w-max absolute top-0 left-0 z-50 overflow-hidden rounded-md border bg-popover px-3 py-1.5 text-sm text-popover-foreground shadow-md peer-focus:zoom-in-95 animate-out fade-out-0 zoom-out-95 peer-hover:animate-in peer-focus:animate-in peer-hover:fade-in-0 peer-focus:fade-in-0 peer-hover:zoom-in-95 group-data-[ruby-ui--tooltip-placement-value=bottom]:slide-in-from-top-2 group-data-[ruby-ui--tooltip-placement-value=left]:slide-in-from-right-2 group-data-[ruby-ui--tooltip-placement-value=right]:slide-in-from-left-2 group-data-[ruby-ui--tooltip-placement-value=top]:slide-in-from-bottom-2 delay-500"
      }
    end
  end
end
