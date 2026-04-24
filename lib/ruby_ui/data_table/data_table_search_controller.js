import { Controller } from "@hotwired/stimulus";

// Module-level map survives controller disconnect/connect across Turbo Frame swaps.
// Keyed by the search form's action URL.
const PENDING_FOCUS = new Map();

export default class extends Controller {
  static values = { delay: { type: Number, default: 300 } };

  connect() {
    this.timer = null;
    this.beforeFrameRender = this.captureBeforeRender.bind(this);
    document.addEventListener("turbo:before-frame-render", this.beforeFrameRender);
    // New instance after a Turbo Frame swap — check for captured state.
    this.restoreIfPending();
  }

  disconnect() {
    clearTimeout(this.timer);
    document.removeEventListener("turbo:before-frame-render", this.beforeFrameRender);
  }

  submit(event) {
    if (event && event.type !== "input") return;
    clearTimeout(this.timer);
    if (this.delayValue <= 0) return;
    this.timer = setTimeout(() => this.element.requestSubmit(), this.delayValue);
  }

  captureBeforeRender() {
    const input = this.input();
    if (!input || document.activeElement !== input) return;
    PENDING_FOCUS.set(this.key(), {
      selectionStart: input.selectionStart,
      selectionEnd: input.selectionEnd
    });
  }

  restoreIfPending() {
    const state = PENDING_FOCUS.get(this.key());
    if (!state) return;
    PENDING_FOCUS.delete(this.key());
    const input = this.input();
    if (!input) return;
    input.focus();
    const len = input.value.length;
    try {
      input.setSelectionRange(
        Math.min(state.selectionStart ?? len, len),
        Math.min(state.selectionEnd ?? len, len)
      );
    } catch (e) {}
  }

  input() {
    return this.element.querySelector('input[type="search"]');
  }

  key() {
    return this.element.action || "_";
  }
}
