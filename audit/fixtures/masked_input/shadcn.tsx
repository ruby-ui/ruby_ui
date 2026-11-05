import type { ReactNode } from "react"
import { Input } from "@/components/ui/input"

// shadcn has no masked input: plain Input with the already-masked strings.
const LABEL = "text-sm font-medium leading-none"

function Field({ id, text, children }: { id: string; text: string; children: ReactNode }) {
  return (
    <div className="flex flex-col gap-2">
      <label htmlFor={id} className={LABEL}>{text}</label>
      {children}
    </div>
  )
}

export default function MaskedInputFixture() {
  return (
    <div className="flex w-80 flex-col gap-6">
      <Field id="phone" text="Phone"><Input id="phone" type="text" placeholder="(11) 98765-4321" data-audit-input="" data-audit-trigger="" /></Field>
      <Field id="phone_filled" text="Phone (filled)"><Input id="phone_filled" type="text" defaultValue="(11) 98765-4321" data-audit-input="" /></Field>
      <Field id="document" text="CPF / CNPJ"><Input id="document" type="text" defaultValue="12.345.678/0001-90" data-audit-input="" /></Field>
      <Field id="disabled" text="Disabled"><Input id="disabled" type="text" disabled placeholder="Disabled input" data-audit-input="" /></Field>
      <Field id="invalid" text="Invalid"><Input id="invalid" type="text" aria-invalid="true" placeholder="Invalid input" data-audit-input="" /></Field>
    </div>
  )
}
