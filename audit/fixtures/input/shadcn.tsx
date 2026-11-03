import type { ReactNode } from "react"
import { Input } from "@/components/ui/input"

const LABEL = "text-sm font-medium leading-none"

function Field({ id, text, children }: { id: string; text: string; children: ReactNode }) {
  return (
    <div className="flex flex-col gap-2">
      <label htmlFor={id} className={LABEL}>{text}</label>
      {children}
    </div>
  )
}

export default function InputFixture() {
  return (
    <div className="flex w-80 flex-col gap-6">
      <Field id="email" text="Email"><Input id="email" type="email" placeholder="m@example.com" data-audit-input="" data-audit-trigger="" /></Field>
      <Field id="plain" text="Name"><Input id="plain" placeholder="Your name" data-audit-input="" /></Field>
      <Field id="password" text="Password"><Input id="password" type="password" defaultValue="secret" data-audit-input="" /></Field>
      <Field id="file" text="Picture"><Input id="file" type="file" data-audit-input="" /></Field>
      <Field id="disabled" text="Disabled"><Input id="disabled" disabled placeholder="Disabled input" data-audit-input="" /></Field>
      <Field id="aria_disabled" text="Aria disabled"><Input id="aria_disabled" aria-disabled="true" placeholder="Aria disabled input" data-audit-input="" /></Field>
      <Field id="invalid" text="Invalid"><Input id="invalid" aria-invalid="true" placeholder="Invalid input" data-audit-input="" /></Field>
    </div>
  )
}
