# frozen_string_literal: true

class Views::Docs::MessageScroller < Views::Base
  def view_template
    component = "MessageScroller"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Message Scroller", description: "A chat scroll container that anchors turns, follows streamed responses, preserves position when older messages load, and jumps to the latest message.")

      Heading(level: 2) { "Chat window" }

      Text(class: "text-muted-foreground") { "A full chat window: an Empty state until the first message, then a scrolling transcript that follows the live edge. Type and press send — the reply lands a beat later and the view stays pinned to the bottom. Scroll up mid-thread and the jump-to-latest button appears. (The send/reply loop is a docs-only demo harness; in a real app an ActionCable or streaming source would produce the rows.)" }

      render Docs::VisualCodeExample.new(title: "Interactive chat", context: self) do
        <<~RUBY
          div(
            class: "mx-auto w-full max-w-sm",
            data: {
              controller: "message-scroller-chat",
              message_scroller_chat_replies_value: [
                "Wrap your message list in MessageScroller and turn on autoScroll — the viewport pins to the bottom as tokens arrive.",
                "Set scroll_anchor on the turn that should settle near the top, and it keeps a peek of the previous exchange above it.",
                "Auto-scroll only runs when you are already at the bottom. Scroll up and your place stays put while new messages arrive below.",
                "When there is unseen content the jump-to-latest button appears — one tap returns you to the newest message."
              ].to_json
            }
          ) do
            Card(class: "flex flex-col h-[32rem] gap-0 overflow-hidden") do
              CardHeader(class: "gap-1 border-b pb-4") do
                CardTitle { "New Chat" }
                CardDescription { "How can I help you today?" }
              end
              CardContent(class: "flex-1 overflow-hidden p-0") do
                div(data: {message_scroller_chat_target: "empty"}, class: "h-full") do
                  Empty(class: "h-full border-none") do
                    EmptyHeader do
                      EmptyMedia(variant: :icon) do
                        svg(xmlns: "http://www.w3.org/2000/svg", fill: "none", viewbox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor", class: "size-6") do |s|
                          s.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M8.625 9.75a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm0 0H8.25m4.125 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm0 0H12m4.125 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Zm0 0h-.375M21 12c0 4.556-4.03 8.25-9 8.25a9.764 9.764 0 0 1-2.555-.337A5.972 5.972 0 0 1 5.41 20.97a5.969 5.969 0 0 1-.474-.065 4.48 4.48 0 0 0 .978-2.025c.09-.457-.133-.901-.467-1.226C3.93 16.178 3 14.189 3 12c0-4.556 4.03-8.25 9-8.25s9 3.694 9 8.25Z")
                        end
                      end
                      EmptyTitle { "Morning!" }
                      EmptyDescription { "What are we working on today? Press send to start a new conversation." }
                    end
                  end
                end

                div(data: {message_scroller_chat_target: "scroller"}, class: "hidden h-full") do
                  MessageScrollerProvider(auto_scroll: true) do
                    MessageScroller do
                      MessageScrollerViewport do
                        MessageScrollerContent(class: "p-4", data: {message_scroller_chat_target: "content"})
                      end
                      MessageScrollerButton()
                    end
                  end
                end
              end
              CardFooter(class: "border-t pt-4") do
                form(data: {action: "submit->message-scroller-chat#send"}, class: "flex w-full items-center gap-2") do
                  Input(type: "text", name: "message", placeholder: "Type a message…", autocomplete: "off", class: "flex-1", data: {message_scroller_chat_target: "input"})
                  Button(type: "submit", class: "shrink-0") do
                    svg(xmlns: "http://www.w3.org/2000/svg", fill: "none", viewbox: "0 0 24 24", stroke_width: "2", stroke: "currentColor", class: "size-4") do |s|
                      s.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M4.5 10.5 12 3m0 0 7.5 7.5M12 3v18")
                    end
                    span(class: "sr-only") { "Send" }
                  end
                end
              end
            end

            template(data: {message_scroller_chat_target: "userTemplate"}) do
              MessageScrollerItem(scroll_anchor: true) do
                Message(align: :end) do
                  MessageAvatar { Avatar(size: :sm) { AvatarFallback { "ME" } } }
                  MessageContent { Bubble { BubbleContent { "" } } }
                end
              end
            end

            template(data: {message_scroller_chat_target: "assistantTemplate"}) do
              MessageScrollerItem do
                Message do
                  MessageAvatar { Avatar(size: :sm) { AvatarFallback { "AI" } } }
                  MessageContent { Bubble(variant: :muted) { BubbleContent { "" } } }
                end
              end
            end
          end
        RUBY
      end

      Heading(level: 2) { "Usage" }

      Text(class: "text-muted-foreground") { "MessageScroller fills its parent, so place it inside a height-constrained container. It follows the live edge while you are pinned to the bottom and releases the moment you scroll up. Scroll up in the panel below — a jump-to-latest button appears." }

      render Docs::VisualCodeExample.new(title: "Streaming chat", context: self) do
        <<~RUBY
          turns = [
            {role: :user, name: "ME", text: "The scroll behavior in my chat is driving me nuts. Every time the AI streams a reply, the whole thread jumps around."},
            {role: :assistant, name: "AI", text: "Wrap your message list in MessageScroller and turn on autoScroll — the viewport pins to the bottom as tokens arrive, so the latest text lands in place."},
            {role: :user, name: "ME", text: "But when someone sends a new message the view feels jarring, like the conversation reloads from the top."},
            {role: :assistant, name: "AI", text: "MessageScrollerItem fixes that with turn anchoring. Set scrollAnchor on the turn that should settle near the top, and it leaves a peek of the previous exchange above it."},
            {role: :user, name: "ME", text: "And if they scrolled up to re-read an older answer?"},
            {role: :assistant, name: "AI", text: "You won't yank them back. Auto-scroll only runs when the viewport is already at the bottom. When there is unseen content, the scroll button appears — one tap returns to the newest message."}
          ]

          MessageScrollerProvider(auto_scroll: true) do
            div(class: "h-96 w-full rounded-xl border bg-background") do
              MessageScroller do
                MessageScrollerViewport do
                  MessageScrollerContent(class: "p-4") do
                    turns.each do |turn|
                      MessageScrollerItem(scroll_anchor: turn[:role] == :user) do
                        Message(align: turn[:role] == :user ? :end : :start) do
                          MessageAvatar do
                            Avatar(size: :sm) { AvatarFallback { turn[:name] } }
                          end
                          MessageContent do
                            Bubble(variant: turn[:role] == :user ? :default : :muted) do
                              BubbleContent { turn[:text] }
                            end
                          end
                        end
                      end
                    end
                  end
                end
                MessageScrollerButton()
              end
            end
          end
        RUBY
      end

      Heading(level: 2) { "Anchoring turns" }

      Text(class: "text-muted-foreground") { "Mark the row that starts a new turn with scroll_anchor. When it is appended, the viewport moves it near the top and keeps a peek of the previous item above it, so the new turn does not feel detached." }

      render Docs::VisualCodeExample.new(title: "Anchored user turn", context: self) do
        <<~RUBY
          MessageScrollerProvider do
            div(class: "h-80 w-full rounded-xl border bg-background") do
              MessageScroller do
                MessageScrollerViewport do
                  MessageScrollerContent(class: "p-4") do
                    MessageScrollerItem(scroll_anchor: true) do
                      Message(align: :end) do
                        MessageAvatar { Avatar(size: :sm) { AvatarFallback { "ME" } } }
                        MessageContent { Bubble { BubbleContent { "Can you summarize the deploy?" } } }
                      end
                    end
                    MessageScrollerItem do
                      Message do
                        MessageAvatar { Avatar(size: :sm) { AvatarFallback { "AI" } } }
                        MessageContent { Bubble(variant: :muted) { BubbleContent { "Shipped 3 PRs: the bubble surface, the message layout, and the scroller. All green." } } }
                      end
                    end
                  end
                end
                MessageScrollerButton()
              end
            end
          end
        RUBY
      end

      Heading(level: 2) { "Scroll commands" }

      Text(class: "text-muted-foreground") { "The provider owns the scroll state, so controls placed anywhere inside it can drive the viewport. These buttons call the controller's scrollToStart and scrollToEnd actions directly." }

      render Docs::VisualCodeExample.new(title: "Jump to start or end", context: self) do
        <<~RUBY
          MessageScrollerProvider(auto_scroll: false) do
            div(class: "space-y-2") do
              div(class: "flex gap-2") do
                Button(variant: :outline, size: :sm, data: {action: "click->ruby-ui--message-scroller#scrollToStart"}) { "Jump to start" }
                Button(variant: :outline, size: :sm, data: {action: "click->ruby-ui--message-scroller#scrollToEnd"}) { "Jump to latest" }
              end
              div(class: "h-72 w-full rounded-xl border bg-background") do
                MessageScroller do
                  MessageScrollerViewport do
                    MessageScrollerContent(class: "p-4") do
                      6.times do |i|
                        MessageScrollerItem do
                          Message(align: i.odd? ? :end : :start) do
                            MessageAvatar { Avatar(size: :sm) { AvatarFallback { i.odd? ? "ME" : "AI" } } }
                            MessageContent { Bubble(variant: i.odd? ? :default : :muted) { BubbleContent { "Message number \#{i + 1} in a longer thread." } } }
                          end
                        end
                      end
                    end
                  end
                  MessageScrollerButton()
                end
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
