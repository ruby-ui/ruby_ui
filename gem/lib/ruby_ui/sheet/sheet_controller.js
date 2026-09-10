import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="ruby-ui--sheet"; opens the <dialog> that ruby-ui--sheet-content closes.
export default class extends Controller {
  static targets = ["dialog"];
  static values = { open: false };

  connect() {
    if (this.openValue) this.open();
  }

  open(e) {
    e?.preventDefault();
    this.dialogTarget.dataset.state = "open";
    // Reopened mid-exit the dialog is still open; showModal() on an open dialog throws in older browsers.
    if (!this.dialogTarget.open) this.dialogTarget.showModal();
    document.body.classList.add("overflow-hidden");
  }
}
