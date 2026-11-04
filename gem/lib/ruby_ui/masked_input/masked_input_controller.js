import { Controller } from "@hotwired/stimulus";
import { MaskInput } from "maska";

// Connects to data-controller="ruby-ui--masked-input"
export default class extends Controller {
  connect() {
    this.mask = new MaskInput(this.element);
  }

  disconnect() {
    this.mask?.destroy();
    this.mask = null;
  }
}
