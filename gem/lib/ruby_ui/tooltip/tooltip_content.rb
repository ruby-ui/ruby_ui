# frozen_string_literal: true

module RubyUI
  class TooltipContent < Base
    def initialize(**attrs)
      @id = "tooltip#{SecureRandom.hex(4)}"
      super
    end

    def view_template(&)
      template(data: {ruby_ui__tooltip_target: "content"}) do
        div(**attrs, &)
      end
    end

    private

    def default_attrs
      {
        id: @id,
        class: [
          "invisible pointer-events-none w-fit max-w-[calc(100vw-2rem)] text-balance break-words absolute top-0 left-0 z-50 overflow-hidden rounded-md border bg-popover px-3 py-1.5 text-sm text-popover-foreground shadow-md",
          "data-[placement=bottom]:slide-in-from-top-2",
          "data-[placement=left]:slide-in-from-right-2",
          "data-[placement=right]:slide-in-from-left-2",
          "data-[placement=top]:slide-in-from-bottom-2",
          "data-[state=open]:visible data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95",
          "data-[state=closed]:visible data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 data-[state=closed]:fill-mode-forwards"
        ]
      }
    end
  end
end
