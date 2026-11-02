import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["checkbox"];

  connect() {
    this.#handleRequired();
  }

  onChange() {
    this.#handleRequired();

    // Toggling `required` changes every checkbox's validity, not only the one
    // the user clicked. When each checkbox sits in its own FormField (shadcn's
    // Field orientation="horizontal"), tell each field to re-check its state.
    this.checkboxTargets.forEach((checkbox) =>
      this.dispatch("change", { target: checkbox, bubbles: false }),
    );
  }

  #handleRequired() {
    if (!this.element.hasAttribute("data-required")) return;

    const checked = this.checkboxTargets.some(({ checked }) => checked);

    this.checkboxTargets.forEach((checkbox) => (checkbox.required = !checked));
  }
}
