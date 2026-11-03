// examples/base/date-picker-input.tsx with a fixed date (2026-03-12, local
// midnight) and the value written as yyyy-MM-dd, RubyUI's default format.
// The Field keeps the example's w-48; mx-auto is dropped so both sides sit at
// the same origin. The audit trigger is the icon button that opens the popover.
import * as React from "react"
import { CalendarIcon } from "lucide-react"

import { Calendar } from "@/components/ui/calendar"
import { Field, FieldLabel } from "@/components/ui/field"
import {
  InputGroup,
  InputGroupAddon,
  InputGroupButton,
  InputGroupInput,
} from "@/components/ui/input-group"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"

function formatDate(date: Date | undefined) {
  if (!date) return ""
  const pad = (n: number) => String(n).padStart(2, "0")
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`
}

export default function DatePickerFixture() {
  const [open, setOpen] = React.useState(false)
  const [date, setDate] = React.useState<Date | undefined>(new Date("2026-03-12T00:00:00"))
  const [month, setMonth] = React.useState<Date | undefined>(date)
  const [value, setValue] = React.useState(formatDate(date))

  return (
    <div className="p-6">
      <Field className="w-48">
        <FieldLabel htmlFor="date">Date</FieldLabel>
        <InputGroup>
          <InputGroupInput
            id="date"
            value={value}
            placeholder="Select a date"
            onChange={(e) => {
              const parsed = new Date(`${e.target.value}T00:00:00`)
              setValue(e.target.value)
              if (!isNaN(parsed.getTime())) {
                setDate(parsed)
                setMonth(parsed)
              }
            }}
            onKeyDown={(e) => {
              if (e.key === "ArrowDown") {
                e.preventDefault()
                setOpen(true)
              }
            }}
          />
          <InputGroupAddon align="inline-end">
            <Popover open={open} onOpenChange={setOpen}>
              <PopoverTrigger
                render={
                  <InputGroupButton
                    id="date-picker"
                    variant="ghost"
                    size="icon-xs"
                    aria-label="Select date"
                    data-audit-trigger=""
                  />
                }
              >
                <CalendarIcon />
                <span className="sr-only">Select date</span>
              </PopoverTrigger>
              <PopoverContent className="w-auto overflow-hidden p-0" align="end" alignOffset={-8} sideOffset={10}>
                <Calendar
                  mode="single"
                  selected={date}
                  month={month}
                  onMonthChange={setMonth}
                  onSelect={(d) => {
                    setDate(d)
                    setValue(formatDate(d))
                    setOpen(false)
                  }}
                />
              </PopoverContent>
            </Popover>
          </InputGroupAddon>
        </InputGroup>
      </Field>
    </div>
  )
}
