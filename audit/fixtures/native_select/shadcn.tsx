import type { ReactNode } from "react"
import { NativeSelect, NativeSelectOptGroup, NativeSelectOption } from "@/components/ui/native-select"

const LABEL = "text-sm font-medium leading-none"

function Field({ id, text, children }: { id: string; text: string; children: ReactNode }) {
  return (
    <div className="flex flex-col gap-2">
      <label htmlFor={id} className={LABEL}>{text}</label>
      {children}
    </div>
  )
}

function Fruits() {
  return (
    <>
      <NativeSelectOption value="">Select a fruit</NativeSelectOption>
      <NativeSelectOption value="apple">Apple</NativeSelectOption>
      <NativeSelectOption value="banana">Banana</NativeSelectOption>
      <NativeSelectOption value="blueberry">Blueberry</NativeSelectOption>
    </>
  )
}

export default function NativeSelectFixture() {
  return (
    <div className="flex w-80 flex-col gap-6">
      <Field id="fruit" text="Fruit">
        <NativeSelect id="fruit" data-audit-select="" data-audit-trigger=""><Fruits /></NativeSelect>
      </Field>
      <Field id="department" text="Department">
        <NativeSelect id="department" data-audit-select="">
          <NativeSelectOption value="">Select a department</NativeSelectOption>
          <NativeSelectOptGroup label="Engineering">
            <NativeSelectOption value="frontend">Frontend</NativeSelectOption>
            <NativeSelectOption value="backend">Backend</NativeSelectOption>
          </NativeSelectOptGroup>
          <NativeSelectOptGroup label="Sales">
            <NativeSelectOption value="account_executive">Account Executive</NativeSelectOption>
          </NativeSelectOptGroup>
        </NativeSelect>
      </Field>
      <Field id="disabled" text="Disabled">
        <NativeSelect id="disabled" disabled data-audit-select=""><Fruits /></NativeSelect>
      </Field>
      <Field id="invalid" text="Invalid">
        <NativeSelect id="invalid" aria-invalid="true" data-audit-select=""><Fruits /></NativeSelect>
      </Field>
      <Field id="small" text="Small">
        <NativeSelect id="small" size="sm" data-audit-select=""><Fruits /></NativeSelect>
      </Field>
    </div>
  )
}
