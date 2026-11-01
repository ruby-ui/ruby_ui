import { Controller } from "@hotwired/stimulus"

// Prefix for generated ids, unique per page (ruby-ui-alert-dialog-1-title, …).
let alertDialogCount = 0

// Connects to data-controller="ruby-ui--alert-dialog"
//
// Native <dialog role="alertdialog"> opened with showModal(): the browser makes
// the page inert, moves focus in, traps Tab and returns focus on close. Unlike
// Dialog, a backdrop click doesn't close it; only Cancel (dismiss) or Esc do.
export default class extends Controller {
  static targets = ["dialog", "title", "description", "trigger"]
  static values = {
    open: {
      type: Boolean,
      default: false
    },
  }

  // Stimulus runs the target callbacks before connect() and after disconnect(),
  // and again when only the <dialog> is replaced (e.g. by a Turbo Stream).
  dialogTargetConnected(dialog) {
    // A Turbo cache snapshot keeps the `open` attribute but not modality:
    // a restored dialog would show without backdrop, inert page or Esc.
    if (dialog.open && !dialog.matches(":modal")) dialog.close()
    dialog.addEventListener("close", this.handleClose)
    dialog.addEventListener("cancel", this.handleCancel)
    this.wireAria(dialog)
  }

  dialogTargetDisconnected(dialog) {
    dialog.removeEventListener("close", this.handleClose)
    dialog.removeEventListener("cancel", this.handleCancel)
    this.closeToken = null
    this.releaseScroll()
  }

  connect() {
    document.addEventListener("turbo:before-cache", this.handleBeforeCache)
    if (this.openValue) {
      this.open()
    }
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.handleBeforeCache)
    this.closeToken = null
    this.releaseScroll()
  }

  open(e) {
    e?.preventDefault()
    if (!this.hasDialogTarget) return

    // Reopening during the exit animation cancels that close.
    this.closeToken = null
    this.dialogTarget.dataset.state = "open"
    if (!this.dialogTarget.open) this.dialogTarget.showModal()
    this.scrollLocked = true
    document.body.classList.add("overflow-hidden")
    this.setTriggersExpanded(true)
  }

  dismiss() {
    this.animateClose()
  }

  // Plays the exit animation on the panel and its ::backdrop, then closes.
  // Each close gets its own token: a reopen, a later close or a disconnect
  // invalidates it, so a stale animation promise never closes the dialog.
  async animateClose() {
    if (!this.hasDialogTarget || this.closeToken || !this.dialogTarget.open) return

    const dialog = this.dialogTarget
    const token = (this.closeToken = Symbol("close"))
    dialog.dataset.state = "closed"
    await Promise.allSettled(this.ownAnimations(dialog).map((animation) => animation.finished))
    if (this.closeToken === token) dialog.close()
  }

  // Only the dialog's own animations (panel + ::backdrop), never its descendants'.
  ownAnimations(dialog) {
    return document.getAnimations().filter((animation) => animation.effect?.target === dialog)
  }

  // Esc fires `cancel`; hold the native close so the exit animation can play.
  // A dismissed <input type="file"> picker also fires a bubbling `cancel`; ignore it.
  handleCancel = (e) => {
    if (e.target !== e.currentTarget) return
    e.preventDefault()
    this.animateClose()
  }

  handleClose = (e) => {
    this.closeToken = null
    delete e.currentTarget.dataset.state
    this.releaseScroll()
    this.setTriggersExpanded(false)
  }

  // Turbo snapshots the page before leaving it: close without animation so
  // the cached copy never holds an open dialog or a locked <body>. The `close`
  // event fires after the snapshot, so clean up synchronously here.
  handleBeforeCache = () => {
    if (!this.hasDialogTarget || !this.dialogTarget.open) return

    this.closeToken = null
    this.dialogTarget.close()
    delete this.dialogTarget.dataset.state
    this.releaseScroll()
    this.setTriggersExpanded(false)
  }

  // Unlock page scroll only if this dialog took the lock and no other modal
  // dialog still needs it.
  releaseScroll() {
    if (!this.scrollLocked) return

    this.scrollLocked = false
    if (!document.querySelector("dialog:modal")) document.body.classList.remove("overflow-hidden")
  }

  // Names the dialog after its title/description and ties each trigger to it.
  // Never overwrites ids or ARIA the author already set.
  wireAria(dialog) {
    const prefix = `ruby-ui-alert-dialog-${++alertDialogCount}`
    const dialogId = this.ensureId(dialog, `${prefix}-content`)

    const title = this.titleTargets.find((target) => dialog.contains(target))
    if (title) {
      const titleId = this.ensureId(title, `${prefix}-title`)
      if (!dialog.hasAttribute("aria-labelledby") && !dialog.hasAttribute("aria-label")) {
        dialog.setAttribute("aria-labelledby", titleId)
      }
    }

    const description = this.descriptionTargets.find((target) => dialog.contains(target))
    if (description) {
      const descriptionId = this.ensureId(description, `${prefix}-description`)
      if (!dialog.hasAttribute("aria-describedby")) {
        dialog.setAttribute("aria-describedby", descriptionId)
      }
    }

    this.triggerControls().forEach((control) => {
      if (!control.hasAttribute("aria-haspopup")) control.setAttribute("aria-haspopup", "dialog")
      // Repoint a stale reference too: a replaced dialog may have a new id.
      const controls = control.getAttribute("aria-controls")
      if (!controls || !document.getElementById(controls)) control.setAttribute("aria-controls", dialogId)
      control.setAttribute("aria-expanded", String(dialog.open))
    })
  }

  ensureId(element, id) {
    if (!element.id) element.id = id
    return element.id
  }

  // The element that carries the trigger's role: a button/link inside the
  // trigger wrapper, or the menuitem/button that wraps it. A role-less wrapper
  // gets no ARIA.
  triggerControls() {
    return this.triggerTargets
      .map((trigger) => trigger.querySelector("button, a[href], [role=button]") || trigger.closest("[role=menuitem], [role=button]"))
      .filter(Boolean)
  }

  setTriggersExpanded(expanded) {
    this.triggerControls().forEach((control) => control.setAttribute("aria-expanded", String(expanded)))
  }
}
