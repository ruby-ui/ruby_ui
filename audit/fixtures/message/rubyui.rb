# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/message (strings in content.yml).
  class Message < Phlex::HTML
    include RubyUI

    def view_template
      div(class: "flex w-[480px] flex-col gap-10 p-6", data: {audit_trigger: true}) do
        MessageGroup do
          Message do
            MessageAvatar { Avatar { AvatarFallback { "AB" } } }
            MessageContent do
              Bubble(variant: :muted) { BubbleContent { "Something went wrong. Any idea?" } }
            end
          end
          Message do
            MessageAvatar { Avatar { AvatarFallback { "AB" } } }
            MessageContent do
              Bubble(variant: :muted) { BubbleContent { "I checked the latest deployment and the build failed during install." } }
            end
          end
        end
        Message(align: :end) do
          MessageAvatar { Avatar { AvatarFallback { "ME" } } }
          MessageContent do
            MessageHeader { "You" }
            Bubble { BubbleContent { "Can you share the exact error from the logs?" } }
            MessageFooter { "Delivered" }
          end
        end
        Message do
          MessageAvatar { Avatar { AvatarFallback { "CD" } } }
          MessageContent do
            MessageHeader { "Assistant" }
            Bubble(variant: :ghost) { BubbleContent { "Sure, here is the log excerpt." } }
            MessageFooter { "9:41 AM" }
          end
        end
      end
    end
  end
end
