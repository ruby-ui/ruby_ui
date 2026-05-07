import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  open() {
    document.body.insertAdjacentHTML("beforeend", this.contentTarget.innerHTML)
  }
}
