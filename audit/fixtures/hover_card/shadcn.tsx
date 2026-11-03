import { Button } from "@/components/ui/button"
import {
  HoverCard,
  HoverCardContent,
  HoverCardTrigger,
} from "@/components/ui/hover-card"

// Delays are 0 (the example uses 100) so collect's click reaches the open
// state; the RubyUI fixture does the same.
export default function HoverCardFixture() {
  return (
    <HoverCard>
      <HoverCardTrigger
        delay={0}
        closeDelay={0}
        data-audit-trigger=""
        render={<Button variant="outline" />}
      >
        Hover me
      </HoverCardTrigger>
      <HoverCardContent>
        <div className="flex flex-col gap-2">
          <h4 className="font-medium">Hover Card</h4>
          <p>This hover card appears on the bottom side of the trigger.</p>
        </div>
      </HoverCardContent>
    </HoverCard>
  )
}
