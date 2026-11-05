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
      data = {slot: "message-scroller-item", scroll_anchor: @scroll_anchor ? "true" : "false"}
      data[:message_id] = @message_id if @message_id

      {
        data: data,
        # content-visibility skips rendering rows that are off screen; the
        # intrinsic size keeps the scrollbar stable meanwhile.
        class: "min-w-0 shrink-0 [contain-intrinsic-size:auto_10rem] [content-visibility:auto]"
      }
    end
  end
end
