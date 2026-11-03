import { Controller } from "@hotwired/stimulus";

// FormField cancels each `invalid` event to show its own error, which also
// cancels the browser's focus on the first invalid control. The form puts it
// back: the browser fires `invalid` for every failing control in tree order,
// all within one task, so the first event of that task is the first invalid
// control. The lock is released on the next task, not a microtask: on a real
// click the microtask queue drains between listener calls.
//
// form.reportValidity() focuses the first invalid control natively, so this
// matches it. form.checkValidity() also fires `invalid`, so calling it from
// app code moves focus too (and FormField shows the errors, as before).
export default class extends Controller {
  #focusLocked = false;
  #unlockTimer = null;

  disconnect() {
    clearTimeout(this.#unlockTimer);
    this.#focusLocked = false;
  }

  focusFirstInvalid(event) {
    if (this.#focusLocked) return;

    // A control that can't take focus (hidden, in a collapsed panel) leaves
    // the lock open, so the next invalid control gets it instead.
    event.target.focus();
    if (document.activeElement !== event.target) return;

    this.#focusLocked = true;
    this.#unlockTimer = setTimeout(() => {
      this.#focusLocked = false;
    });
  }
}
