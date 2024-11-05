import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  handleItemSelected(value) {
    if (this.element.dataset.value == value) {
      this.element.setAttribute("aria-selected", true);
    } else {
      this.element.removeAttribute("aria-selected");
    }
  }
}
