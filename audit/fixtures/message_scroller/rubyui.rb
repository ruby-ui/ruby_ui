# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/message_scroller (strings in content.yml).
  class MessageScroller < Phlex::HTML
    include RubyUI

    ROWS = [
      "Hello there!",
      "Hey, how's it going?",
      "I'm prototyping a chat surface for our product docs.",
      "Treat the chat as three layers so scrolling and the composer never fight.",
      "The transcript owns vertical rhythm, not individual bubbles.",
      "What about spacing when one reply is short and the next is long?",
      "Use a consistent gap on the message list.",
      "Pin the viewport to the bottom until the reader scrolls up.",
      "Thanks, that helps.",
      "Happy to help."
    ].freeze

    def view_template
      div(class: "p-6") do
        div(class: "h-80 w-96 rounded-xl border") do
          MessageScrollerProvider(auto_scroll: true) do
            MessageScroller do
              MessageScrollerViewport(data: {audit_trigger: true}) do
                MessageScrollerContent(class: "p-4") do
                  ROWS.each_with_index do |text, i|
                    anchor = [0, 5].include?(i)
                    MessageScrollerItem(scroll_anchor: anchor, message_id: (anchor ? "m#{i + 1}" : nil)) do
                      p { text }
                    end
                  end
                end
              end
              MessageScrollerButton()
              MessageScrollerButton(direction: :start)
            end
          end
        end
      end
    end
  end
end
