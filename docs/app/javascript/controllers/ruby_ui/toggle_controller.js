import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ruby-ui--toggle"
export default class extends Controller {
  static targets = ["input"]
  static values = {
    pressed: Boolean,
    value: String,
    unpressedValue: String
  }

  toggle(event) {
    if (this.element.disabled) return
    this.pressedValue = !this.pressedValue
  }

  pressedValueChanged(current) {
    this.element.setAttribute("aria-pressed", current ? "true" : "false")
    this.element.dataset.state = current ? "on" : "off"

    if (this.hasInputTarget) {
      this.inputTarget.value = current ? this.valueValue : this.unpressedValueValue
    }

    this.dispatch("change", { detail: { pressed: current }, bubbles: true })
  }
}
