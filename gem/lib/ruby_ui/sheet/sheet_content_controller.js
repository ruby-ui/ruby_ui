import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ruby-ui--sheet-content"
// Kept for markup written against the old Sheet: `click->ruby-ui--sheet-content#close`
// still closes the sheet. New code uses `click->ruby-ui--sheet#dismiss`.
export default class extends Controller {
  close() {
    const root = this.element.closest('[data-controller~="ruby-ui--sheet"]')
    const sheet = root && this.application.getControllerForElementAndIdentifier(root, "ruby-ui--sheet")
    sheet?.dismiss()
  }
}
