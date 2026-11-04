# frozen_string_literal: true

module RubyUI
  # Wraps the element that opens the popover (usually a Button). It opens on
  # click, Enter or Space. open_on_hover: also opens it when the pointer rests
  # on the trigger for delay: ms, and closes it close_delay: ms after the
  # pointer leaves both the trigger and the content (shadcn's PopoverTrigger:
  # 300 and 0, plus a short grace to cross the gap onto the content).
  class PopoverTrigger < Base
    def initialize(open_on_hover: nil, delay: nil, close_delay: nil, **attrs)
      @open_on_hover = open_on_hover
      @delay = delay
      @close_delay = close_delay
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          slot: "popover-trigger",
          ruby_ui__popover_target: "trigger",
          # Unset (nil) lets Popover's older options trigger: "hover" apply; false turns hover off.
          open_on_hover: @open_on_hover&.to_s,
          delay: @delay,
          close_delay: @close_delay
        },
        class: "inline-block"
      }
    end
  end
end
