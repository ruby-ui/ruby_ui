import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["content"];

  static values = { open: false };

  connect() {
    if (this.openValue) this.open();
  }

  open() {
    document.body.insertAdjacentHTML("beforeend", this.contentTarget.innerHTML);
    document.body.classList.add("overflow-hidden");
  }

  dismiss() {
    document.body.classList.remove("overflow-hidden");
    this.element.remove();
  }
}
