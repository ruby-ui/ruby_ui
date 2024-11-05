import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["checkbox"];

  connect() {
    this.#applyRequired();
  }

  onChange() {
    this.#applyRequired();
  }

  #applyRequired() {
    if (!this.element.hasAttribute("data-required")) return;

    const checked = this.checkboxTargets.some(({ checked }) => checked);

    this.checkboxTargets.forEach((checkbox) => (checkbox.required = !checked));
  }
}
