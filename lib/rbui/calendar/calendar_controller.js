import { Controller } from "@hotwired/stimulus";
import { format } from "date-fns"; // See https://date-fns.org/v2.30.0/docs/format for more options
import Mustache from "mustache";

export default class extends Controller {
  static targets = ["calendar", "title", "weekdaysTemplate", "selectedDateTemplate", "todayDateTemplate", "currentMonthDateTemplate", "otherMonthDateTemplate"];
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
  static outlets = ["rbui--calendar-input"]

  initialize() {
    this.updateCalendar() // Initial calendar render
  }

  nextMonth(e) {
    e.preventDefault()
    this.viewDateValue = this.adjustMonth(1);
  }

  prevMonth(e) {
    e.preventDefault()
    this.viewDateValue = this.adjustMonth(-1);
  }

  selectDay(e) {
    e.preventDefault()
    // Set the selected date value
    this.selectedDateValue = e.currentTarget.dataset.day
  }

  selectedDateValueChanged(value, prevValue) {
    // update the viewDateValue to the first day of month of the selected date (This will trigger updateCalendar() function)
    const newViewDate = new Date(this.selectedDateValue)
    newViewDate.setDate(2); // set the day to the 2nd (to avoid issues with months with different number of days and timezones)
    this.viewDateValue = newViewDate.toISOString().slice(0, 10);

    // Re-render the calendar
    this.updateCalendar()

    // update the input value
    this.rbuiCalendarInputOutlets.forEach(outlet => {
      const formattedDate = this.formatDate(this.selectedDate())
      outlet.setValue(formattedDate)
    })
  }

  viewDateValueChanged(value, prevValue) {
    this.updateCalendar()
  }

  adjustMonth(adjustment) {
    const date = this.viewDate()
    date.setDate(2); // set the day to the 2nd (to avoid issues with months with different number of days and timezones)
    date.setMonth(date.getMonth() + adjustment);
    return date.toISOString().slice(0, 10);
  }

  updateCalendar() {
    // Update the title with month and year
    this.titleTarget.textContent = this.monthAndYear();
    this.calendarTarget.innerHTML = this.calendarHTML();
  }

  calendarHTML() {
    return this.weekdaysTemplateTarget.innerHTML + this.calendarDays()
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
    let dateHTML = ''
    const data = { day: day, dayDate: day.getDate() }

    if (day.toDateString() === this.selectedDate().toDateString()) {
      // selectedDate
      // Render the selected date template target innerHTML with Mustache
      dateHTML = Mustache.render(this.selectedDateTemplateTarget.innerHTML, data)
    } else if (day.toDateString() === today.toDateString()) {
      // todayDate
      dateHTML = Mustache.render(this.todayDateTemplateTarget.innerHTML, data)
    } else if (day.getMonth() === this.viewDate().getMonth()) {
      // currentMonthDaTE
      dateHTML = Mustache.render(this.currentMonthDateTemplateTarget.innerHTML, data)
    } else {
      // otherMonthDate
      dateHTML = Mustache.render(this.otherMonthDateTemplateTarget.innerHTML, data)
    }
    return dateHTML
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
    return weeks.map(({ start, end }, index) => {
      const sub = +(start > end && index === 0);
      return Array.from({ length: 7 }, (_, index) => {
        const date = new Date(year, month - sub, start + index);
        return date;
      });
    })//.flat(Infinity);
  }

  formatDate(date) {
    return format(date, this.formatValue);
  }
}
