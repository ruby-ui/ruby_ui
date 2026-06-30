# frozen_string_literal: true

module RubyUI
  class MessageScrollerViewport < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        tabindex: "0",
        data: {
          slot: "message-scroller-viewport",
          ruby_ui__message_scroller_target: "viewport"
        },
        class: "size-full min-h-0 min-w-0 overflow-y-auto overscroll-contain contain-content"
      }
    end
  end
end
