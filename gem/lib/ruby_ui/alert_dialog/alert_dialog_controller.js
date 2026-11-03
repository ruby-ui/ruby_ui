import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ruby-ui--alert-dialog"
//
// <dialog role="alertdialog"> opened with showModal(): the browser makes the
// page inert, moves focus in, traps Tab and returns focus on close. Title and
// Description are wired in Ruby. This controller adds what the browser lacks:
// the exit animation, the page scroll lock and the trigger's ARIA.
// Unlike Dialog, a backdrop click doesn't close it; only Cancel or Esc do.
export default class extends Controller {
  static targets = ["dialog", "trigger"]
  static values = { open: Boolean }

  // Target callbacks also run when Turbo replaces only part of the component.
  dialogTargetConnected(dialog) {
    // A Turbo cache snapshot keeps `open` but not modality; don't restore it half-open.
    if (dialog.open && !dialog.matches(":modal")) dialog.close()
    dialog.addEventListener("cancel", this.handleCancel)
    dialog.addEventListener("close", this.handleClose)
    this.triggerTargets.forEach((trigger) => this.wireTrigger(trigger))
  }

  dialogTargetDisconnected(dialog) {
    dialog.removeEventListener("cancel", this.handleCancel)
    dialog.removeEventListener("close", this.handleClose)
    this.closeToken = null
    this.releaseScroll()
  }

  triggerTargetConnected(trigger) {
    this.wireTrigger(trigger)
  }

  connect() {
    document.addEventListener("turbo:before-cache", this.handleBeforeCache)
    if (this.openValue) this.open()
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.handleBeforeCache)
    this.closeToken = null
    this.releaseScroll()
  }

  open(e) {
    e?.preventDefault()
    if (!this.hasDialogTarget) return

    this.closeToken = null // reopening cancels a close still animating
    this.dialogTarget.dataset.state = "open"
    if (!this.dialogTarget.open) this.dialogTarget.showModal()
    this.scrollLocked = true
    document.body.classList.add("overflow-hidden")
    this.setExpanded(true)
  }

  // Plays the exit animation (panel + ::backdrop), then closes. The token lets
  // a reopen or a later close invalidate this one.
  async dismiss() {
    if (!this.hasDialogTarget || !this.dialogTarget.open || this.closeToken) return

    const dialog = this.dialogTarget
    const token = (this.closeToken = Symbol("close"))
    dialog.dataset.state = "closed"
    const animations = document.getAnimations().filter((animation) => animation.effect?.target === dialog)
    await Promise.allSettled(animations.map((animation) => animation.finished))
    if (this.closeToken === token) dialog.close()
  }

  // Esc: hold the native close so the exit animation plays. A dismissed
  // <input type="file"> picker also fires a bubbling `cancel`; ignore it.
  handleCancel = (e) => {
    if (e.target !== e.currentTarget) return
    e.preventDefault()
    this.dismiss()
  }

  handleClose = (e) => {
    this.closeToken = null
    delete e.currentTarget.dataset.state
    this.releaseScroll()
    this.setExpanded(false)
  }

  // Turbo snapshots the page right after this event and `close` fires later,
  // so clean up synchronously: the cache never keeps an open dialog or a locked body.
  handleBeforeCache = () => {
    if (!this.hasDialogTarget || !this.dialogTarget.open) return

    this.closeToken = null
    this.dialogTarget.close()
    delete this.dialogTarget.dataset.state
    this.releaseScroll()
    this.setExpanded(false)
  }

  // Only release a lock this dialog took, and keep it while another modal is open.
  releaseScroll() {
    if (!this.scrollLocked) return

    this.scrollLocked = false
    if (!document.querySelector("dialog:modal")) document.body.classList.remove("overflow-hidden")
  }

  // The trigger wraps the author's button: the ARIA goes on that button.
  wireTrigger(trigger) {
    const button = this.triggerButton(trigger)
    if (!button || !this.hasDialogTarget) return

    // Keep the author's ARIA; repoint aria-controls only when it's missing or stale.
    if (!button.hasAttribute("aria-haspopup")) button.setAttribute("aria-haspopup", "dialog")
    const controls = button.getAttribute("aria-controls")
    if (!controls || !document.getElementById(controls)) button.setAttribute("aria-controls", this.dialogTarget.id)
    button.setAttribute("aria-expanded", String(this.dialogTarget.open))
  }

  setExpanded(expanded) {
    this.triggerTargets.forEach((trigger) => this.triggerButton(trigger)?.setAttribute("aria-expanded", String(expanded)))
  }

  // A button/link inside the trigger, or the menuitem/button that wraps it.
  triggerButton(trigger) {
    return trigger.querySelector("button, a[href], [role=button]") || trigger.closest("[role=menuitem], [role=button]")
  }
}
