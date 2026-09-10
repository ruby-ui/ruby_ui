# frozen_string_literal: true

module RubyUI
  class SheetContent < Base
    # Per side: release the opposite edge (a modal <dialog> is pinned to all four by inset: 0),
    # then the default size and the direction to slide in from.
    SIDE_CLASS = {
      top: "inset-x-0 top-0 bottom-auto w-full h-auto border-b data-[state=closed]:slide-out-to-top data-[state=open]:slide-in-from-top",
      right: "inset-y-0 right-0 left-auto h-full w-3/4 sm:max-w-sm border-l data-[state=closed]:slide-out-to-right data-[state=open]:slide-in-from-right",
      bottom: "inset-x-0 bottom-0 top-auto w-full h-auto border-t data-[state=closed]:slide-out-to-bottom data-[state=open]:slide-in-from-bottom",
      left: "inset-y-0 left-0 right-auto h-full w-3/4 sm:max-w-sm border-r data-[state=closed]:slide-out-to-left data-[state=open]:slide-in-from-left"
    }

    def initialize(side: :right, show_close_button: true, **attrs)
      @side = side
      @show_close_button = show_close_button
      super(**attrs)
    end

    def view_template(&block)
      dialog(**attrs) do
        block&.call
        close_button if @show_close_button
      end
    end

    private

    def default_attrs
      {
        data: {
          controller: "ruby-ui--sheet-content",
          ruby_ui__sheet_target: "dialog",
          action: "click->ruby-ui--sheet-content#backdropClick",
          side: @side
        },
        class: [
          # UA <dialog> reset; not-open:hidden keeps a caller's bare `flex` from overriding the display: none of a closed dialog.
          "m-0 max-w-full max-h-full not-open:hidden",
          "fixed pointer-events-auto z-50 gap-4 bg-background text-foreground p-6 shadow-lg transition ease-in-out overflow-scroll",
          "data-[state=open]:animate-in data-[state=open]:duration-500 data-[state=closed]:animate-out data-[state=closed]:duration-300 data-[state=closed]:fill-mode-forwards",
          # ::backdrop does not inherit the panel's --tw-duration; give it the same exit so both fade in step.
          "backdrop:bg-background/80 backdrop:backdrop-blur-sm data-[state=open]:backdrop:animate-in data-[state=open]:backdrop:fade-in-0 data-[state=closed]:backdrop:animate-out data-[state=closed]:backdrop:fade-out-0 data-[state=closed]:backdrop:duration-300 data-[state=closed]:backdrop:fill-mode-forwards",
          SIDE_CLASS[@side]
        ]
      }
    end

    def close_button
      button(
        type: "button",
        class: "absolute end-4 top-4 rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:pointer-events-none data-[state=open]:bg-accent data-[state=open]:text-muted-foreground",
        data_action: "click->ruby-ui--sheet-content#close"
      ) do
        svg(
          width: "15",
          height: "15",
          viewbox: "0 0 15 15",
          fill: "none",
          xmlns: "http://www.w3.org/2000/svg",
          class: "h-4 w-4"
        ) do |s|
          s.path(
            d:
                  "M11.7816 4.03157C12.0062 3.80702 12.0062 3.44295 11.7816 3.2184C11.5571 2.99385 11.193 2.99385 10.9685 3.2184L7.50005 6.68682L4.03164 3.2184C3.80708 2.99385 3.44301 2.99385 3.21846 3.2184C2.99391 3.44295 2.99391 3.80702 3.21846 4.03157L6.68688 7.49999L3.21846 10.9684C2.99391 11.193 2.99391 11.557 3.21846 11.7816C3.44301 12.0061 3.80708 12.0061 4.03164 11.7816L7.50005 8.31316L10.9685 11.7816C11.193 12.0061 11.5571 12.0061 11.7816 11.7816C12.0062 11.557 12.0062 11.193 11.7816 10.9684L8.31322 7.49999L11.7816 4.03157Z",
            fill: "currentColor",
            fill_rule: "evenodd",
            clip_rule: "evenodd"
          )
        end
        span(class: "sr-only") { "Close" }
      end
    end
  end
end
