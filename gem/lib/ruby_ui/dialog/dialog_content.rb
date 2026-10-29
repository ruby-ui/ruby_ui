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

    DEFAULT_WIDTH = "max-w-[calc(100%-2rem)] sm:max-w-md"

    def initialize(size: nil, show_close_button: true, **attrs)
      @size = size
      @show_close_button = show_close_button
      super(**attrs)
    end

    def view_template
      dialog(**attrs) do
        yield
        close_button if @show_close_button
      end
    end

    private

    def default_attrs
      {
        data_ruby_ui__dialog_target: "dialog",
        data_action: "pointerdown->ruby-ui--dialog#backdropPointerdown click->ruby-ui--dialog#backdropClick",
        class: [
          "fixed open:grid top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-50 w-full gap-6 rounded-xl bg-popover p-6 text-sm text-popover-foreground outline-none ring-1 ring-foreground/10 backdrop:bg-black/10 supports-backdrop-filter:backdrop:backdrop-blur-xs",
          "duration-100 data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 motion-reduce:animate-none!",
          "backdrop:duration-100 data-[state=open]:backdrop:animate-in data-[state=open]:backdrop:fade-in-0 data-[state=closed]:backdrop:animate-out data-[state=closed]:backdrop:fade-out-0 motion-reduce:backdrop:animate-none!",
          @size ? SIZES[@size] : DEFAULT_WIDTH
        ]
      }
    end

    def close_button
      button(
        type: "button",
        class: "absolute top-4 right-4 size-8 rounded-[min(var(--radius-md),10px)] inline-flex items-center justify-center outline-none transition-all hover:bg-muted hover:text-foreground dark:hover:bg-muted/50 focus-visible:ring-3 focus-visible:ring-ring/50 [&_svg]:size-4",
        data_action: "click->ruby-ui--dialog#dismiss"
      ) do
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          viewbox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          stroke_width: "2",
          stroke_linecap: "round",
          stroke_linejoin: "round"
        ) do |s|
          s.path(d: "M18 6 6 18")
          s.path(d: "m6 6 12 12")
        end
        span(class: "sr-only") { "Close" }
      end
    end
  end
end
