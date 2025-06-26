# frozen_string_literal: true

module RubyUI
  class DialogContent < Base
    SIZES = {
      xs: "max-w-sm",
      sm: "max-w-md",
      md: "max-w-lg",
      lg: "max-w-2xl",
      xl: "max-w-4xl",
      full: "max-w-full"
    }

    def initialize(size: :md, **attrs)
      @size = size
      super(**attrs)
    end

    def view_template
      template(data: {ruby_ui__dialog_target: "content"}) do
        div(data_controller: "ruby-ui--dialog") do
          backdrop
          div(**attrs) do
            yield
            close_button
          end
        end
      end
    end

    private

    def default_attrs
      {
        data_state: "open",
        class: [
          "fixed flex flex-col pointer-events-auto left-[50%] top-[50%] z-50 w-full max-h-screen overflow-y-auto translate-x-[-50%] translate-y-[-50%] gap-4 border bg-background p-6 shadow-lg duration-200 data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95 sm:rounded-lg md:w-full",
          SIZES[@size]
        ]
      }
    end

    def close_button
      button(
        type: "button",
        class: "absolute end-4 top-4 rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:pointer-events-none data-[state=open]:bg-accent data-[state=open]:text-muted-foreground",
        data_action: "click->ruby-ui--dialog#dismiss"
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

    def backdrop
      div(
        data_state: "open",
        data_action: "click->ruby-ui--dialog#dismiss esc->ruby-ui--dialog#dismiss",
        class: "fixed pointer-events-auto inset-0 z-50 bg-background/80 backdrop-blur-sm data-[state=open]:animate-in data-[state=open]:fade-in-0"
      )
    end
  end
end
