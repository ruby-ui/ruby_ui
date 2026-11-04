import type { ReactNode } from "react"
import { Textarea } from "@/components/ui/textarea"

const LABEL = "text-sm font-medium leading-none"

function Field({ id, text, children }: { id: string; text: string; children: ReactNode }) {
  return (
    <div className="flex flex-col gap-2">
      <label htmlFor={id} className={LABEL}>{text}</label>
      {children}
    </div>
  )
}

export default function TextareaFixture() {
  return (
    <div className="flex w-80 flex-col gap-6">
      <Field id="message" text="Message"><Textarea id="message" placeholder="Type your message here." data-audit-textarea="" data-audit-trigger="" /></Field>
      <Field id="bio" text="Bio"><Textarea id="bio" defaultValue={["Line one", "Line two", "Line three"].join("\n")} data-audit-textarea="" /></Field>
      <Field id="disabled" text="Disabled"><Textarea id="disabled" disabled placeholder="Disabled textarea" data-audit-textarea="" /></Field>
      <Field id="aria_disabled" text="Aria disabled"><Textarea id="aria_disabled" aria-disabled="true" placeholder="Aria disabled textarea" data-audit-textarea="" /></Field>
      <Field id="invalid" text="Invalid"><Textarea id="invalid" aria-invalid="true" placeholder="Invalid textarea" data-audit-textarea="" /></Field>
    </div>
  )
}
