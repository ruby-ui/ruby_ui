# frozen_string_literal: true

class Views::Docs::Bubble < Views::Base
  def view_template
    component = "Bubble"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Bubble", description: "A chat bubble surface for displaying conversational content, with variants, alignment, grouping, and reactions.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Default", context: self) do
        <<~RUBY
          Bubble(align: :end) do
            BubbleContent { "Hey there! what's up?" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Conversation", context: self) do
        <<~RUBY
          div(class: "flex flex-col gap-8") do
            Bubble(align: :end) do
              BubbleContent { "Hey there! what's up?" }
            end
            BubbleGroup do
              Bubble(variant: :muted) do
                BubbleContent { "Hey! Want to see chat bubbles?" }
              end
              Bubble(variant: :muted) do
                BubbleContent { "I can group messages, switch sides, and keep the whole thread easy to scan." }
                BubbleReactions(role: "img", aria_label: "Reaction: thumbs up") do
                  span { "👍" }
                end
              end
            end
            Bubble(align: :end) do
              BubbleContent { "Sure. Hit me with your best demo." }
            end
          end
        RUBY
      end

      Heading(level: 2) { "Variants" }

      render Docs::VisualCodeExample.new(title: "Variants", context: self) do
        <<~RUBY
          div(class: "flex flex-col gap-4 w-full") do
            Bubble(variant: :default) { BubbleContent { "Default" } }
            Bubble(variant: :secondary) { BubbleContent { "Secondary" } }
            Bubble(variant: :muted) { BubbleContent { "Muted" } }
            Bubble(variant: :tinted) { BubbleContent { "Tinted" } }
            Bubble(variant: :outline) { BubbleContent { "Outline" } }
            Bubble(variant: :ghost) { BubbleContent { "Ghost — unframed, full width for assistant text or markdown." } }
            Bubble(variant: :destructive) { BubbleContent { "Destructive — something went wrong." } }
          end
        RUBY
      end

      Heading(level: 2) { "Alignment" }

      render Docs::VisualCodeExample.new(title: "Start and end", context: self) do
        <<~RUBY
          div(class: "flex flex-col gap-4 w-full") do
            Bubble(align: :start, variant: :muted) do
              BubbleContent { "Aligned to the start (receiver)." }
            end
            Bubble(align: :end) do
              BubbleContent { "Aligned to the end (sender)." }
            end
          end
        RUBY
      end

      Heading(level: 2) { "Reactions" }

      render Docs::VisualCodeExample.new(title: "Reactions", context: self) do
        <<~RUBY
          div(class: "flex flex-col gap-10 w-full py-6") do
            Bubble(variant: :muted) do
              BubbleContent { "Reactions anchor to the bubble edge." }
              BubbleReactions(role: "img", aria_label: "Reactions: thumbs up, fire, eyes, and 2 more") do
                span { "👍" }
                span { "🔥" }
                span { "👀" }
                span { "+2" }
              end
            end
            Bubble(align: :end) do
              BubbleContent { "Place them on top and to the start too." }
              BubbleReactions(side: :top, align: :start, role: "img", aria_label: "Reaction: heart") do
                span { "❤️" }
              end
            end
          end
        RUBY
      end

      Heading(level: 2) { "Group" }

      render Docs::VisualCodeExample.new(title: "Bubble group", context: self) do
        <<~RUBY
          BubbleGroup do
            Bubble(variant: :muted) { BubbleContent { "First message in the group." } }
            Bubble(variant: :muted) { BubbleContent { "Second one, tighter spacing." } }
            Bubble(variant: :muted) { BubbleContent { "Third, all stacked together." } }
          end
        RUBY
      end

      Heading(level: 2) { "Link or button bubble" }

      render Docs::VisualCodeExample.new(title: "Interactive content", context: self) do
        <<~RUBY
          div(class: "flex flex-col gap-4 w-full") do
            Bubble(align: :end) do
              BubbleContent(as: :a, href: "#") { "Tap to open the link →" }
            end
            Bubble(variant: :outline) do
              BubbleContent(as: :button, type: "button") { "Retry sending" }
            end
          end
        RUBY
      end

      Heading(level: 2) { "With Tooltip" }

      render Docs::VisualCodeExample.new(title: "Reveal metadata on hover", context: self) do
        <<~RUBY
          Tooltip do
            TooltipTrigger(class: "w-fit") do
              Bubble(variant: :muted, class: "max-w-none") do
                BubbleContent { "Read 9:41 AM" }
              end
            end
            TooltipContent do
              Text { "Delivered and read" }
            end
          end
        RUBY
      end

      Heading(level: 2) { "With Popover" }

      render Docs::VisualCodeExample.new(title: "Surface details on demand", context: self) do
        <<~RUBY
          Popover do
            PopoverTrigger do
              Bubble(variant: :destructive, class: "max-w-none") do
                BubbleContent { "Message failed to send" }
              end
            end
            PopoverContent(class: "w-64") do
              Text(weight: :semibold) { "Delivery error" }
              Text(size: :sm, class: "text-muted-foreground") { "The recipient's inbox is full. Try again later." }
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
