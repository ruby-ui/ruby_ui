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
    this.closing = false
    this.dialogTarget.addEventListener("close", this.handleClose)
    this.dialogTarget.addEventListener("cancel", this.handleCancel)
    if (this.openValue) {
      this.open()
    }
  }

  disconnect() {
    this.closing = false
    this.dialogTarget.removeEventListener("close", this.handleClose)
    this.dialogTarget.removeEventListener("cancel", this.handleCancel)
    document.body.classList.remove("overflow-hidden")
  }

  open(e) {
    e?.preventDefault()
    this.dialogTarget.dataset.state = "open"
    this.dialogTarget.showModal()
    document.body.classList.add("overflow-hidden")
  }

  dismiss() {
    this.animateClose()
  }

  // Plays the exit animation on the panel and its ::backdrop, then closes.
  async animateClose() {
    if (this.closing || !this.dialogTarget.open) return

    this.closing = true
    this.dialogTarget.dataset.state = "closed"
    await Promise.allSettled(this.ownAnimations().map((animation) => animation.finished))
    // handleClose/disconnect reset `closing`: the dialog already closed (e.g. a forced
    // second Esc) and may have been reopened since, so don't close it again.
    if (this.closing) this.dialogTarget.close()
  }

  // Only the dialog's own animations (panel + ::backdrop), never its descendants'.
  ownAnimations() {
    return document.getAnimations().filter((animation) => animation.effect?.target === this.dialogTarget)
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

  // Esc fires `cancel`; hold the native close so the exit animation can play.
  // A dismissed <input type="file"> picker also fires a bubbling `cancel`; ignore it.
  handleCancel = (e) => {
    if (e.target !== this.dialogTarget) return
    e.preventDefault()
    this.animateClose()
  }

  handleClose = () => {
    this.closing = false
    delete this.dialogTarget.dataset.state
    document.body.classList.remove("overflow-hidden")
  }
}
