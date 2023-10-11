import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="accordion"
export default class extends Controller {
  static targets = ['icon', 'content']
  static values = {
    open: {
      type: Boolean,
      default: false,
    }
  }
  connect() {
    this.openValue ? this.open() : this.close()
  }

  open() {
    if (this.hasContentTarget) {
      this.contentTarget.classList.remove('hidden')
      this.hasIconTarget && this.iconTarget.classList.add('rotate-180')
      this.openValue = true
    }
  }

  close() {
    if (this.hasContentTarget) {
      this.contentTarget.classList.add('hidden')
      this.hasIconTarget && this.iconTarget.classList.remove('rotate-180')
      this.openValue = false
    }
  }

  toggle() {
    this.openValue ? this.close() : this.open()
  }
}
