# frozen_string_literal: true

module RubyUI
  class CommandDialogContent < Base
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

    def view_template(&block)
      template(data: {ruby_ui__command_target: "content"}) do
        div(data: {controller: "ruby-ui--command"}) do
          backdrop
          div(**attrs, &block)
        end
      end
    end

    private

    def default_attrs
      {
        data_state: "open",
        class: [
          "fixed pointer-events-auto left-[50%] top-[50%] z-50 grid w-full translate-x-[-50%] translate-y-[-50%] gap-4 border bg-background shadow-lg duration-200 data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[state=closed]:slide-out-to-left-1/2 data-[state=closed]:slide-out-to-top-[48%] data-[state=open]:slide-in-from-left-1/2 data-[state=open]:slide-in-from-top-[48%] sm:rounded-lg md:w-full",
          SIZES[@size]
        ]
      }
    end

    def backdrop
      div(
        data_state: "open",
        data_action: "click->ruby-ui--command#dismiss esc->ruby-ui--command#dismiss",
        class: "fixed pointer-events-auto inset-0 z-50 bg-background/80 backdrop-blur-sm data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0"
      )
    end
  end
end
