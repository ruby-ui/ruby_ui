import { Fragment, type ReactNode } from "react"
import { InputOTP, InputOTPGroup, InputOTPSeparator, InputOTPSlot } from "@/components/ui/input-otp"

const LABEL = "text-sm font-medium leading-none"

function Field({ id, text, children }: { id: string; text: string; children: ReactNode }) {
  return (
    <div className="flex flex-col gap-2">
      <label htmlFor={id} className={LABEL}>{text}</label>
      {children}
    </div>
  )
}

function Pairs({ id, value, invalid }: { id: string; value: string; invalid?: boolean }) {
  return (
    <InputOTP id={id} maxLength={6} defaultValue={value}>
      {[[0, 1], [2, 3], [4, 5]].map((pair, n) => (
        <Fragment key={n}>
          {n > 0 && <InputOTPSeparator />}
          <InputOTPGroup>
            {pair.map((i) => <InputOTPSlot key={i} index={i} aria-invalid={invalid || undefined} />)}
          </InputOTPGroup>
        </Fragment>
      ))}
    </InputOTP>
  )
}

export default function InputOTPFixture() {
  return (
    <div className="flex flex-col gap-6">
      <Field id="simple" text="Simple">
        <InputOTP id="simple" maxLength={6} data-audit-trigger="">
          <InputOTPGroup>
            <InputOTPSlot index={0} /><InputOTPSlot index={1} /><InputOTPSlot index={2} />
          </InputOTPGroup>
          <InputOTPSeparator />
          <InputOTPGroup>
            <InputOTPSlot index={3} /><InputOTPSlot index={4} /><InputOTPSlot index={5} />
          </InputOTPGroup>
        </InputOTP>
      </Field>
      <Field id="filled" text="With Separator"><Pairs id="filled" value="123456" /></Field>
      <Field id="disabled" text="Disabled">
        <InputOTP id="disabled" maxLength={6} disabled defaultValue="123456">
          <InputOTPGroup>
            <InputOTPSlot index={0} /><InputOTPSlot index={1} /><InputOTPSlot index={2} />
          </InputOTPGroup>
          <InputOTPSeparator />
          <InputOTPGroup>
            <InputOTPSlot index={3} /><InputOTPSlot index={4} /><InputOTPSlot index={5} />
          </InputOTPGroup>
        </InputOTP>
      </Field>
      <Field id="invalid" text="Invalid State"><Pairs id="invalid" value="000000" invalid /></Field>
    </div>
  )
}
