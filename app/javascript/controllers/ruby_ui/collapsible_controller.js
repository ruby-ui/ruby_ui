import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="accordion"
export default class extends Controller {
  static targets = ['content']
  static values = {
    open: {
      type: Boolean,
      default: false,
    },
  }

  connect() {
    // Set the initial state of the accordion
    this.openValue ? this.open() : this.close()
  }

  // Toggle the 'open' value
  toggle() {
    this.openValue = !this.openValue
  }

  // Handle changes in the 'open' value
  openValueChanged(isOpen, wasOpen) {
    if (isOpen) {
      this.open()
    } else {
      this.close()
    }
  }

  // Open the accordion content
  open() {
    if (this.hasContentTarget) {
      this.contentTarget.classList.remove('hidden')
      this.openValue = true
    }
  }

  // Close the accordion content
  close() {
    if (this.hasContentTarget) {
      this.contentTarget.classList.add('hidden')
      this.openValue = false
    }
  }
}
