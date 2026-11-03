# frozen_string_literal: true

module RubyUI
  # The submenu. A native popover placed next to its DropdownMenuSubTrigger,
  # with the defaults of shadcn's DropdownMenuSubContent (right, start, 0, -3).
  class DropdownMenuSubContent < Base
    SIDES = DropdownMenuContent::SIDES
    ALIGNS = DropdownMenuContent::ALIGNS

    def initialize(side: :right, align: :start, side_offset: 0, align_offset: -3, **)
      @side = SIDES.include?(side.to_sym) ? side.to_sym : :right
      @align = ALIGNS.include?(align.to_sym) ? align.to_sym : :start
      @side_offset = side_offset
      @align_offset = align_offset
      super(**)
    end

    def view_template(&)
      div(**mix(sub_attrs, attrs), &)
    end

    private

    # The ids come from the DropdownMenuSub around it, known only while rendering.
    def sub_attrs
      id = context[:ruby_ui_dropdown_menu_sub]
      return {} unless id

      {id: "#{id}-content", aria: {labelledby: "#{id}-trigger"}}
    end

    def default_attrs
      {
        role: "menu",
        tabindex: "-1",
        popover: "manual",
        data: {
          slot: "dropdown-menu-sub-content",
          state: "closed",
          closed: "",
          preferred_side: @side,
          align: @align,
          side_offset: @side_offset,
          align_offset: @align_offset
        },
        class: [
          "fixed inset-auto m-0 border-0 z-50 w-auto min-w-[96px] max-h-(--available-height) origin-(--transform-origin)",
          "overflow-x-hidden overflow-y-auto outline-none",
          "bg-popover text-popover-foreground ring-1 ring-foreground/10 rounded-md p-1 shadow-lg duration-100",
          "data-open:animate-in data-open:fade-in-0 data-open:zoom-in-95",
          "data-closed:animate-out data-closed:fade-out-0 data-closed:zoom-out-95 data-closed:fill-mode-forwards",
          "data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2",
          "data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2"
        ]
      }
    end
  end
end
