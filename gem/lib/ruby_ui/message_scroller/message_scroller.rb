# frozen_string_literal: true

module RubyUI
  class MessageScroller < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "message-scroller"},
        class: "group/message-scroller relative flex size-full min-h-0 flex-col overflow-hidden"
      }
    end
  end
end
