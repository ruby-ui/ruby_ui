# frozen_string_literal: true

module RubyUI
  # The popup. A native popover="manual" (top layer, so no ancestor with
  # overflow: hidden clips it) with role="dialog", placed next to the trigger
  # by Floating UI. side:/align: pick the placement (side also takes the
  # logical :inline_start / :inline_end), side_offset:/align_offset: the gap,
  # with the defaults of shadcn's PopoverContent. Without side:/align:,
  # Popover's options placement: applies, then bottom/center.
  class PopoverContent < Base
    SIDES = %i[top right bottom left inline_start inline_end].freeze
    ALIGNS = %i[start center end].freeze

    def initialize(side: nil, side_offset: 4, align: nil, align_offset: 0, **attrs)
      @side = SIDES.include?(side&.to_sym) ? side.to_s.tr("_", "-") : nil
      @align = ALIGNS.include?(align&.to_sym) ? align.to_s : nil
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
        role: "dialog",
        tabindex: "-1",
        data: {
          slot: "popover-content",
          ruby_ui__popover_target: "content",
          # Kept in sync with data-open/data-closed for CSS that targets data-[state=...].
          state: "closed",
          closed: "",
          preferred_side: @side,
          preferred_align: @align,
          side_offset: @side_offset,
          align_offset: @align_offset
        },
        class: [
          # Resets the UA popover box; display:flex must not beat the UA's hidden closed popover.
          "fixed inset-auto m-0 border-0 [&:not(:popover-open)]:hidden",
          "z-50 w-72 origin-(--transform-origin) outline-hidden",
          "bg-popover text-popover-foreground ring-1 ring-foreground/10 flex flex-col gap-4 rounded-md p-4 text-sm shadow-md duration-100",
          "data-open:animate-in data-open:fade-in-0 data-open:zoom-in-95",
          "data-closed:animate-out data-closed:fade-out-0 data-closed:zoom-out-95 data-closed:fill-mode-forwards",
          "data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2",
          "data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2",
          "data-[side=inline-start]:slide-in-from-right-2 data-[side=inline-end]:slide-in-from-left-2"
        ]
      }
    end
  end
end
