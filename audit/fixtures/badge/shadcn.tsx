import { Badge } from "@/components/ui/badge"

export default function BadgeFixture() {
  return (
    <div className="flex flex-wrap items-center gap-2">
      <Badge>Badge</Badge>
      <Badge variant="secondary">Secondary</Badge>
      <Badge variant="destructive">Destructive</Badge>
      <Badge variant="outline">Outline</Badge>
      <Badge variant="ghost">Ghost</Badge>
      <Badge variant="link">Link</Badge>
      <Badge render={<a href="#" data-audit-trigger="" />}>Open Link</Badge>
    </div>
  )
}
