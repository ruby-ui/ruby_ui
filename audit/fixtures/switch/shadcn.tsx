import { Switch } from "@/components/ui/switch"

const LABEL = "text-sm font-medium leading-none"

export default function SwitchFixture() {
  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center gap-3">
        <Switch id="airplane" name="airplane" data-audit-trigger="" />
        <label htmlFor="airplane" className={LABEL}>Airplane mode</label>
      </div>
      <div className="flex items-center gap-3">
        <Switch id="notifications" name="notifications" defaultChecked />
        <label htmlFor="notifications" className={LABEL}>Enable notifications</label>
      </div>
      <div className="flex items-center gap-3">
        <Switch id="disabled" name="disabled" disabled />
        <label htmlFor="disabled" className={LABEL}>Disabled option</label>
      </div>
      <div className="flex items-center gap-3">
        <Switch id="invalid" name="invalid" aria-invalid="true" />
        <label htmlFor="invalid" className={LABEL}>Invalid option</label>
      </div>
    </div>
  )
}
