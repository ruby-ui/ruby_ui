# frozen_string_literal: true

module RubyUI
  # The menu. A native popover (top layer), opened at the pointer and placed
  # by Floating UI; side:/align: pick the placement, side_offset:/align_offset:
  # the gap, with the defaults of shadcn's ContextMenuContent.
  class ContextMenuContent < Base
    SIDES = %i[top right bottom left].freeze
    ALIGNS = %i[start center end].freeze

    def initialize(side: :right, side_offset: 0, align: :start, align_offset: 4, **)
      @side = SIDES.include?(side.to_sym) ? side.to_sym : :right
      @side_offset = side_offset
      @align = ALIGNS.include?(align.to_sym) ? align.to_sym : :start
      @align_offset = align_offset
      super(**)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        role: "menu",
        tabindex: "-1",
        popover: "manual",
        data: {
          slot: "context-menu-content",
          ruby_ui__context_menu_target: "content",
          action: "keydown->ruby-ui--context-menu#keydown",
          closed: "",
          side: @side,
          align: @align,
          preferred_side: @side,
          side_offset: @side_offset,
          align_offset: @align_offset
        },
        class: [
          "fixed inset-auto m-0 border-0 z-50 max-h-(--available-height) origin-(--transform-origin)",
          "overflow-x-hidden overflow-y-auto outline-none",
          "bg-popover text-popover-foreground ring-1 ring-foreground/10 min-w-36 rounded-md p-1 shadow-md duration-100",
          "data-open:animate-in data-open:fade-in-0 data-open:zoom-in-95",
          "data-closed:animate-out data-closed:fade-out-0 data-closed:zoom-out-95 data-closed:fill-mode-forwards",
          "data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2",
          "data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2"
        ]
      }
    end
  end
end
