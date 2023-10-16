import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="input"
export default class extends Controller {
  connect() {
    console.log("Connected!")
  }

  setValue(value) {
    console.log("Setting value to", value)
    this.element.value = value
  }
}
