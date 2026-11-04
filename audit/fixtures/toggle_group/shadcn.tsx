import { ToggleGroup, ToggleGroupItem } from "@/components/ui/toggle-group"

export default function ToggleGroupFixture() {
  return (
    <div id="toggle-group-fixture" className="flex flex-col items-start gap-6">
      <ToggleGroup aria-label="Alignment" variant="outline" spacing={0}>
        <ToggleGroupItem value="left" data-audit-trigger="">Left</ToggleGroupItem>
        <ToggleGroupItem value="center">Center</ToggleGroupItem>
        <ToggleGroupItem value="right">Right</ToggleGroupItem>
      </ToggleGroup>
      <ToggleGroup aria-label="Formatting" multiple spacing={1} defaultValue={["bold"]}>
        <ToggleGroupItem value="bold">Bold</ToggleGroupItem>
        <ToggleGroupItem value="italic">Italic</ToggleGroupItem>
        <ToggleGroupItem value="underline">Underline</ToggleGroupItem>
      </ToggleGroup>
      <ToggleGroup aria-label="Size" variant="outline" size="sm" spacing={0} orientation="vertical" defaultValue={["medium"]}>
        <ToggleGroupItem value="small">Small</ToggleGroupItem>
        <ToggleGroupItem value="medium">Medium</ToggleGroupItem>
        <ToggleGroupItem value="large">Large</ToggleGroupItem>
      </ToggleGroup>
      <ToggleGroup aria-label="Range" multiple variant="outline" spacing={2} disabled>
        <ToggleGroupItem value="day">Day</ToggleGroupItem>
        <ToggleGroupItem value="week">Week</ToggleGroupItem>
      </ToggleGroup>
    </div>
  )
}
