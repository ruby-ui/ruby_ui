import { Controller } from "@hotwired/stimulus";
import { MaskInput } from "maska";

// Connects to data-controller="ruby-ui--masked-input"
export default class extends Controller {
  connect() {
    new MaskInput(this.element)
  }
}
