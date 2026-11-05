import { Button } from "@/components/ui/button"
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip"

// shadcn's "Basic" example inside its TooltipProvider (delay 0). closeOnClick
// is off so collect's click (a hover, then a press) leaves it open.
export default function TooltipFixture() {
  return (
    <TooltipProvider>
      <Tooltip>
        <TooltipTrigger
          closeOnClick={false}
          data-audit-trigger=""
          render={<Button variant="outline" className="w-fit" />}
        >
          Show Tooltip
        </TooltipTrigger>
        <TooltipContent>
          <p>Add to library</p>
        </TooltipContent>
      </Tooltip>
    </TooltipProvider>
  )
}
