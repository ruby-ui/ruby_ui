# frozen_string_literal: true

module RubyUI
  class HoverCardTrigger < Base
    def view_template(&)
      div(**attrs, &)
    end

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
