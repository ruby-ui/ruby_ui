import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ruby-ui--dialog"
export default class extends Controller {
  static targets = ["dialog"]
  static values = {
    open: {
      type: Boolean,
      default: false
    },
  }

  connect() {
    this.dialogTarget.addEventListener("close", this.handleClose)
    if (this.openValue) {
      this.open()
    }
  }

  disconnect() {
    this.dialogTarget.removeEventListener("close", this.handleClose)
    document.body.classList.remove("overflow-hidden")
  }

  open(e) {
    e?.preventDefault()
    this.dialogTarget.showModal()
    document.body.classList.add("overflow-hidden")
  }

  dismiss() {
    this.dialogTarget.close()
  }

  // The panel's own padding also reports the <dialog> as target, so only a press
  // that starts and ends outside the panel's rect counts as a backdrop click.
  backdropPointerdown(e) {
    this.pressStartedOutside = e.target === this.dialogTarget && this.isOutsidePanel(e)
  }

  backdropClick(e) {
    const startedOutside = this.pressStartedOutside
    this.pressStartedOutside = false
    if (e.target !== this.dialogTarget) return

    if (startedOutside && this.isOutsidePanel(e)) {
      this.dismiss()
    }
  }

  isOutsidePanel(e) {
    const rect = this.dialogTarget.getBoundingClientRect()
    return e.clientX < rect.left || e.clientX > rect.right || e.clientY < rect.top || e.clientY > rect.bottom
  }

  handleClose = () => {
    document.body.classList.remove("overflow-hidden")
  }
}
