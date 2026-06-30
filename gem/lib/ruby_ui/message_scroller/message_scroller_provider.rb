# frozen_string_literal: true

module RubyUI
  class MessageScrollerProvider < Base
    def initialize(auto_scroll: true, previous_item_peek: 64, default_position: :end, preserve_on_prepend: true, **attrs)
      @auto_scroll = auto_scroll
      @previous_item_peek = previous_item_peek
      @default_position = default_position
      @preserve_on_prepend = preserve_on_prepend
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          slot: "message-scroller-provider",
          controller: "ruby-ui--message-scroller",
          ruby_ui__message_scroller_auto_scroll_value: @auto_scroll.to_s,
          ruby_ui__message_scroller_previous_item_peek_value: @previous_item_peek,
          ruby_ui__message_scroller_default_position_value: @default_position,
          ruby_ui__message_scroller_preserve_on_prepend_value: @preserve_on_prepend.to_s
        },
        # display: contents — the provider owns scroll state without adding a box.
        class: "contents"
      }
    end
  end
end
