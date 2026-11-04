import { Separator } from "@/components/ui/separator"

export default function SeparatorFixture() {
  return (
    <div id="separator-fixture" className="flex w-96 flex-col gap-8">
      <div className="flex flex-col gap-4 text-sm">
        <div className="flex flex-col gap-1">
          <div className="leading-none font-medium" data-audit-trigger="">
            shadcn/ui
          </div>
          <div className="text-muted-foreground">The Foundation for your Design System</div>
        </div>
        <Separator data-audit-separator="" />
        <div>A set of beautifully designed components that you can customize, extend, and build on.</div>
      </div>
      <div className="flex h-5 items-center gap-4 text-sm">
        <div>Blog</div>
        <Separator orientation="vertical" data-audit-separator="" />
        <div>Docs</div>
        <Separator orientation="vertical" data-audit-separator="" />
        <div>Source</div>
      </div>
      <div className="flex items-center gap-4 text-sm">
        <div className="flex flex-col gap-1">
          <span className="font-medium">Settings</span>
          <span className="text-xs text-muted-foreground">Manage preferences</span>
        </div>
        <Separator orientation="vertical" data-audit-separator="" />
        <div className="flex flex-col gap-1">
          <span className="font-medium">Account</span>
          <span className="text-xs text-muted-foreground">Profile & security</span>
        </div>
      </div>
    </div>
  )
}
