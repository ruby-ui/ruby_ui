# frozen_string_literal: true

module RubyUI
  # Root of the hover card: scopes the trigger and the card for the Stimulus
  # controller. open: renders it open on load (shadcn's defaultOpen).
  #
  # option: is the older API and still works as a fallback: placement: when
  # HoverCardContent gets no side:/align:, delay: ([open, close] or a number)
  # when HoverCardTrigger gets no delay:/close_delay:. strategy: is ignored:
  # the card opens in the top layer, so no ancestor clips it.
  class HoverCard < Base
    def initialize(open: false, option: {}, **attrs)
      @open = open
      @options = option
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          slot: "hover-card",
          controller: "ruby-ui--hover-card",
          ruby_ui__hover_card_open_value: @open.to_s,
          ruby_ui__hover_card_options_value: @options.to_json
        }
      }
    end
  end
end
