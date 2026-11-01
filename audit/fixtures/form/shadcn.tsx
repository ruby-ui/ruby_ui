// shadcn has no form.tsx: the counterpart is field.tsx. FieldError renders
// nothing without content, so Username shows no error until RubyUI validates.
import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import {
  Field,
  FieldContent,
  FieldDescription,
  FieldError,
  FieldGroup,
  FieldLabel,
  FieldLegend,
  FieldSeparator,
  FieldSet,
} from "@/components/ui/field"
import { Input } from "@/components/ui/input"

export default function FormFixture() {
  return (
    <form className="flex w-96 flex-col gap-6" noValidate>
      <FieldGroup>
        <Field>
          <FieldLabel htmlFor="username">Username</FieldLabel>
          <Input id="username" required minLength={3} />
          <FieldDescription>Choose a public username.</FieldDescription>
          <FieldError />
        </Field>
        <Field data-invalid="true">
          <FieldLabel htmlFor="email">Email</FieldLabel>
          <Input id="email" type="email" aria-invalid="true" />
          <FieldError errors={[{ message: "is too short" }, { message: "is invalid" }]} />
        </Field>
      </FieldGroup>
      <FieldSet>
        <FieldLegend>Notifications</FieldLegend>
        <FieldDescription>Pick how we reach you.</FieldDescription>
        <FieldGroup>
          <Field orientation="horizontal">
            <Checkbox id="newsletter" />
            <FieldContent>
              <FieldLabel htmlFor="newsletter">Email me updates</FieldLabel>
              <FieldDescription>One email a month.</FieldDescription>
            </FieldContent>
          </Field>
          <FieldSeparator>Or</FieldSeparator>
          <Field orientation="responsive">
            <FieldLabel htmlFor="phone">Phone</FieldLabel>
            <Input id="phone" type="tel" />
          </Field>
        </FieldGroup>
      </FieldSet>
      <Field data-disabled="true">
        <FieldLabel htmlFor="company">Company</FieldLabel>
        <Input id="company" disabled />
      </Field>
      <Button type="submit" data-audit-trigger="">
        Save
      </Button>
    </form>
  )
}
