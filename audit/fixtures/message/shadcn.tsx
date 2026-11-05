import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Bubble, BubbleContent } from "@/components/ui/bubble"
import {
  Message,
  MessageAvatar,
  MessageContent,
  MessageFooter,
  MessageGroup,
  MessageHeader,
} from "@/components/ui/message"

export default function MessageFixture() {
  return (
    <div className="flex w-[480px] flex-col gap-10 p-6" data-audit-trigger="">
      <MessageGroup>
        <Message>
          <MessageAvatar>
            <Avatar>
              <AvatarFallback>AB</AvatarFallback>
            </Avatar>
          </MessageAvatar>
          <MessageContent>
            <Bubble variant="muted">
              <BubbleContent>Something went wrong. Any idea?</BubbleContent>
            </Bubble>
          </MessageContent>
        </Message>
        <Message>
          <MessageAvatar>
            <Avatar>
              <AvatarFallback>AB</AvatarFallback>
            </Avatar>
          </MessageAvatar>
          <MessageContent>
            <Bubble variant="muted">
              <BubbleContent>
                I checked the latest deployment and the build failed during install.
              </BubbleContent>
            </Bubble>
          </MessageContent>
        </Message>
      </MessageGroup>
      <Message align="end">
        <MessageAvatar>
          <Avatar>
            <AvatarFallback>ME</AvatarFallback>
          </Avatar>
        </MessageAvatar>
        <MessageContent>
          <MessageHeader>You</MessageHeader>
          <Bubble>
            <BubbleContent>
              Can you share the exact error from the logs?
            </BubbleContent>
          </Bubble>
          <MessageFooter>Delivered</MessageFooter>
        </MessageContent>
      </Message>
      <Message>
        <MessageAvatar>
          <Avatar>
            <AvatarFallback>CD</AvatarFallback>
          </Avatar>
        </MessageAvatar>
        <MessageContent>
          <MessageHeader>Assistant</MessageHeader>
          <Bubble variant="ghost">
            <BubbleContent>Sure, here is the log excerpt.</BubbleContent>
          </Bubble>
          <MessageFooter>9:41 AM</MessageFooter>
        </MessageContent>
      </Message>
    </div>
  )
}
