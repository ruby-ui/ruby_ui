# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/bubble (strings in content.yml).
  # shadcn render={<button />} on BubbleContent maps to RubyUI's as: :button.
  class Bubble < Phlex::HTML
    include RubyUI

    def view_template
      div(class: "flex w-[480px] flex-col p-6") do
        BubbleGroup do
          Bubble { BubbleContent { "Hi! Are we still on for Friday?" } }
          Bubble(variant: :secondary) { BubbleContent { "Secondary bubble" } }
          Bubble(variant: :muted) { BubbleContent { "Muted bubble" } }
          Bubble(variant: :tinted) { BubbleContent { "Tinted bubble" } }
          Bubble(variant: :outline) { BubbleContent { "Outline bubble" } }
          Bubble(variant: :ghost) { BubbleContent { "Ghost bubble" } }
          Bubble(variant: :destructive) { BubbleContent { "Message failed to send" } }
          Bubble(align: :end) do
            BubbleContent { "Yes, see you at 3pm." }
            BubbleReactions do
              span { "👍" }
              span { "2" }
            end
          end
          Bubble(variant: :muted) do
            BubbleContent { "Sounds good." }
            BubbleReactions(side: :top, align: :start) do
              span { "❤️" }
            end
          end
          Bubble(variant: :outline) do
            BubbleContent(as: :button, type: "button", data: {audit_trigger: true}) { "Tap to retry" }
          end
        end
        Message(align: :end) do
          MessageContent do
            Bubble { BubbleContent { "Sent from inside a message." } }
          end
        end
        Message(align: :end) do
          div(class: "flex w-full flex-col") do
            Bubble { BubbleContent { "Aligned by the bubble itself." } }
          end
        end
      end
    end
  end
end
