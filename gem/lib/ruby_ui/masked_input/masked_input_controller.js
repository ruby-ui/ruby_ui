import { Controller } from "@hotwired/stimulus";
import { MaskInput } from "maska";

// Connects to data-controller="ruby-ui--masked-input"
export default class extends Controller {
  connect() {
    new MaskInput(this.element)
    this.#boundSync = this.#sync.bind(this);
    this.element.addEventListener("maska", this.#boundSync);
  }

  disconnect() {
    this.element.removeEventListener("maska", this.#boundSync);
  }

  #boundSync = null;

  #sync(event) {
    const hidden = this.element.nextElementSibling;
    if (hidden?.type === "hidden") hidden.value = event.detail.unmasked;
  }
}
