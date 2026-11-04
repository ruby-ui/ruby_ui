import { Controller } from "@hotwired/stimulus"

// Prefix for generated ids, unique per page (ruby-ui-sheet-1-title, …).
let sheetCount = 0

// Connects to data-controller="ruby-ui--sheet"
// The panel is a native <dialog> opened with showModal(). Exit, Tab loop and
// ARIA wiring match RubyUI's Dialog controller; the Turbo and scroll-lock
// lifecycle matches AlertDialog's.
export default class extends Controller {
  static targets = ["content", "title", "description", "trigger"]
  static values = {
    open: {
      type: Boolean,
      default: false
    },
  }

  // Target callbacks (they run before connect) also cover Turbo replacing only
  // the panel while the Sheet root stays.
  contentTargetConnected(content) {
    // A Turbo cache snapshot keeps `open` but not modality; don't restore it half-open.
    if (content.open && !content.matches(":modal")) content.close()
    content.addEventListener("close", this.handleClose)
    content.addEventListener("cancel", this.handleCancel)
    content.addEventListener("keydown", this.handleKeydown)
    this.wireAria()
  }

  contentTargetDisconnected(content) {
    content.removeEventListener("close", this.handleClose)
    content.removeEventListener("cancel", this.handleCancel)
    content.removeEventListener("keydown", this.handleKeydown)
    this.closing = false
    this.releaseScroll()
  }

  connect() {
    this.closing = false
    document.addEventListener("turbo:before-cache", this.handleBeforeCache)
    if (this.openValue) {
      this.open()
    }
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.handleBeforeCache)
    this.closing = false
    this.releaseScroll()
  }

  open(e) {
    e?.preventDefault()
    if (!this.hasContentTarget) return

    // Reopening during the exit animation must not be closed by the stale animation promise.
    this.closing = false
    this.contentTarget.dataset.state = "open"
    if (!this.contentTarget.open) this.contentTarget.showModal()
    this.scrollLocked = true
    document.body.classList.add("overflow-hidden")
    this.setTriggersExpanded(true)
  }

  // Turbo snapshots the page right after this event and `close` fires later,
  // so clean up synchronously: the cache never keeps an open sheet or a locked body.
  handleBeforeCache = () => {
    if (!this.hasContentTarget || !this.contentTarget.open) return

    this.closing = false
    this.contentTarget.close()
    delete this.contentTarget.dataset.state
    this.releaseScroll()
    this.setTriggersExpanded(false)
  }

  // Only release a lock this sheet took, and keep it while another modal is open.
  releaseScroll() {
    if (!this.scrollLocked) return

    this.scrollLocked = false
    if (!document.querySelector("dialog:modal")) document.body.classList.remove("overflow-hidden")
  }

  dismiss() {
    this.animateClose()
  }

  // Plays the exit animation on the panel and its ::backdrop, then closes.
  async animateClose() {
    if (this.closing || !this.hasContentTarget || !this.contentTarget.open) return

    this.closing = true
    this.contentTarget.dataset.state = "closed"
    await Promise.allSettled(this.ownAnimations().map((animation) => animation.finished))
    // handleClose/disconnect reset `closing`: the dialog already closed (e.g. a forced
    // second Esc) and may have been reopened since, so don't close it again.
    if (this.closing) this.contentTarget.close()
  }

  // Only the dialog's own animations (panel + ::backdrop), never its descendants'.
  ownAnimations() {
    return document.getAnimations().filter((animation) => animation.effect?.target === this.contentTarget)
  }

  // The panel's own padding also reports the <dialog> as target, so only a press
  // that starts and ends outside the panel's rect counts as a backdrop click.
  backdropPointerdown(e) {
    this.pressStartedOutside = e.target === this.contentTarget && this.isOutsidePanel(e)
  }

  backdropClick(e) {
    const startedOutside = this.pressStartedOutside
    this.pressStartedOutside = false
    if (e.target !== this.contentTarget) return

    if (startedOutside && this.isOutsidePanel(e)) {
      this.dismiss()
    }
  }

  isOutsidePanel(e) {
    const rect = this.contentTarget.getBoundingClientRect()
    return e.clientX < rect.left || e.clientX > rect.right || e.clientY < rect.top || e.clientY > rect.bottom
  }

  // Esc fires `cancel`; hold the native close so the exit animation can play.
  // A dismissed <input type="file"> picker also fires a bubbling `cancel`; ignore it.
  handleCancel = (e) => {
    if (e.target !== this.contentTarget) return
    e.preventDefault()
    this.animateClose()
  }

  // Native <dialog> lets Tab leave the last control for the browser UI before it
  // wraps. Keep focus cycling inside, as the APG dialog pattern asks.
  handleKeydown = (e) => {
    if (e.key !== "Tab" || e.defaultPrevented || e.altKey || e.ctrlKey || e.metaKey) return
    // A nested dialog handles its own Tab.
    if (e.target.closest("dialog") !== this.contentTarget) return

    const tabbables = this.tabbables()
    if (tabbables.length === 0) {
      e.preventDefault()
      return
    }

    const first = tabbables[0]
    const last = tabbables[tabbables.length - 1]
    const active = document.activeElement
    if (e.shiftKey && (active === first || active === this.contentTarget)) {
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
    return [...this.contentTarget.querySelectorAll(selector)]
      .filter((el) =>
        this.inTabOrder(el) &&
        !el.matches(":disabled") && // also covers controls inside fieldset[disabled]
        !el.closest("[inert]") &&
        el.closest("dialog") === this.contentTarget &&
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

  handleClose = (e) => {
    this.closing = false
    delete e.currentTarget.dataset.state
    this.releaseScroll()
    this.setTriggersExpanded(false)
  }

  // Names the dialog after its title/description and ties each trigger to it.
  // Never overwrites ids or ARIA the author already set.
  wireAria() {
    const dialog = this.contentTarget
    const prefix = `ruby-ui-sheet-${++sheetCount}`
    const contentId = this.ensureId(dialog, `${prefix}-content`)

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

    this.contentId = contentId
    this.triggerControls().forEach((control) => {
      if (!control.hasAttribute("aria-haspopup")) control.setAttribute("aria-haspopup", "dialog")
    })
    this.setTriggersExpanded(dialog.open)
  }

  // First target that lives inside this controller's own <dialog>.
  ownTarget(targets) {
    return targets.find((target) => this.contentTarget.contains(target))
  }

  ensureId(element, id) {
    if (!element.id) element.id = id
    return element.id
  }

  // The element that carries the trigger's role: a button/link inside the
  // trigger wrapper, or the menuitem/button that wraps it. A role-less wrapper
  // gets no ARIA. The `closest` lookup climbs above the Sheet root, as Dialog's
  // does, so a menu item that wraps the Sheet carries the ARIA.
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
        control.setAttribute("aria-controls", this.contentId)
      } else if (!expanded && control.getAttribute("aria-controls") === this.contentId) {
        control.removeAttribute("aria-controls")
      }
    })
  }
}
