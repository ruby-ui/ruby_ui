import { Button } from "@/components/ui/button"
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "@/components/ui/collapsible"

const row = "rounded-md border px-4 py-2 font-mono text-sm"

export default function CollapsibleFixture() {
  return (
    <Collapsible className="w-[350px] flex flex-col gap-2">
      <div className="flex items-center justify-between gap-4 px-4">
        <h4 className="text-sm font-semibold">@peduarte starred 3 repositories</h4>
        <CollapsibleTrigger
          data-audit-trigger=""
          render={<Button variant="ghost" size="icon" className="size-8" />}
        >
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="size-4"><path d="m7 15 5 5 5-5" /><path d="m7 9 5-5 5 5" /></svg>
          <span className="sr-only">Toggle</span>
        </CollapsibleTrigger>
      </div>
      <div className={row}>@radix-ui/primitives</div>
      <CollapsibleContent className="flex flex-col gap-2">
        <div className={row}>@radix-ui/colors</div>
        <div className={row}>@stitches/react</div>
      </CollapsibleContent>
    </Collapsible>
  )
}
