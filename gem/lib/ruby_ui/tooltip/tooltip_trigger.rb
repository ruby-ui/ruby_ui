# frozen_string_literal: true

module RubyUI
  # Wraps the element that shows the tooltip (usually a Button). The tooltip
  # opens while the pointer rests on it for delay: ms, or when it gets
  # keyboard focus, and closes close_delay: ms after the pointer leaves both
  # the trigger and the content (plus a short grace to cross the gap), on
  # blur or on Escape. close_on_click: closes it when the trigger is pressed.
  # Defaults follow shadcn's TooltipProvider (delay 0) and Base UI's Trigger.
  class TooltipTrigger < Base
    def initialize(delay: 0, close_delay: 0, close_on_click: true, **attrs)
      @delay = delay
      @close_delay = close_delay
      @close_on_click = close_on_click
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          slot: "tooltip-trigger",
          ruby_ui__tooltip_target: "trigger",
          delay: @delay,
          close_delay: @close_delay,
          close_on_click: @close_on_click.to_s
        },
        # Shrinks to the button, so the hit area and the anchor are the button.
        class: "inline-flex w-fit"
      }
    end
  end
end
