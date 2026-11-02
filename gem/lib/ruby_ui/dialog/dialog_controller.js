import { Controller } from "@hotwired/stimulus"

// Prefix for generated ids, unique per page (ruby-ui-dialog-1-title, …).
let dialogCount = 0

// Connects to data-controller="ruby-ui--dialog"
export default class extends Controller {
  static targets = ["dialog", "title", "description", "trigger"]
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
    this.dialogTarget.addEventListener("keydown", this.handleKeydown)
    this.wireAria()
    if (this.openValue) {
      this.open()
    }
  }

  disconnect() {
    this.closing = false
    this.dialogTarget.removeEventListener("close", this.handleClose)
    this.dialogTarget.removeEventListener("cancel", this.handleCancel)
    this.dialogTarget.removeEventListener("keydown", this.handleKeydown)
    document.body.classList.remove("overflow-hidden")
  }

  open(e) {
    e?.preventDefault()
    // Reopening during the exit animation must not be closed by the stale animation promise.
    this.closing = false
    this.dialogTarget.dataset.state = "open"
    this.dialogTarget.showModal()
    document.body.classList.add("overflow-hidden")
    this.setTriggersExpanded(true)
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

  // Native <dialog> lets Tab leave the last control for the browser UI before it
  // wraps. Keep focus cycling inside, as the APG dialog pattern asks.
  handleKeydown = (e) => {
    if (e.key !== "Tab" || e.defaultPrevented || e.altKey || e.ctrlKey || e.metaKey) return
    // A nested dialog handles its own Tab.
    if (e.target.closest("dialog") !== this.dialogTarget) return

    const tabbables = this.tabbables()
    if (tabbables.length === 0) {
      e.preventDefault()
      return
    }

    const first = tabbables[0]
    const last = tabbables[tabbables.length - 1]
    const active = document.activeElement
    if (e.shiftKey && (active === first || active === this.dialogTarget)) {
      e.preventDefault()
      last.focus()
    } else if (!e.shiftKey && active === last) {
      e.preventDefault()
      first.focus()
    }
  }

  // Candidates in the browser's sequential focus order: positive tabindex first,
  // ascending, then tabindex 0 in DOM order (Array#sort is stable).
  tabbables() {
    const selector = "a[href], area[href], button, input, select, textarea, iframe, object, embed, summary, audio[controls], video[controls], [contenteditable], [tabindex]"
    return [...this.dialogTarget.querySelectorAll(selector)]
      .filter((el) =>
        this.inTabOrder(el) &&
        !el.matches(":disabled") && // also covers controls inside fieldset[disabled]
        !el.closest("[inert]") &&
        el.closest("dialog") === this.dialogTarget &&
        this.isVisible(el)
      )
      .sort((a, b) => {
        const ta = Math.max(a.tabIndex, 0)
        const tb = Math.max(b.tabIndex, 0)
        if (ta === tb) return 0
        if (ta === 0) return 1
        if (tb === 0) return -1
        return ta - tb
      })
  }

  // An explicit tabindex decides; otherwise the element is natively focusable.
  // `tabIndex` reads -1 for an editing host and (in Chromium and WebKit) for
  // <embed>, yet Tab reaches both. A contenteditable inside another is skipped.
  inTabOrder(el) {
    if (el.hasAttribute("tabindex")) return el.tabIndex >= 0
    if (el.isContentEditable) return !el.parentElement?.isContentEditable
    return el.localName === "embed" || el.tabIndex >= 0
  }

  // checkVisibility() landed in Safari 17.4; older engines fall back to layout boxes.
  isVisible(el) {
    if (typeof el.checkVisibility === "function") return el.checkVisibility({ visibilityProperty: true })
    return el.getClientRects().length > 0
  }

  handleClose = () => {
    this.closing = false
    delete this.dialogTarget.dataset.state
    document.body.classList.remove("overflow-hidden")
    this.setTriggersExpanded(false)
  }

  // Names the dialog after its title/description and ties each trigger to it.
  // Never overwrites ids or ARIA the author already set.
  wireAria() {
    const dialog = this.dialogTarget
    const prefix = `ruby-ui-dialog-${++dialogCount}`
    const dialogId = this.ensureId(dialog, `${prefix}-content`)

    const title = this.ownTarget(this.titleTargets)
    if (title) {
      const titleId = this.ensureId(title, `${prefix}-title`)
      if (!dialog.hasAttribute("aria-labelledby") && !dialog.hasAttribute("aria-label")) {
        dialog.setAttribute("aria-labelledby", titleId)
      }
    }

    const description = this.ownTarget(this.descriptionTargets)
    if (description) {
      const descriptionId = this.ensureId(description, `${prefix}-description`)
      if (!dialog.hasAttribute("aria-describedby")) {
        dialog.setAttribute("aria-describedby", descriptionId)
      }
    }

    this.dialogId = dialogId
    this.triggerControls().forEach((control) => {
      if (!control.hasAttribute("aria-haspopup")) control.setAttribute("aria-haspopup", "dialog")
    })
    this.setTriggersExpanded(dialog.open)
  }

  // First target that lives inside this controller's own <dialog>.
  ownTarget(targets) {
    return targets.find((target) => this.dialogTarget.contains(target))
  }

  ensureId(element, id) {
    if (!element.id) element.id = id
    return element.id
  }

  // The element that carries the trigger's role: a button/link inside the
  // trigger wrapper, or the menuitem/button that wraps it. A role-less wrapper
  // gets no ARIA. The `closest` lookup intentionally climbs above the Dialog root
  // for the dropdown pattern (DropdownMenuItem wraps the Dialog, see
  // docs/app/views/docs/dropdown_menu.rb).
  triggerControls() {
    return this.triggerTargets
      .map((trigger) => trigger.querySelector("button, a[href], [role=button]") || trigger.closest("[role=menuitem], [role=button]"))
      .filter(Boolean)
  }

  // aria-controls is set only while open, as Base UI does. On close only a value
  // pointing at this dialog is removed; one pointing elsewhere is the author's and
  // stays. No state is kept, so a trigger added later or a reconnect (Turbo cache)
  // behaves the same.
  setTriggersExpanded(expanded) {
    this.triggerControls().forEach((control) => {
      control.setAttribute("aria-expanded", String(expanded))
      if (expanded && !control.hasAttribute("aria-controls")) {
        control.setAttribute("aria-controls", this.dialogId)
      } else if (!expanded && control.getAttribute("aria-controls") === this.dialogId) {
        control.removeAttribute("aria-controls")
      }
    })
  }
}
