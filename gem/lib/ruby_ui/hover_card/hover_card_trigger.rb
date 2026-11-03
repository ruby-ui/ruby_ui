# frozen_string_literal: true

module RubyUI
  # Wraps the element that opens the card on hover or keyboard focus.
  # delay:/close_delay: are in milliseconds, with the defaults of shadcn's
  # HoverCardTrigger (Base UI: 600 and 300).
  class HoverCardTrigger < Base
    def initialize(delay: nil, close_delay: nil, **attrs)
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
          slot: "hover-card-trigger",
          ruby_ui__hover_card_target: "trigger",
          delay: @delay,
          close_delay: @close_delay
        },
        class: "inline-block"
      }
    end
  end
end
