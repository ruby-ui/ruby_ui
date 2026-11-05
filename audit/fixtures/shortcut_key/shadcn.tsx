import { Kbd, KbdGroup } from "@/components/ui/kbd"

export default function ShortcutKeyFixture() {
  return (
    <div className="flex flex-col items-start gap-4">
      <div className="flex items-center gap-2">
        <Kbd>Ctrl</Kbd>
        <Kbd>⌘K</Kbd>
        <Kbd data-audit-trigger="">Ctrl + B</Kbd>
      </div>
      <KbdGroup>
        <Kbd>Ctrl</Kbd>
        <Kbd>Shift</Kbd>
        <Kbd>P</Kbd>
      </KbdGroup>
    </div>
  )
}
