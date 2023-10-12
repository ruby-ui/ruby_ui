import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dismissable"
export default class extends Controller {
  dismiss(e) {
    this.element.remove()
  }
}
