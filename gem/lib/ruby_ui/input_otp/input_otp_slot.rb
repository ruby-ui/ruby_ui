# frozen_string_literal: true

module RubyUI
  class InputOtpSlot < Base
    def initialize(index:, **attrs)
      @index = index
      super(**attrs)
    end

    def view_template
      div(**attrs)
    end

    private

    def default_attrs
      {
        aria_hidden: "true",
        data: {
          ruby_ui__input_otp_target: "slot",
          index: @index
        },
        class: [
          "relative flex h-9 w-9 items-center justify-center border-y border-r border-input text-sm shadow-xs transition-all",
          "first:rounded-l-md first:border-l last:rounded-r-md",
          "data-[active=true]:z-10 data-[active=true]:border-ring data-[active=true]:ring-2 data-[active=true]:ring-ring/50",
          "data-[caret=true]:after:content-[''] data-[caret=true]:after:absolute data-[caret=true]:after:h-4 data-[caret=true]:after:w-px data-[caret=true]:after:animate-caret-blink data-[caret=true]:after:bg-foreground"
        ]
      }
    end
  end
end
