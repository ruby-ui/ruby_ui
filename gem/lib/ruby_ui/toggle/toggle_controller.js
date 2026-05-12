import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ruby-ui--toggle"
// Sits on a wrapper element; the visible <button> and optional hidden <input>
// are descendants so Stimulus can target them.
export default class extends Controller {
  static targets = ["button", "input"]
  static values = {
    pressed: Boolean,
    value: String,
    unpressedValue: String
  }

  toggle(event) {
    if (this.buttonTarget.disabled) return
    this.pressedValue = !this.pressedValue
  }

  pressedValueChanged(current, previous) {
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-pressed", current ? "true" : "false")
      this.buttonTarget.dataset.state = current ? "on" : "off"
    }

    if (this.hasInputTarget) {
      this.inputTarget.value = current ? this.valueValue : this.unpressedValueValue
    }

    if (previous !== undefined) {
      this.dispatch("change", { detail: { pressed: current }, bubbles: true })
    }
  }
}
