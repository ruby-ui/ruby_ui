import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tabs"
export default class extends Controller {
  static targets = [ "trigger", "content" ]
  static values = { active: String }

  connect() {
    if (!this.hasActiveValue) {
      this.activeValue = this.triggerTargets[0].dataset.value
    }
  }

  show(e) {
    this.activeValue = e.target.dataset.value
  }

  activeValueChanged(currentValue, previousValue) {
    this.contentTargets.forEach((el) => {
      el.dataset.value == currentValue ? el.classList.remove("hidden") : el.classList.add("hidden")
    })

    this.triggerTargets.forEach((el) => {
      el.dataset.value == currentValue ? el.dataset.state = "active" : el.dataset.state = "inactive"
    })
  }
}
