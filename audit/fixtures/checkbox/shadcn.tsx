import { Checkbox } from "@/components/ui/checkbox"

const LABEL = "text-sm font-medium leading-none"

export default function CheckboxFixture() {
  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center gap-3">
        <Checkbox id="terms" data-audit-trigger="" />
        <label htmlFor="terms" className={LABEL}>Accept terms and conditions</label>
      </div>
      <div className="flex items-center gap-3">
        <Checkbox id="notifications" defaultChecked />
        <label htmlFor="notifications" className={LABEL}>Enable notifications</label>
      </div>
      <div className="flex items-center gap-3">
        <Checkbox id="disabled" disabled />
        <label htmlFor="disabled" className={LABEL}>Disabled option</label>
      </div>
      <div className="flex items-center gap-3">
        <Checkbox id="invalid" aria-invalid="true" />
        <label htmlFor="invalid" className={LABEL}>Invalid option</label>
      </div>
    </div>
  )
}
