# frozen_string_literal: true

class Views::Docs::Message < Views::Base
  def view_template
    component = "Message"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Message", description: "A chat message layout that pairs an avatar with bubbles, headers, and footers. Built on top of Avatar and Bubble.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Conversation", context: self) do
        <<~RUBY
          div(class: "flex flex-col gap-6") do
            Message(align: :end) do
              MessageAvatar do
                Avatar(size: :sm) do
                  AvatarImage(src: "https://github.com/joeldrapper.png", alt: "@me")
                  AvatarFallback { "ME" }
                end
              end
              MessageContent do
                Bubble do
                  BubbleContent { "Deploying to prod real quick." }
                end
              end
            end

            Message do
              MessageAvatar do
                Avatar(size: :sm) do
                  AvatarImage(src: "https://github.com/shadcn.png", alt: "@rabbit")
                  AvatarFallback { "R" }
                end
              end
              MessageContent do
                Bubble(variant: :muted) do
                  BubbleContent { "It's 4:55 PM. On a Friday." }
                end
              end
            end

            Message(align: :end) do
              MessageAvatar do
                Avatar(size: :sm) do
                  AvatarImage(src: "https://github.com/joeldrapper.png", alt: "@me")
                  AvatarFallback { "ME" }
                end
              end
              MessageContent do
                Bubble do
                  BubbleContent { "It's a one-line change." }
                end
                MessageFooter { "Delivered" }
              end
            end

            Message do
              MessageAvatar do
                Avatar(size: :sm) do
                  AvatarImage(src: "https://github.com/shadcn.png", alt: "@rabbit")
                  AvatarFallback { "R" }
                end
              end
              MessageContent do
                BubbleGroup do
                  Bubble(variant: :muted) do
                    BubbleContent { "It's always a one-line change 😭." }
                  end
                  Bubble(variant: :muted) do
                    BubbleContent { "Alright, let me take a look." }
                    BubbleReactions(role: "img", aria_label: "Reaction: thumbs up") do
                      span { "👍" }
                    end
                  end
                end
              end
            end
          end
        RUBY
      end

      Heading(level: 2) { "With header" }

      render Docs::VisualCodeExample.new(title: "Header and footer", context: self) do
        <<~RUBY
          Message do
            MessageAvatar do
              Avatar(size: :sm) do
                AvatarImage(src: "https://github.com/shadcn.png", alt: "@oliver")
                AvatarFallback { "OL" }
              end
            end
            MessageContent do
              MessageHeader { "Oliver" }
              Bubble(variant: :muted) do
                BubbleContent { "Pushed the fix, can you review?" }
              end
              MessageFooter { "9:41 AM" }
            end
          end
        RUBY
      end

      Heading(level: 2) { "Alignment" }

      render Docs::VisualCodeExample.new(title: "Sender and receiver", context: self) do
        <<~RUBY
          div(class: "flex flex-col gap-6") do
            Message do
              MessageAvatar do
                Avatar(size: :sm) do
                  AvatarImage(src: "https://github.com/shadcn.png", alt: "@rabbit")
                  AvatarFallback { "R" }
                end
              end
              MessageContent do
                Bubble(variant: :muted) { BubbleContent { "Aligned to the start." } }
              end
            end
            Message(align: :end) do
              MessageAvatar do
                Avatar(size: :sm) do
                  AvatarImage(src: "https://github.com/joeldrapper.png", alt: "@me")
                  AvatarFallback { "ME" }
                end
              end
              MessageContent do
                Bubble { BubbleContent { "Aligned to the end." } }
              end
            end
          end
        RUBY
      end

      Heading(level: 2) { "Group" }

      render Docs::VisualCodeExample.new(title: "Message group", context: self) do
        <<~RUBY
          MessageGroup do
            Message do
              MessageAvatar do
                Avatar(size: :sm) do
                  AvatarImage(src: "https://github.com/shadcn.png", alt: "@rabbit")
                  AvatarFallback { "R" }
                end
              end
              MessageContent do
                Bubble(variant: :muted) { BubbleContent { "First message." } }
              end
            end
            Message do
              MessageAvatar do
                Avatar(size: :sm) do
                  AvatarImage(src: "https://github.com/shadcn.png", alt: "@rabbit")
                  AvatarFallback { "R" }
                end
              end
              MessageContent do
                Bubble(variant: :muted) { BubbleContent { "Second, tighter spacing." } }
              end
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      # components
      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
