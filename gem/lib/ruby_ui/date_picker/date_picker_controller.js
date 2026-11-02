import { Controller } from "@hotwired/stimulus";

// The tokens the calendar's formatDate writes. PPPP is a shorthand for
// "EEEE, MMMM do, yyyy".
const TOKENS = /PPPP|yyyy|MMMM|EEEE|MM|dd|do|HH|mm|ss/g;
const TOKEN_PATTERNS = {
  yyyy: "(\\d{4})",
  MMMM: "([A-Za-z]+)",
  EEEE: "([A-Za-z]+)",
  MM: "(\\d{2})",
  dd: "(\\d{2})",
  do: "(\\d{1,2})(?:st|nd|rd|th)",
  HH: "(\\d{2})",
  mm: "(\\d{2})",
  ss: "(\\d{2})",
};
const MONTHS = Array.from({ length: 12 }, (_, i) =>
  new Date(2000, i, 1).toLocaleString("en-US", { month: "long" }).toLowerCase(),
);

// Wires DatePicker's input, icon button, Popover and Calendar together, as
// shadcn's date-picker-input example does:
// - ArrowDown in the input opens the calendar (Enter/Space on the button open
//   it through the Popover's own click handler);
// - the button mirrors the popover state in aria-expanded / aria-controls;
// - on open, focus moves to the selected day (else the calendar's day in the
//   Tab sequence), as APG's date picker does;
// - picking a day closes the popover; on close, focus goes back to the button
//   unless it already moved somewhere else (an outside click on a field);
// - a date typed in the input, in the calendar's date_format, moves the calendar.
export default class extends Controller {
  static targets = ["input", "trigger", "content"];
  static outlets = ["ruby-ui--popover", "ruby-ui--calendar"];

  // The input may come prefilled (value: without selected_date:).
  rubyUiCalendarOutletConnected() {
    this.syncCalendar();
  }

  inputKeydown(event) {
    if (event.key !== "ArrowDown" || event.altKey || !this.hasRubyUiPopoverOutlet) return;

    event.preventDefault();
    if (this.rubyUiPopoverOutlet.openValue) {
      this.focusSelectedDay();
    } else {
      this.rubyUiPopoverOutlet.showPopover();
    }
  }

  // aria-controls only while open, as Base UI does: closed, the popup is hidden.
  opened() {
    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", "true");
      if (this.hasContentTarget && this.contentTarget.id) {
        this.triggerTarget.setAttribute("aria-controls", this.contentTarget.id);
      }
    }
    this.focusSelectedDay();
  }

  closed() {
    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", "false");
      this.triggerTarget.removeAttribute("aria-controls");
    }

    const active = document.activeElement;
    const focusLost = !active || active === document.body;
    const focusInside = this.hasContentTarget && this.contentTarget.contains(active);
    if ((focusLost || focusInside) && this.hasTriggerTarget) this.triggerTarget.focus();
  }

  // Delegated click on the popover content. The calendar re-renders its grid
  // when a day is selected, so the clicked button may already be detached:
  // closest() still works on it.
  pick(event) {
    const day = event.target.closest?.("button[data-day]");
    if (!day || day.disabled || day.getAttribute("aria-disabled") === "true") return;
    if (!this.hasRubyUiPopoverOutlet || !this.rubyUiPopoverOutlet.openValue) return;

    this.rubyUiPopoverOutlet.hidePopover();
  }

  // Selects the typed date in the calendar when it reads back exactly in the
  // calendar's format, so a half-typed value is left alone and writing the
  // date back into the input never changes what the user typed.
  syncCalendar() {
    if (!this.hasRubyUiCalendarOutlet || !this.hasInputTarget) return;

    const calendar = this.rubyUiCalendarOutlet;
    const value = this.inputTarget.value.trim();
    const date = this.parseFormatted(value, calendar.formatValue);
    if (!date || calendar.formatDate(date) !== value || calendar.isDateDisabled(date)) return;

    const iso = calendar.toISODate(date);
    if (iso === calendar.selectedDateValue) return;

    // A day focused earlier must not win the Tab stop over the new selection.
    calendar.focusedDate = null;
    calendar.selectedDateValue = iso;
  }

  // Reads value in the calendar's date_format (the tokens formatDate writes).
  // Weekday names are matched loosely here and checked by the caller's
  // formatDate round trip.
  parseFormatted(value, format) {
    if (!value || !format) return null;

    const pattern = format.replace("PPPP", "EEEE, MMMM do, yyyy");
    const order = [];
    let source = "";
    let last = 0;
    for (const match of pattern.matchAll(TOKENS)) {
      source += this.escape(pattern.slice(last, match.index)) + TOKEN_PATTERNS[match[0]];
      order.push(match[0]);
      last = match.index + match[0].length;
    }
    source += this.escape(pattern.slice(last));

    const found = value.match(new RegExp(`^${source}$`, "i"));
    if (!found) return null;

    const parts = {};
    order.forEach((token, i) => {
      parts[token] = found[i + 1];
    });

    const year = Number(parts.yyyy);
    const month = parts.MM ? Number(parts.MM) - 1 : MONTHS.indexOf((parts.MMMM || "").toLowerCase());
    const day = Number(parts.dd || parts.do);
    if (!year || month < 0 || month > 11 || !day) return null;

    return new Date(year, month, day, Number(parts.HH || 0), Number(parts.mm || 0), Number(parts.ss || 0));
  }

  escape(text) {
    return text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  }

  // The selected day, on its month, even if another day was focused or another
  // month shown before the popover closed. With no selection, the calendar's
  // own Tab stop (today or the first enabled day).
  focusSelectedDay() {
    if (this.hasRubyUiCalendarOutlet) {
      const calendar = this.rubyUiCalendarOutlet;
      const selected = calendar.selectedDate();
      if (selected && !calendar.isDateDisabled(selected)) {
        calendar.focusedDate = selected;
        calendar.viewDateValue = calendar.toISODate(new Date(selected.getFullYear(), selected.getMonth(), 2));
        calendar.updateCalendar();
      }
    }
    if (!this.hasContentTarget) return;

    this.contentTarget.querySelector('button[data-day][tabindex="0"]')?.focus({ preventScroll: true });
  }
}
