# frozen_string_literal: true

module RubyUI
  class SheetContent
    include ComponentBase

    SIDE_CLASS = {
      top: "inset-x-0 top-0 border-b data-[state=closed]:slide-out-to-top data-[state=open]:slide-in-from-top",
      right: "inset-y-0 right-0 h-full border-l data-[state=closed]:slide-out-to-right data-[state=open]:slide-in-from-right",
      bottom: "inset-x-0 bottom-0 border-t data-[state=closed]:slide-out-to-bottom data-[state=open]:slide-in-from-bottom",
      left: "inset-y-0 left-0 h-full border-r data-[state=closed]:slide-out-to-left data-[state=open]:slide-in-from-left"
    }.freeze

    attr_reader :side

    def initialize(side: :right, **attrs)
      @side = side
      @side_classes = SIDE_CLASS[side]
      super(**attrs)
    end

    def backdrop_attrs
      {
        data_state: "open",
        data_action: "click->ruby-ui--sheet-content#close",
        class: "fixed pointer-events-auto inset-0 z-50 bg-background/80 backdrop-blur-sm data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0"
      }
    end

    def close_button_attrs
      {
        type: "button",
        class: "absolute end-4 top-4 rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:pointer-events-none data-[state=open]:bg-accent data-[state=open]:text-muted-foreground",
        data_action: "click->ruby-ui--sheet-content#close"
      }
    end

    private

    def default_attrs
      {
        data_state: "open",
        class: [
          "fixed pointer-events-auto z-50 gap-4 bg-background p-6 shadow-lg transition ease-in-out data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:duration-300 data-[state=open]:duration-500 overflow-scroll",
          @side_classes
        ]
      }
    end
  end
end
