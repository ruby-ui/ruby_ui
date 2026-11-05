# frozen_string_literal: true

module RubyUI
  # The scroll container. A named region (aria-label "Messages", override with
  # aria: {label: ...}) so the transcript is announced when focused.
  #
  # preserve_scroll_on_prepend: keeps the visible row in place when older rows
  # load above it. The browser does this natively (CSS scroll anchoring);
  # false turns it off with overflow-anchor: none.
  #
  # data-pending-scroll hides the first paint until the controller has moved
  # to the default position, so the transcript doesn't flash at the top.
  class MessageScrollerViewport < Base
    CLASSES = [
      "size-full min-h-0 min-w-0 scroll-fade-b scrollbar-thin scrollbar-gutter-stable",
      "overflow-y-auto overscroll-contain contain-content",
      "data-autoscrolling:scrollbar-thumb-transparent data-autoscrolling:scrollbar-track-transparent",
      "data-pending-scroll:invisible"
    ].freeze

    def initialize(preserve_scroll_on_prepend: true, **attrs)
      @preserve_scroll_on_prepend = preserve_scroll_on_prepend
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        role: "region",
        aria: {label: "Messages"},
        tabindex: "0",
        data: {
          slot: "message-scroller-viewport",
          pending_scroll: "",
          ruby_ui__message_scroller_target: "viewport"
        },
        class: [*CLASSES, ("[overflow-anchor:none]" unless @preserve_scroll_on_prepend)]
      }
    end
  end
end
