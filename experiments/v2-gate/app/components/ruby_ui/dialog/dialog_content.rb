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

    private

    def default_attrs
      {
        data_ruby_ui__dialog_target: "dialog",
        data_action: "click->ruby-ui--dialog#backdropClick",
        class: [
          "fixed open:flex flex-col pointer-events-auto left-[50%] top-[50%] z-50 w-full max-h-screen overflow-y-auto translate-x-[-50%] translate-y-[-50%] gap-4 border bg-background p-6 shadow-lg duration-200 backdrop:bg-background/80 backdrop:backdrop-blur-sm open:animate-in open:fade-in-0 open:zoom-in-95 sm:rounded-lg md:w-full",
          SIZES[@size]
        ]
      }
    end
  end
end
