# frozen_string_literal: true

module RubyUI
  class BubbleReactions < Base
    SIDES = {
      top: "top-0 -translate-y-3/4",
      bottom: "bottom-0 translate-y-3/4"
    }

    ALIGNS = {
      start: "left-3",
      end: "right-3"
    }

    def initialize(side: :bottom, align: :end, **attrs)
      @side = side
      @align = align
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "bubble-reactions", side: @side, align: @align},
        class: [
          "absolute z-10 flex w-fit items-center justify-center rounded-full ring-3 ring-card bg-muted shrink-0 gap-1 px-1.5 py-0.5 has-[button]:p-0 text-sm",
          SIDES[@side],
          ALIGNS[@align]
        ]
      }
    end
  end
end
