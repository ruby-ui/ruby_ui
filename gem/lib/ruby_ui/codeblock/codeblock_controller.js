import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="ruby-ui--codeblock"
// Copies a CodeblockCopyButton's data-value (or the block's code), then shows
// the copied state for two seconds: data-copied, the copied label as
// aria-label and in the live region next to the button. A failed copy shows
// nothing, as in shadcn.
export default class extends Controller {
  static RESET_AFTER = 2000;

  connect() {
    this.timers = new Map();
    // A cached page (Turbo snapshot) can come back mid-feedback: start clean.
    this.buttons().forEach((button) => this.reset(button));
  }

  disconnect() {
    this.timers.forEach((timer, button) => {
      clearTimeout(timer);
      this.reset(button);
    });
    this.timers.clear();
  }

  copy(event) {
    const button = event.currentTarget;
    const value = button.dataset.value ?? this.code();

    // No Clipboard API outside a secure context (plain http).
    if (!navigator.clipboard?.writeText) return;

    navigator.clipboard
      .writeText(value)
      .then(() => this.show(button))
      .catch(() => {});
  }

  code() {
    return this.element.querySelector("[data-slot=code-block-code]")?.innerText ?? "";
  }

  show(button) {
    const label = button.dataset.copiedLabel;
    clearTimeout(this.timers.get(button));
    button.dataset.copied = "true";
    button.setAttribute("aria-label", label);
    this.status(button, label);

    this.timers.set(button, setTimeout(() => {
      this.timers.delete(button);
      this.reset(button);
    }, this.constructor.RESET_AFTER));
  }

  reset(button) {
    delete button.dataset.copied;
    button.setAttribute("aria-label", button.dataset.label);
    this.status(button, "");
  }

  buttons() {
    return this.element.querySelectorAll("[data-slot=code-block-copy-button]");
  }

  status(button, text) {
    const status = button.nextElementSibling;
    if (status?.dataset.slot === "code-block-copy-status") status.textContent = text;
  }
}
