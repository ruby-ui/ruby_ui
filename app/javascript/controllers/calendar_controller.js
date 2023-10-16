import { Controller } from "@hotwired/stimulus";
import { format } from "date-fns"; // See https://date-fns.org/v2.30.0/docs/format for more options

export default class extends Controller {
  static targets = ["calendar", "title"];
  static values = { 
    selectedDate: {
      type: String,
      default: null
    },
    viewDate: {
      type: String,
      default: new Date().toISOString().slice(0, 10)
    },
    format: {
      type: String,
      default: "yyyy-MM-dd" // See https://date-fns.org/v2.30.0/docs/format for more options
    }
  };
  static outlets = ["input"]

  initialize() {
    this.updateCalendar() // Initial calendar render
  }

  nextMonth() {
    // Update the date value
    const date = this.viewDate()
    date.setMonth(date.getMonth() + 1);
    this.viewDateValue = date.toISOString().slice(0, 10);
  }

  prevMonth() {
    // Update the date value
    const date = this.viewDate()
    date.setMonth(date.getMonth() - 1);
    this.viewDateValue = date.toISOString().slice(0, 10);
  }

  selectDay(event) {
    // Set the selected date value
    this.selectedDateValue = event.currentTarget.dataset.day
    // update the viewDateValue to the selected date
    this.viewDateValue = this.selectedDateValue
  }

  selectedDateValueChanged(value, prevValue) {
    this.updateCalendar()
    this.inputOutlets.forEach(outlet => {
      const formattedDate = this.formatDate(this.selectedDate())
      outlet.setValue(formattedDate)
    })
  }

  viewDateValueChanged(value, prevValue) {
    this.updateCalendar()
  }

  updateCalendar() {
      // Update the title with month and year
      this.titleTarget.textContent = this.monthAndYear();
      this.calendarTarget.innerHTML = this.calendarHTML();
  }

  calendarHTML() {
    return this.weekdays() + this.calendarDays()
  }

  weekdays() {
    return `<thead class="">
        <tr class="flex">
          <th scope="col" class="text-muted-foreground rounded-md w-8 font-normal text-[0.8rem]" aria-label="Monday">Mo</th>
          <th scope="col" class="text-muted-foreground rounded-md w-8 font-normal text-[0.8rem]" aria-label="Tuesday">Tu</th>
          <th scope="col" class="text-muted-foreground rounded-md w-8 font-normal text-[0.8rem]" aria-label="Wednesday">We</th>
          <th scope="col" class="text-muted-foreground rounded-md w-8 font-normal text-[0.8rem]" aria-label="Thursday">Th</th>
          <th scope="col" class="text-muted-foreground rounded-md w-8 font-normal text-[0.8rem]" aria-label="Friday">Fr</th>
          <th scope="col" class="text-muted-foreground rounded-md w-8 font-normal text-[0.8rem]" aria-label="Saturday">Sa</th>
          <th scope="col" class="text-muted-foreground rounded-md w-8 font-normal text-[0.8rem]" aria-label="Sunday">Su</th>
        </tr>
      </thead>`
  }

  calendarDays() {
    return this.getFullWeeksStartAndEndInMonth().map(week => this.renderWeek(week)).join('')
  }

  renderWeek(week) {
    const days = week.map(day => {
      return this.renderDay(day)
    }).join('')
    return `<tr class="flex w-full mt-2">${days}</tr>`
  }

  renderDay(day) {
    const today = new Date()
    let btn = ''

    if (day.toDateString() === this.selectedDate().toDateString()) {
      btn = `<button data-day="${day}" data-action="click->calendar#selectDay" name="day" class="rdp-button_reset rdp-button inline-flex items-center justify-center rounded-md text-sm ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 hover:bg-accent hover:text-accent-foreground h-8 w-8 p-0 font-normal aria-selected:opacity-100 bg-primary text-primary-foreground hover:bg-primary hover:text-primary-foreground focus:bg-primary focus:text-primary-foreground" role="gridcell" tabindex="0" type="button" aria-selected="true">${day.getDate()}</button>`
    } else if (day.toDateString() === today.toDateString()) {
      btn = `<button data-day="${day}" data-action="click->calendar#selectDay" name="day" class="rdp-button_reset rdp-button inline-flex items-center justify-center rounded-md text-sm ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 hover:bg-accent hover:text-accent-foreground h-8 w-8 p-0 font-normal aria-selected:opacity-100 bg-accent text-accent-foreground" role="gridcell" tabindex="-1" type="button">${day.getDate()}</button>`
    } else if (day.getMonth() === this.viewDate().getMonth()) {
      btn = `<button data-day="${day}" data-action="click->calendar#selectDay" name="day" class="rdp-button_reset rdp-button inline-flex items-center justify-center rounded-md text-sm ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 hover:bg-accent hover:text-accent-foreground h-8 w-8 p-0 font-normal aria-selected:opacity-100" role="gridcell" tabindex="-1" type="button">${day.getDate()}</button>`
    } else {
      btn = `<button data-day="${day}" data-action="click->calendar#selectDay" name="day" class="rdp-button_reset rdp-button inline-flex items-center justify-center rounded-md text-sm ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 hover:bg-accent hover:text-accent-foreground h-8 w-8 p-0 font-normal aria-selected:opacity-100 text-muted-foreground opacity-50" role="gridcell" tabindex="-1" type="button">${day.getDate()}</button>`
    }
    return `<td class="relative p-0 text-center text-sm focus-within:relative focus-within:z-20 [&amp;:has([aria-selected])]:bg-accent [&amp;:has([aria-selected])]:rounded-md" role="presentation">
        ${btn}
      </td>`
  }

  monthAndYear() {
    const month = this.viewDate().toLocaleString("default", { month: "long" });
    const year = this.viewDate().getFullYear();
    return `${month} ${year}`;
  }

  selectedDate() {
    return new Date(this.selectedDateValue);
  }

  viewDate() {
    return this.viewDateValue ? new Date(this.viewDateValue) : this.selectedDate()
  }

  getFullWeeksStartAndEndInMonth() {
      const month = this.viewDate().getMonth();
      const year = this.viewDate().getFullYear();

      let weeks = [],
          firstDate = new Date(year, month, 1),
          lastDate = new Date(year, month + 1, 0),
          numDays = lastDate.getDate()

      let start = 1
      let end
      if (firstDate.getDay() === 1) {
          end = 7
      } else if (firstDate.getDay() === 0) {
          let preMonthEndDay = new Date(year, month, 0)
          start = preMonthEndDay.getDate() - 6 + 1
          end = 1
      } else {
          let preMonthEndDay = new Date(year, month, 0)
          start = preMonthEndDay.getDate() + 1 - firstDate.getDay() + 1
          end = 7 - firstDate.getDay() + 1
          weeks.push({
              start: start,
              end: end
          })
          start = end + 1
          end = end + 7
      }
      while (start <= numDays) {
          weeks.push({
              start: start,
              end: end
          });
          start = end + 1;
          end = end + 7;
          end = start === 1 && end === 8 ? 1 : end;
          if (end > numDays && start <= numDays) {
              end = end - numDays
              weeks.push({
                  start: start,
                  end: end
              })
              break
          }
      }
      // *** the magic starts here
      return weeks.map(({start, end}, index) => {
          const sub = +(start > end && index === 0);
          return Array.from({length: 7}, (_, index) => {
              const date = new Date(year, month - sub, start + index);
              return date;
          });
      })//.flat(Infinity);
  }

  formatDate(date) {
    return format(date, this.formatValue);
  }
}
