import { Controller } from "@hotwired/stimulus";

// FormField cancels each `invalid` event to show its own error, which also
// cancels the browser's focus on the first invalid control. The form puts it
// back: the browser fires `invalid` for every failing control in tree order,
// all within one task, so the first event of that task is the first invalid
// control. The lock is released on the next task, not a microtask: on a real
// click the microtask queue drains between listener calls.
export default class extends Controller {
  #focusLocked = false;
  #unlockTimer = null;

  disconnect() {
    clearTimeout(this.#unlockTimer);
    this.#focusLocked = false;
  }

  focusFirstInvalid(event) {
    if (this.#focusLocked) return;

    this.#focusLocked = true;
    this.#unlockTimer = setTimeout(() => {
      this.#focusLocked = false;
    });
    event.target.focus();
  }
}
