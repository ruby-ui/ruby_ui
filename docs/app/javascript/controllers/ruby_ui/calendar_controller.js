import { Controller } from "@hotwired/stimulus";
import Mustache from "mustache";

export default class extends Controller {
  static targets = [
    "calendar",
    "title",
    "weekdaysTemplate",
    "disabledDateTemplate",
    "selectedDateTemplate",
    "todayDateTemplate",
    "currentMonthDateTemplate",
    "otherMonthDateTemplate",
  ];
  static values = {
    selectedDate: {
      type: String,
      default: null,
    },
    minDate: {
      type: String,
      default: null,
    },
    viewDate: {
      type: String,
      default: new Date().toISOString().slice(0, 10),
    },
    format: {
      type: String,
      default: "yyyy-MM-dd", // Default format
    },
  };
  static outlets = ["ruby-ui--calendar-input"];

  initialize() {
    this.updateCalendar(); // Initial calendar render
  }

  nextMonth(e) {
    e.preventDefault();
    this.viewDateValue = this.adjustMonth(1);
  }

  prevMonth(e) {
    e.preventDefault();
    this.viewDateValue = this.adjustMonth(-1);
  }

  selectDay(e) {
    e.preventDefault();
    if (this.isDateDisabled(e.currentTarget.dataset.day)) return;

    // Set the selected date value
    this.selectedDateValue = e.currentTarget.dataset.day;
  }

  selectedDateValueChanged(value, prevValue) {
    const selectedDate = this.selectedDate();
    if (!selectedDate) {
      this.updateCalendar();
      return;
    }

    // update the viewDateValue to the first day of month of the selected date (This will trigger updateCalendar() function)
    const newViewDate = new Date(selectedDate);
    newViewDate.setDate(2); // set the day to the 2nd (to avoid issues with months with different number of days and timezones)
    this.viewDateValue = newViewDate.toISOString().slice(0, 10);

    // Re-render the calendar
    this.updateCalendar();

    // update the input value
    this.rubyUiCalendarInputOutlets.forEach((outlet) => {
      const formattedDate = this.formatDate(selectedDate);
      outlet.setValue(formattedDate);
    });
  }

  viewDateValueChanged(value, prevValue) {
    this.updateCalendar();
  }

  adjustMonth(adjustment) {
    const date = this.viewDate();
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
    return this.weekdaysTemplateTarget.innerHTML + this.calendarDays();
  }

  calendarDays() {
    return this.getFullWeeksStartAndEndInMonth()
      .map((week) => this.renderWeek(week))
      .join("");
  }

  renderWeek(week) {
    const days = week
      .map((day) => {
        return this.renderDay(day);
      })
      .join("");
    return `<tr class="flex w-full mt-2">${days}</tr>`;
  }

  renderDay(day) {
    const today = new Date();
    const selectedDate = this.selectedDate();
    let dateHTML = "";
    const data = { day: day, dayDate: day.getDate() };

    if (this.isDateDisabled(day)) {
      // disabledDate
      dateHTML = Mustache.render(
        this.disabledDateTemplateTarget.innerHTML,
        data,
      );
    } else if (
      selectedDate &&
      day.toDateString() === selectedDate.toDateString()
    ) {
      // selectedDate
      // Render the selected date template target innerHTML with Mustache
      dateHTML = Mustache.render(
        this.selectedDateTemplateTarget.innerHTML,
        data,
      );
    } else if (day.toDateString() === today.toDateString()) {
      // todayDate
      dateHTML = Mustache.render(this.todayDateTemplateTarget.innerHTML, data);
    } else if (day.getMonth() === this.viewDate().getMonth()) {
      // currentMonthDate
      dateHTML = Mustache.render(
        this.currentMonthDateTemplateTarget.innerHTML,
        data,
      );
    } else {
      // otherMonthDate
      dateHTML = Mustache.render(
        this.otherMonthDateTemplateTarget.innerHTML,
        data,
      );
    }
    return dateHTML;
  }

  monthAndYear() {
    const month = this.viewDate().toLocaleString("en-US", { month: "long" });
    const year = this.viewDate().getFullYear();
    return `${month} ${year}`;
  }

  selectedDate() {
    return this.parseDate(this.selectedDateValue);
  }

  viewDate() {
    return (
      this.parseDate(this.viewDateValue) || this.selectedDate() || new Date()
    );
  }

  getFullWeeksStartAndEndInMonth() {
    const month = this.viewDate().getMonth();
    const year = this.viewDate().getFullYear();

    let weeks = [],
      firstDate = new Date(year, month, 1),
      lastDate = new Date(year, month + 1, 0),
      numDays = lastDate.getDate();

    let start = 1;
    let end;
    if (firstDate.getDay() === 1) {
      end = 7;
    } else if (firstDate.getDay() === 0) {
      let preMonthEndDay = new Date(year, month, 0);
      start = preMonthEndDay.getDate() - 6 + 1;
      end = 1;
    } else {
      let preMonthEndDay = new Date(year, month, 0);
      start = preMonthEndDay.getDate() + 1 - firstDate.getDay() + 1;
      end = 7 - firstDate.getDay() + 1;
      weeks.push({
        start: start,
        end: end,
      });
      start = end + 1;
      end = end + 7;
    }
    while (start <= numDays) {
      weeks.push({
        start: start,
        end: end,
      });
      start = end + 1;
      end = end + 7;
      end = start === 1 && end === 8 ? 1 : end;
      if (end > numDays && start <= numDays) {
        end = end - numDays;
        weeks.push({
          start: start,
          end: end,
        });
        break;
      }
    }
    // *** the magic starts here
    return weeks.map(({ start, end }, index) => {
      const sub = +(start > end && index === 0);
      return Array.from({ length: 7 }, (_, index) => {
        const date = new Date(year, month - sub, start + index);
        return date;
      });
    });
  }

  formatDate(date) {
    const format = this.formatValue;
    const day = date.getDate();
    const month = date.getMonth() + 1;
    const year = date.getFullYear();
    const hours = date.getHours();
    const minutes = date.getMinutes();
    const seconds = date.getSeconds();
    const dayOfWeek = date.toLocaleString("en-US", { weekday: "long" });
    const monthName = date.toLocaleString("en-US", { month: "long" });
    const daySuffix = this.getDaySuffix(day);

    const map = {
      yyyy: year,
      MM: ("0" + month).slice(-2),
      dd: ("0" + day).slice(-2),
      HH: ("0" + hours).slice(-2),
      mm: ("0" + minutes).slice(-2),
      ss: ("0" + seconds).slice(-2),
      EEEE: dayOfWeek,
      MMMM: monthName,
      do: day + daySuffix,
      PPPP: `${dayOfWeek}, ${monthName} ${day}${daySuffix}, ${year}`,
    };

    const formattedDate = format.replace(
      /yyyy|MM|dd|HH|mm|ss|EEEE|MMMM|do|PPPP/g,
      (matched) => map[matched],
    );
    return formattedDate;
  }

  getDaySuffix(day) {
    if (day > 3 && day < 21) return "th";
    switch (day % 10) {
      case 1:
        return "st";
      case 2:
        return "nd";
      case 3:
        return "rd";
      default:
        return "th";
    }
  }

  minDate() {
    return this.parseDate(this.minDateValue);
  }

  isDateDisabled(date) {
    const minDate = this.minDate();
    const candidate = this.parseDate(date);

    if (!minDate || !candidate) return false;

    return this.startOfDay(candidate) < this.startOfDay(minDate);
  }

  parseDate(value) {
    if (!value) return null;
    if (value instanceof Date) return new Date(value);

    const isoDate = value.toString().match(/^(\d{4})-(\d{2})-(\d{2})/);
    if (isoDate) {
      return new Date(
        Number(isoDate[1]),
        Number(isoDate[2]) - 1,
        Number(isoDate[3]),
      );
    }

    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? null : date;
  }

  startOfDay(date) {
    const normalizedDate = new Date(date);
    normalizedDate.setHours(0, 0, 0, 0);
    return normalizedDate;
  }
}
