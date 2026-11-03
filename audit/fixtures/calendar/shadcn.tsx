// mode="single" with a fixed month, selection and a min date (disabled before).
// Dates are parsed as local midnight, as RubyUI's controller does.
import { Calendar } from "@/components/ui/calendar"

export default function CalendarFixture() {
  return (
    <div className="p-6">
      <Calendar
        mode="single"
        defaultMonth={new Date("2026-03-12T00:00:00")}
        selected={new Date("2026-03-12T00:00:00")}
        disabled={{ before: new Date("2026-03-05T00:00:00") }}
        data-audit-trigger=""
      />
    </div>
  )
}
