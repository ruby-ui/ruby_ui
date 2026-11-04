// See content.yml. Plain-text rows, rows 1 and 6 anchored; one end button and
// one start button. The viewport carries the audit trigger.
import {
  MessageScroller,
  MessageScrollerButton,
  MessageScrollerContent,
  MessageScrollerItem,
  MessageScrollerProvider,
  MessageScrollerViewport,
} from "@/components/ui/message-scroller"

const rows = [
  "Hello there!",
  "Hey, how's it going?",
  "I'm prototyping a chat surface for our product docs.",
  "Treat the chat as three layers so scrolling and the composer never fight.",
  "The transcript owns vertical rhythm, not individual bubbles.",
  "What about spacing when one reply is short and the next is long?",
  "Use a consistent gap on the message list.",
  "Pin the viewport to the bottom until the reader scrolls up.",
  "Thanks, that helps.",
  "Happy to help.",
]

export default function MessageScrollerFixture() {
  return (
    <div className="p-6">
      <div className="h-80 w-96 rounded-xl border">
        <MessageScrollerProvider autoScroll>
          <MessageScroller>
            <MessageScrollerViewport data-audit-trigger="">
              <MessageScrollerContent className="p-4">
                {rows.map((text, i) => (
                  <MessageScrollerItem
                    key={i}
                    messageId={i === 0 || i === 5 ? `m${i + 1}` : undefined}
                    scrollAnchor={i === 0 || i === 5}
                  >
                    <p>{text}</p>
                  </MessageScrollerItem>
                ))}
              </MessageScrollerContent>
            </MessageScrollerViewport>
            <MessageScrollerButton />
            <MessageScrollerButton direction="start" />
          </MessageScroller>
        </MessageScrollerProvider>
      </div>
    </div>
  )
}
