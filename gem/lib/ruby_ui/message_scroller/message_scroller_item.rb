# frozen_string_literal: true

module RubyUI
  class MessageScrollerItem < Base
    def initialize(scroll_anchor: false, message_id: nil, **attrs)
      @scroll_anchor = scroll_anchor
      @message_id = message_id
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      data = {slot: "message-scroller-item"}
      data[:scroll_anchor] = "" if @scroll_anchor
      data[:message_id] = @message_id if @message_id

      {
        data: data,
        class: "min-w-0 shrink-0"
      }
    end
  end
end
