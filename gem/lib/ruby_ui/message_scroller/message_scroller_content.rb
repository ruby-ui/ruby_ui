# frozen_string_literal: true

module RubyUI
  class MessageScrollerContent < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        role: "log",
        aria_relevant: "additions text",
        data: {
          slot: "message-scroller-content",
          ruby_ui__message_scroller_target: "content"
        },
        class: "flex h-max min-h-full flex-col gap-8"
      }
    end
  end
end
