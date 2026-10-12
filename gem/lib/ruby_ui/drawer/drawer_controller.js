import { Controller } from "@hotwired/stimulus"

const CONTENT_EVENTS = ["opened", "snap", "closed"]

export default class extends Controller {
  static targets = ["content"]
  static values = { open: { type: Boolean, default: false } }

  connect() {
    if (this.openValue) this.open()
  }

  // The content waits in a <template>; a copy goes to <body> so the fixed dialog
  // is not caught by a transformed ancestor.
  open(event) {
    event?.preventDefault()
    if (this.dialog?.isConnected) return

    this.dialog = this.contentTarget.content.firstElementChild.cloneNode(true)
    this.dialog.addEventListener("close", () => { this.dialog = null }, { once: true })
    // Under <body> the dialog is out of reach of the page's controllers, so its events are relayed from here.
    for (const name of CONTENT_EVENTS) this.dialog.addEventListener(`ruby-ui--drawer-content:${name}`, this.relay)
    document.body.append(this.dialog)
  }

  relay = (event) => {
    this.dispatch(event.type.split(":").pop(), { detail: event.detail })
  }
}
