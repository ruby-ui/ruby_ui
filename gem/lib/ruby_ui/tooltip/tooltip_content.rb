# frozen_string_literal: true

module RubyUI
  # The popup, kept in a <template> until the controller connects. The
  # controller places the copy right after the trigger, so it stays inside
  # the same container (a Sidebar hides its own tooltips from its state), and
  # opens it as a native popover="manual" in the top layer, where no ancestor
  # with overflow: hidden clips it. role="tooltip"; the trigger's focusable
  # element points at it with aria-describedby.
  #
  # side:/align: pick the placement (side also takes the logical
  # :inline_start / :inline_end), side_offset:/align_offset: the gap, with the
  # defaults of shadcn's TooltipContent. Without side:, Tooltip's placement:
  # applies, then top. It flips to the other side when there is no room.
  class TooltipContent < Base
    SIDES = %i[top right bottom left inline_start inline_end].freeze
    ALIGNS = %i[start center end].freeze

    def initialize(side: nil, side_offset: 4, align: nil, align_offset: 0, **attrs)
      @id = "tooltip-#{SecureRandom.hex(4)}"
      @side = SIDES.include?(side&.to_sym) ? side.to_s.tr("_", "-") : nil
      @align = ALIGNS.include?(align&.to_sym) ? align.to_s : nil
      @side_offset = side_offset
      @align_offset = align_offset
      super(**attrs)
    end

    def view_template(&block)
      template(data: {ruby_ui__tooltip_target: "content"}) do
        div(**attrs) do
          yield if block
          span(**arrow_attrs)
        end
      end
    end

    private

    def arrow_attrs
      {
        aria: {hidden: "true"},
        data: {slot: "tooltip-arrow"},
        class: [
          "absolute z-50 size-2.5 translate-y-[calc(-50%-2px)] rotate-45 rounded-[2px] bg-foreground fill-foreground",
          "data-[side=bottom]:top-1 data-[side=top]:-bottom-2.5",
          "data-[side=left]:top-1/2! data-[side=left]:-right-1 data-[side=left]:-translate-y-1/2",
          # The controller writes the physical side, so logical sides point right in RTL too.
          "data-[side=right]:top-1/2! data-[side=right]:-left-1 data-[side=right]:-translate-y-1/2"
        ]
      }
    end

    def default_attrs
      {
        id: @id,
        popover: "manual",
        role: "tooltip",
        data: {
          slot: "tooltip-content",
          # Kept in sync with data-open/data-closed for CSS that targets data-[state=...].
          state: "closed",
          closed: "",
          preferred_side: @side,
          preferred_align: @align,
          side_offset: @side_offset,
          align_offset: @align_offset
        },
        class: [
          # Resets the UA popover box (overflow too, or it clips the arrow);
          # inline-flex must not beat the UA's hidden closed popover.
          "fixed inset-auto m-0 border-0 overflow-visible [&:not(:popover-open)]:hidden",
          "z-50 w-fit max-w-xs origin-(--transform-origin) bg-foreground text-background",
          "inline-flex items-center gap-1.5 rounded-md px-3 py-1.5 text-xs",
          "has-data-[slot=kbd]:pr-1.5 **:data-[slot=kbd]:relative **:data-[slot=kbd]:isolate **:data-[slot=kbd]:z-50 **:data-[slot=kbd]:rounded-sm",
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
