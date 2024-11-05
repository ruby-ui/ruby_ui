import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"];

  connect() {
    if (this.element.hasAttribute("data-required")) {
      this.checkboxTargets.forEach(checkbox => {
        checkbox.required = true;
      });
    }
  }

  onChange(event) {
    if (this.element.hasAttribute("data-required")) {
      const checked = this.checkboxTargets.some(checkbox => checkbox.checked);

      this.checkboxTargets.forEach(checkbox => {
        checkbox.required = !checked;
      });
    }
  }
}
