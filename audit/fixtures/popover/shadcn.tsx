import { Button } from "@/components/ui/button"
import {
  Popover,
  PopoverContent,
  PopoverDescription,
  PopoverHeader,
  PopoverTitle,
  PopoverTrigger,
} from "@/components/ui/popover"

// shadcn's "Basic" popover example.
export default function PopoverFixture() {
  return (
    <Popover>
      <PopoverTrigger
        data-audit-trigger=""
        render={<Button variant="outline" className="w-fit" />}
      >
        Open Popover
      </PopoverTrigger>
      <PopoverContent align="start">
        <PopoverHeader>
          <PopoverTitle>Dimensions</PopoverTitle>
          <PopoverDescription>Set the dimensions for the layer.</PopoverDescription>
        </PopoverHeader>
      </PopoverContent>
    </Popover>
  )
}
