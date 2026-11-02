import { Controller } from "@hotwired/stimulus";

// Wired on Button(href:) and on Button(disabled: true, focusable_when_disabled: true).
//
// - An <a role="button"> has to activate on Space like a native button
//   (Enter already follows the link). Space is handled on keyup, as a native
//   button does, and its keydown is cancelled so the page doesn't scroll.
// - While aria-disabled="true", every activation is blocked. Keyboard
//   activation arrives as a click too. The listener uses the capture phase:
//   it runs before every bubbling listener on the element and its ancestors,
//   so no Stimulus action (with or without :prevent/:stop, whatever order the
//   controllers connected in) and no form submission sees the click.
export default class extends Controller {
  connect() {
    this.element.addEventListener("click", this.preventActivation, { capture: true });
    if (!this.isNativeButton) {
      this.element.addEventListener("keydown", this.cancelSpaceScroll);
      this.element.addEventListener("keyup", this.clickOnSpace);
    }
  }

  disconnect() {
    this.element.removeEventListener("click", this.preventActivation, { capture: true });
    this.element.removeEventListener("keydown", this.cancelSpaceScroll);
    this.element.removeEventListener("keyup", this.clickOnSpace);
  }

  preventActivation = (event) => {
    if (!this.disabled) return;

    event.preventDefault();
    event.stopImmediatePropagation();
  };

  cancelSpaceScroll = (event) => {
    if (event.key === " ") event.preventDefault();
  };

  clickOnSpace = (event) => {
    if (event.key !== " ") return;

    event.preventDefault();
    this.element.click();
  };

  get disabled() {
    return this.element.getAttribute("aria-disabled") === "true";
  }

  get isNativeButton() {
    return this.element.tagName === "BUTTON";
  }
}
