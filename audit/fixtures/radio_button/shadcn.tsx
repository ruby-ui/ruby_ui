import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"

const LABEL = "text-sm font-medium leading-none"

export default function RadioButtonFixture() {
  return (
    <div className="flex flex-col gap-6">
      <RadioGroup name="density" defaultValue="comfortable">
        <div className="flex items-center gap-3">
          <RadioGroupItem id="r-default" value="default" />
          <label htmlFor="r-default" className={LABEL}>Default</label>
        </div>
        <div className="flex items-center gap-3">
          <RadioGroupItem id="r-comfortable" value="comfortable" data-audit-trigger="" />
          <label htmlFor="r-comfortable" className={LABEL}>Comfortable</label>
        </div>
        <div className="flex items-center gap-3">
          <RadioGroupItem id="r-compact" value="compact" disabled />
          <label htmlFor="r-compact" className={LABEL}>Compact</label>
        </div>
      </RadioGroup>
      <RadioGroup name="invalid">
        <div className="flex items-center gap-3">
          <RadioGroupItem id="r-invalid" value="invalid" aria-invalid="true" />
          <label htmlFor="r-invalid" className={LABEL}>Invalid option</label>
        </div>
      </RadioGroup>
    </div>
  )
}
