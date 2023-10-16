import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="input"
export default class extends Controller {
  setValue(value) {
    this.element.value = value
  }
}
