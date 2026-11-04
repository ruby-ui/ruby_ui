# frozen_string_literal: true

module RubyUI
  # The transcript: a polite live region that announces new rows (not every
  # streamed character, hence aria-relevant="additions", as in shadcn).
  #
  # Ends with a hidden spacer the controller sizes when an anchored turn needs
  # room to settle near the top while its reply is still short.
  # spacer_class: styles it (shadcn's spacerClassName).
  class MessageScrollerContent < Base
    def initialize(spacer_class: nil, **attrs)
      @spacer_class = spacer_class
      super(**attrs)
    end

    def view_template(&block)
      div(**attrs) do
        yield if block
        div(
          aria_hidden: "true",
          hidden: true,
          class: @spacer_class,
          data: {message_scroller_spacer: "", ruby_ui__message_scroller_target: "spacer"}
        )
      end
    end

    private

    def default_attrs
      {
        role: "log",
        aria_relevant: "additions",
        data: {
          slot: "message-scroller-content",
          ruby_ui__message_scroller_target: "content"
        },
        class: "flex h-max min-h-full flex-col gap-8"
      }
    end
  end
end
