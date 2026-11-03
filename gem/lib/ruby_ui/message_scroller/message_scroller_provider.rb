# frozen_string_literal: true

module RubyUI
  # Owns the scroll state (shadcn's MessageScroller.Provider). Unlike the React
  # provider it renders an element, display: contents, because Stimulus needs
  # one to hold the controller.
  #
  # auto_scroll, default_position, scroll_edge_threshold, previous_item_peek
  # and scroll_margin mirror shadcn's autoScroll, defaultScrollPosition,
  # scrollEdgeThreshold, scrollPreviousItemPeek and scrollMargin, with the
  # same defaults.
  class MessageScrollerProvider < Base
    def initialize(auto_scroll: false, default_position: :end, scroll_edge_threshold: 8, previous_item_peek: 64,
      scroll_margin: 0, preserve_on_prepend: nil, **attrs)
      @auto_scroll = auto_scroll
      @default_position = default_position
      @scroll_edge_threshold = scroll_edge_threshold
      @previous_item_peek = previous_item_peek
      @scroll_margin = scroll_margin
      # preserve_on_prepend: is the deprecated name of
      # MessageScrollerViewport's preserve_scroll_on_prepend:.
      unless preserve_on_prepend.nil?
        Warning.warn("RubyUI::MessageScrollerProvider: `preserve_on_prepend:` is deprecated, " \
          "use `MessageScrollerViewport(preserve_scroll_on_prepend:)`\n", category: :deprecated)
      end
      @preserve_on_prepend = preserve_on_prepend
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      data = {
        slot: "message-scroller-provider",
        controller: "ruby-ui--message-scroller",
        ruby_ui__message_scroller_auto_scroll_value: @auto_scroll.to_s,
        ruby_ui__message_scroller_default_position_value: @default_position,
        ruby_ui__message_scroller_scroll_edge_threshold_value: @scroll_edge_threshold,
        ruby_ui__message_scroller_previous_item_peek_value: @previous_item_peek,
        ruby_ui__message_scroller_scroll_margin_value: @scroll_margin
      }
      data[:ruby_ui__message_scroller_preserve_on_prepend_value] = @preserve_on_prepend.to_s unless @preserve_on_prepend.nil?

      {data: data, class: "contents"}
    end
  end
end
