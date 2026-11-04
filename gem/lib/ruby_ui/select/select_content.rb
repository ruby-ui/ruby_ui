# frozen_string_literal: true

require "securerandom"

module RubyUI
  # The list. A native popover (top layer) with role=listbox, positioned next
  # to the trigger by Floating UI; side:/align: pick the placement and
  # side_offset:/align_offset: the gap, as in shadcn's SelectContent. Like
  # shadcn's default (alignItemWithTrigger), it doesn't animate.
  class SelectContent < Base
    SIDES = %i[top right bottom left].freeze
    ALIGNS = %i[start center end].freeze

    # outlet_id: is accepted for backwards compatibility and ignored.
    def initialize(side: :bottom, side_offset: 4, align: :center, align_offset: 0, outlet_id: nil, **)
      @side = SIDES.include?(side.to_sym) ? side.to_sym : :bottom
      @side_offset = side_offset
      @align = ALIGNS.include?(align.to_sym) ? align.to_sym : :center
      @align_offset = align_offset
      super(**)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        id: "select-content-#{SecureRandom.hex(4)}",
        role: "listbox",
        tabindex: "-1",
        popover: "manual",
        data: {
          slot: "select-content",
          ruby_ui__select_target: "content",
          action: "keydown->ruby-ui--select#listKeydown",
          closed: "",
          side: @side,
          align: @align,
          preferred_side: @side,
          side_offset: @side_offset,
          align_offset: @align_offset
        },
        class: [
          "fixed inset-auto m-0 border-0 p-0 outline-none",
          "isolate z-50 min-w-36 w-(--anchor-width) max-h-(--available-height) origin-(--transform-origin)",
          "overflow-x-hidden overflow-y-auto rounded-md bg-popover text-popover-foreground shadow-md ring-1 ring-foreground/10"
        ]
      }
    end
  end
end
