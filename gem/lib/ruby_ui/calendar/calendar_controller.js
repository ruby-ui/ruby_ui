import { Controller } from "@hotwired/stimulus";
import Mustache from "mustache";

// Renders the month grid from the templates in CalendarWeekdays and
// CalendarDays. Keyboard support follows the APG date picker grid:
// one day is in the Tab sequence; arrows move by day/week, Home/End to the
// start/end of the week, PageUp/PageDown by month (Shift: by year).
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
    weekStartsOn: {
      type: Number,
      default: 0, // Sunday
    },
  };
  static outlets = ["ruby-ui--calendar-input"];

  initialize() {
    this.focusedDate = null;
    this.shouldFocus = false;
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
    const date = this.parseDate(e.currentTarget.dataset.day);
    if (!date || this.isDateDisabled(date)) return;

    // Selecting the selected day again needs no re-render, but the linked
    // input may have been edited since: write the date back into it.
    const value = this.toISODate(date);
    if (value === this.selectedDateValue) {
      this.syncInputs(date);
      return;
    }

    this.focusedDate = date;
    this.shouldFocus = true;
    this.selectedDateValue = value;
  }

  navigate(e) {
    const button = e.target.closest("button[data-day]");
    if (!button) return;

    const current = this.parseDate(button.dataset.day);
    const offset = this.weekdayOffset(current);
    let step = 0;
    let next;

    switch (e.key) {
      case "ArrowLeft":
        step = -1;
        break;
      case "ArrowRight":
        step = 1;
        break;
      case "ArrowUp":
        step = -7;
        break;
      case "ArrowDown":
        step = 7;
        break;
      case "Home":
        next = this.addDays(current, -offset);
        break;
      case "End":
        next = this.addDays(current, 6 - offset);
        break;
      case "PageUp":
        next = this.addMonths(current, e.shiftKey ? -12 : -1);
        break;
      case "PageDown":
        next = this.addMonths(current, e.shiftKey ? 12 : 1);
        break;
      default:
        return;
    }
    e.preventDefault();

    if (step !== 0) {
      next = this.addDays(current, step);
      // Skip disabled days, as react-day-picker does.
      for (let i = 0; i < 366 && this.isDateDisabled(next); i++) {
        next = this.addDays(next, step);
      }
      if (this.isDateDisabled(next)) return;
    } else {
      // Home/End/PageUp/PageDown landing on a disabled day: walk back toward
      // the current (enabled) day until an enabled one, so focus never lands
      // on a month with no focusable day.
      const back = next < current ? 1 : -1;
      while (this.isDateDisabled(next) && !this.sameDay(next, current)) {
        next = this.addDays(next, back);
      }
    }
    this.focusDay(next);
  }

  focusDay(date) {
    this.focusedDate = date;
    this.shouldFocus = true;
    const viewDate = this.toISODate(
      new Date(date.getFullYear(), date.getMonth(), 2),
    );
    if (viewDate === this.viewDateValue) {
      this.updateCalendar();
    } else {
      this.viewDateValue = viewDate; // triggers updateCalendar()
    }
  }

  selectedDateValueChanged(value, prevValue) {
    const selectedDate = this.selectedDate();
    if (!selectedDate) {
      this.updateCalendar();
      return;
    }

    // update the viewDateValue to the month of the selected date (This will trigger updateCalendar() function)
    this.viewDateValue = this.toISODate(
      new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 2),
    );

    // Re-render the calendar
    this.updateCalendar();

    this.syncInputs(selectedDate);
  }

  // Write the date into the linked inputs (input_id).
  syncInputs(date) {
    const formattedDate = this.formatDate(date);
    this.rubyUiCalendarInputOutlets.forEach((outlet) => {
      outlet.setValue(formattedDate);
    });
  }

  viewDateValueChanged(value, prevValue) {
    this.updateCalendar();
  }

  adjustMonth(adjustment) {
    const date = this.viewDate();
    return this.toISODate(
      new Date(date.getFullYear(), date.getMonth() + adjustment, 2),
    );
  }

  updateCalendar() {
    if (!this.hasCalendarTarget) return;

    // Re-rendering replaces the day buttons: keep focus in the grid if it was there.
    const keepFocus =
      this.shouldFocus || this.calendarTarget.contains(document.activeElement);

    // Update the title with month and year
    const title = this.monthAndYear();
    this.titleTarget.textContent = title;
    this.calendarTarget.setAttribute("aria-label", title);
    this.calendarTarget.innerHTML = this.calendarHTML();

    if (keepFocus) {
      this.calendarTarget.querySelector('button[tabindex="0"]')?.focus();
    }
    this.shouldFocus = false;
  }

  calendarHTML() {
    return this.weekdaysTemplateTarget.innerHTML + this.calendarDays();
  }

  calendarDays() {
    const tabbable = this.tabbableDate();
    return `<tbody>${this.weeks()
      .map((week) => this.renderWeek(week, tabbable))
      .join("")}</tbody>`;
  }

  renderWeek(week, tabbable) {
    const days = week.map((day) => this.renderDay(day, tabbable)).join("");
    return `<tr class="flex w-full mt-2">${days}</tr>`;
  }

  renderDay(day, tabbable) {
    const selectedDate = this.selectedDate();
    const isSelected = this.sameDay(day, selectedDate);
    const isToday = this.sameDay(day, new Date());
    const data = {
      date: this.toISODate(day),
      dayDate: day.getDate(),
      label: this.dayLabel(day, { isSelected, isToday }),
      tabindex: this.sameDay(day, tabbable) ? "0" : "-1",
    };

    let template;
    if (this.isDateDisabled(day)) {
      template = this.disabledDateTemplateTarget;
    } else if (isSelected) {
      template = this.selectedDateTemplateTarget;
    } else if (isToday) {
      template = this.todayDateTemplateTarget;
    } else if (day.getMonth() === this.viewDate().getMonth()) {
      template = this.currentMonthDateTemplateTarget;
    } else {
      template = this.otherMonthDateTemplateTarget;
    }
    return Mustache.render(template.innerHTML, data);
  }

  // The one day in the Tab sequence: the focused day, else the selected day,
  // else today, else the first enabled day of the month on view.
  tabbableDate() {
    const view = this.viewDate();
    const inView = (date) =>
      date &&
      date.getFullYear() === view.getFullYear() &&
      date.getMonth() === view.getMonth() &&
      !this.isDateDisabled(date);

    const candidate = [this.focusedDate, this.selectedDate(), new Date()].find(
      inView,
    );
    if (candidate) return candidate;

    const lastDay = new Date(view.getFullYear(), view.getMonth() + 1, 0);
    for (let day = 1; day <= lastDay.getDate(); day++) {
      const date = new Date(view.getFullYear(), view.getMonth(), day);
      if (!this.isDateDisabled(date)) return date;
    }
    return null;
  }

  // Full weeks covering the month on view, starting on weekStartsOn.
  weeks() {
    const view = this.viewDate();
    const year = view.getFullYear();
    const month = view.getMonth();
    const first = new Date(year, month, 1);
    const last = new Date(year, month + 1, 0);
    const start = 1 - this.weekdayOffset(first);

    const weeks = [];
    for (let day = start; new Date(year, month, day) <= last; day += 7) {
      weeks.push(
        Array.from({ length: 7 }, (_, i) => new Date(year, month, day + i)),
      );
    }
    return weeks;
  }

  // Days since the start of the week (0-6).
  weekdayOffset(date) {
    return (date.getDay() - this.weekStartsOnValue + 7) % 7;
  }

  // "Monday, March 16th, 2026", as react-day-picker labels its day buttons.
  dayLabel(date, { isSelected, isToday }) {
    const weekday = date.toLocaleString("en-US", { weekday: "long" });
    const month = date.toLocaleString("en-US", { month: "long" });
    const day = date.getDate();
    let label = `${weekday}, ${month} ${day}${this.getDaySuffix(day)}, ${date.getFullYear()}`;
    if (isToday) label = `Today, ${label}`;
    if (isSelected) label = `${label}, selected`;
    return label;
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

  addDays(date, days) {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate() + days);
  }

  // Same day in another month, clamped to that month's last day.
  addMonths(date, months) {
    const lastDay = new Date(
      date.getFullYear(),
      date.getMonth() + months + 1,
      0,
    ).getDate();
    return new Date(
      date.getFullYear(),
      date.getMonth() + months,
      Math.min(date.getDate(), lastDay),
    );
  }

  sameDay(a, b) {
    return !!(a && b && a.toDateString() === b.toDateString());
  }

  toISODate(date) {
    const pad = (n) => String(n).padStart(2, "0");
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
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
