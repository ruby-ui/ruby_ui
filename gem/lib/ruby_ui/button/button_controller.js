import { Controller } from "@hotwired/stimulus";

// Wired only on Button(disabled: true, focusable_when_disabled: true): the
// button stays focusable (aria-disabled instead of disabled), so its
// activation has to be blocked here. Keyboard activation (Enter, Space) also
// arrives as a click.
//
// The listener uses the capture phase: it runs before every bubbling listener
// on the element and its ancestors, so no Stimulus action (with or without
// :prevent/:stop, whatever order the controllers connected in) and no form
// submission sees the click.
export default class extends Controller {
  connect() {
    this.element.addEventListener("click", this.preventActivation, { capture: true });
  }

  disconnect() {
    this.element.removeEventListener("click", this.preventActivation, { capture: true });
  }

  preventActivation = (event) => {
    if (this.element.getAttribute("aria-disabled") !== "true") return;

    event.preventDefault();
    event.stopImmediatePropagation();
  };
}
