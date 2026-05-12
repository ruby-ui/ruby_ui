import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="ruby-ui--command-dialog"
export default class extends Controller {
  static targets = ["content"];
  static outlets = ["ruby-ui--command"];

  rubyUiCommandOutletConnected(controller) {
    this.openOutlet = controller;
  }

  rubyUiCommandOutletDisconnected() {
    this.openOutlet = null;
  }

  open(e) {
    if (e) {
      e.preventDefault();
    }

    if (!this.hasContentTarget) {
      return;
    }

    if (this.openOutlet) {
      this.openOutlet.focusInput();
      return;
    }

    document.body.insertAdjacentHTML("beforeend", this.contentTarget.innerHTML);
    // prevent scroll on body
    document.body.classList.add("overflow-hidden");
  }
}
