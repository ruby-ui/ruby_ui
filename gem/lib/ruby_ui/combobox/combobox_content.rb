# frozen_string_literal: true

module RubyUI
  # The popup. A native popover (top layer), positioned next to the trigger,
  # the input or the chips by Floating UI; side:/align: pick the placement,
  # side_offset:/align_offset: the gap, as in shadcn's ComboboxContent.
  class ComboboxContent < Base
    include ComboboxContext

    SIDES = %i[top right bottom left].freeze
    ALIGNS = %i[start center end].freeze

    def initialize(side: :bottom, side_offset: 6, align: :start, align_offset: 0, **)
      @side = SIDES.include?(side.to_sym) ? side.to_sym : :bottom
      @side_offset = side_offset
      @align = ALIGNS.include?(align.to_sym) ? align.to_sym : :start
      @align_offset = align_offset
      super(**)
    end

    def view_template(&)
      div(**with_combobox_defaults(id: combobox[:content_id], role: (combobox[:popup] == :dialog) ? "dialog" : nil), &)
    end

    private

    def default_attrs
      {
        popover: "manual",
        data: {
          slot: "combobox-content",
          ruby_ui__combobox_target: "content",
          closed: "",
          side: @side,
          align: @align,
          preferred_side: @side,
          side_offset: @side_offset,
          align_offset: @align_offset
        },
        class: [
          "group/combobox-content fixed inset-auto m-0 border-0 p-0",
          "bg-popover text-popover-foreground ring-1 ring-foreground/10 rounded-md shadow-md overflow-hidden",
          "max-h-[min(--spacing(72),var(--available-height,100vh))] min-w-36",
          "w-(--anchor-width) max-w-(--available-width) min-w-[calc(var(--anchor-width)+--spacing(7))]",
          "data-[chips=true]:min-w-(--anchor-width) origin-(--transform-origin) duration-100",
          "data-open:animate-in data-open:fade-in-0 data-open:zoom-in-95",
          "data-closed:animate-out data-closed:fade-out-0 data-closed:zoom-out-95 data-closed:fill-mode-forwards",
          "data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2",
          "data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2",
          "*:data-[slot=input-group]:m-1 *:data-[slot=input-group]:mb-0 *:data-[slot=input-group]:h-8",
          "*:data-[slot=input-group]:border-input/30 *:data-[slot=input-group]:bg-input/30",
          "*:data-[slot=input-group]:shadow-none"
        ]
      }
    end
  end
end
