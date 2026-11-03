# frozen_string_literal: true

module RubyUI
  # The card. A native popover (top layer, so no ancestor clips it) placed
  # next to the trigger by Floating UI. side:/align: pick the placement,
  # side_offset:/align_offset: the gap, with the defaults of shadcn's
  # HoverCardContent. Without side:/align:, HoverCard's option placement:
  # applies, then bottom/center.
  class HoverCardContent < Base
    SIDES = %i[top right bottom left].freeze
    ALIGNS = %i[start center end].freeze

    def initialize(side: nil, side_offset: 4, align: nil, align_offset: 4, **attrs)
      @side = SIDES.include?(side&.to_sym) ? side.to_sym : nil
      @align = ALIGNS.include?(align&.to_sym) ? align.to_sym : nil
      @side_offset = side_offset
      @align_offset = align_offset
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        popover: "manual",
        data: {
          slot: "hover-card-content",
          ruby_ui__hover_card_target: "content",
          # Kept in sync with data-open/data-closed for CSS that targets data-[state=...].
          state: "closed",
          closed: "",
          preferred_side: @side,
          preferred_align: @align,
          side_offset: @side_offset,
          align_offset: @align_offset
        },
        class: [
          "fixed inset-auto m-0 border-0 z-50 w-64 origin-(--transform-origin) outline-hidden",
          "bg-popover text-popover-foreground ring-1 ring-foreground/10 rounded-lg p-4 text-sm shadow-md duration-100",
          "data-open:animate-in data-open:fade-in-0 data-open:zoom-in-95",
          "data-closed:animate-out data-closed:fade-out-0 data-closed:zoom-out-95 data-closed:fill-mode-forwards",
          "data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2",
          "data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2"
        ]
      }
    end
  end
end
