# frozen_string_literal: true

module RubyUI
  class HoverCardTrigger
    include ComponentBase

    private

    def default_attrs
      {
        data: {
          ruby_ui__hover_card_target: "trigger"
        },
        class: "inline-block"
      }
    end
  end
end
