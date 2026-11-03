import {
  Bubble,
  BubbleContent,
  BubbleGroup,
  BubbleReactions,
} from "@/components/ui/bubble"
import { Message, MessageContent } from "@/components/ui/message"

export default function BubbleFixture() {
  return (
    <div className="flex w-[480px] flex-col p-6">
      <BubbleGroup>
        <Bubble>
          <BubbleContent>Hi! Are we still on for Friday?</BubbleContent>
        </Bubble>
        <Bubble variant="secondary">
          <BubbleContent>Secondary bubble</BubbleContent>
        </Bubble>
        <Bubble variant="muted">
          <BubbleContent>Muted bubble</BubbleContent>
        </Bubble>
        <Bubble variant="tinted">
          <BubbleContent>Tinted bubble</BubbleContent>
        </Bubble>
        <Bubble variant="outline">
          <BubbleContent>Outline bubble</BubbleContent>
        </Bubble>
        <Bubble variant="ghost">
          <BubbleContent>Ghost bubble</BubbleContent>
        </Bubble>
        <Bubble variant="destructive">
          <BubbleContent>Message failed to send</BubbleContent>
        </Bubble>
        <Bubble align="end">
          <BubbleContent>Yes, see you at 3pm.</BubbleContent>
          <BubbleReactions>
            <span>👍</span>
            <span>2</span>
          </BubbleReactions>
        </Bubble>
        <Bubble variant="muted">
          <BubbleContent>Sounds good.</BubbleContent>
          <BubbleReactions side="top" align="start">
            <span>❤️</span>
          </BubbleReactions>
        </Bubble>
        <Bubble variant="outline">
          <BubbleContent
            render={<button type="button" data-audit-trigger="" />}
          >
            Tap to retry
          </BubbleContent>
        </Bubble>
      </BubbleGroup>
      <Message align="end">
        <MessageContent>
          <Bubble>
            <BubbleContent>Sent from inside a message.</BubbleContent>
          </Bubble>
        </MessageContent>
      </Message>
      <Message align="end">
        <div className="flex w-full flex-col">
          <Bubble>
            <BubbleContent>Aligned by the bubble itself.</BubbleContent>
          </Bubble>
        </div>
      </Message>
    </div>
  )
}
