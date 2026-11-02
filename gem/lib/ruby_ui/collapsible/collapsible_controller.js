import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ruby-ui--collapsible"
//
// The server renders the initial state (hidden, aria-expanded, data-open /
// data-closed), so connect() only syncs it. Each toggle dispatches a cancelable
// ruby-ui--collapsible:change event before the state changes. Changing the
// open value from outside opens or closes without the event.
export default class extends Controller {
  static targets = ["trigger", "content"]
  static values = {
    open: { type: Boolean, default: false },
    disabled: { type: Boolean, default: false },
  }

  initialize() {
    this.ownDisabled = new WeakMap()
  }

  connect() {
    this.sync()
    this.ready = true
  }

  disconnect() {
    this.ready = false
    this.transition = null
  }

  // Target callbacks run before connect() and again whenever Turbo or other
  // code swaps a trigger or the content inside a connected collapsible.
  triggerTargetConnected(trigger) {
    // A trigger rendered with its own disabled: keeps it.
    this.ownDisabled.set(trigger, trigger.disabled && !this.disabledValue)
    if (this.ready) this.syncAttributes()
  }

  contentTargetConnected(content) {
    content.addEventListener("beforematch", this.handleBeforeMatch)
    if (this.ready) this.sync()
  }

  contentTargetDisconnected(content) {
    content.removeEventListener("beforematch", this.handleBeforeMatch)
  }

  toggle() {
    if (this.disabledValue) return
    this.requestOpen(!this.openValue)
  }

  // Find-in-page reached the text inside a hidden="until-found" panel. The
  // browser removes hidden right after this event, so a canceled open puts it
  // back on the next frame.
  handleBeforeMatch = (event) => {
    if (this.openValue) return
    if (this.requestOpen(true)) return
    const content = event.currentTarget
    requestAnimationFrame(() => {
      if (!this.openValue) this.hideContent(content)
    })
  }

  requestOpen(open) {
    const event = this.dispatch("change", { detail: { open }, cancelable: true })
    if (event.defaultPrevented) return false
    this.openValue = open
    return true
  }

  openValueChanged() {
    if (!this.ready) return
    this.openValue ? this.animateOpen() : this.animateClose()
  }

  disabledValueChanged() {
    if (!this.ready) return
    this.syncAttributes()
  }

  // Current state with no animation; also drops a transition a reconnect cut
  // short.
  sync() {
    this.transition = null
    this.syncAttributes()
    this.contentTargets.forEach((content) => {
      content.removeAttribute("data-starting-style")
      content.removeAttribute("data-ending-style")
      if (this.openValue) {
        content.hidden = false
        this.setSize(content, "auto")
      } else {
        this.hideContent(content)
      }
    })
  }

  syncAttributes() {
    const open = this.openValue
    this.toggleAttribute(this.element, "data-open", open)
    this.toggleAttribute(this.element, "data-closed", !open)
    this.toggleAttribute(this.element, "data-disabled", this.disabledValue)

    const controls = this.contentTargets.map((content) => content.id).filter(Boolean).join(" ")
    this.triggerTargets.forEach((trigger) => {
      trigger.setAttribute("aria-expanded", String(open))
      if (controls) trigger.setAttribute("aria-controls", controls)
      this.toggleAttribute(trigger, "data-panel-open", open)
      this.toggleAttribute(trigger, "data-disabled", this.disabledValue)
      if (trigger.tagName === "BUTTON") trigger.disabled = this.disabledValue || this.ownDisabled.get(trigger) === true
    })

    this.contentTargets.forEach((content) => {
      this.toggleAttribute(content, "data-open", open)
      this.toggleAttribute(content, "data-closed", !open)
    })
  }

  animateOpen() {
    const transition = (this.transition = {})
    this.syncAttributes()
    this.contentTargets.forEach((content) => {
      content.removeAttribute("data-ending-style")
      content.hidden = false
      this.setSize(content, `${content.scrollHeight}px`, `${content.scrollWidth}px`)
      content.setAttribute("data-starting-style", "")
      requestAnimationFrame(() => {
        if (this.transition !== transition) return
        content.removeAttribute("data-starting-style")
        this.afterAnimations(content, () => {
          if (this.transition === transition) this.setSize(content, "auto")
        })
      })
    })
  }

  animateClose() {
    const transition = (this.transition = {})
    this.syncAttributes()
    this.contentTargets.forEach((content) => {
      content.removeAttribute("data-starting-style")
      this.setSize(content, `${content.scrollHeight}px`, `${content.scrollWidth}px`)
      requestAnimationFrame(() => {
        if (this.transition !== transition) return
        content.setAttribute("data-ending-style", "")
        this.afterAnimations(content, () => {
          if (this.transition !== transition) return
          content.removeAttribute("data-ending-style")
          this.hideContent(content)
        })
      })
    })
  }

  // Runs callback once the finite animations and transitions the current
  // styles started have finished (at once when there are none). Infinite ones,
  // like animate-pulse, never finish, so they don't hold the panel open.
  afterAnimations(element, callback) {
    requestAnimationFrame(() => {
      const animations = typeof element.getAnimations === "function" ? element.getAnimations() : []
      const finite = animations.filter((animation) => animation.effect?.getComputedTiming().endTime !== Infinity)
      Promise.allSettled(finite.map((animation) => animation.finished)).then(callback)
    })
  }

  hideContent(content) {
    if (content.hasAttribute("data-hidden-until-found")) content.setAttribute("hidden", "until-found")
    else content.hidden = true
    this.setSize(content, "0px")
  }

  setSize(content, height, width = height) {
    content.style.setProperty("--collapsible-panel-height", height)
    content.style.setProperty("--collapsible-panel-width", width)
  }

  toggleAttribute(element, name, on) {
    if (on) element.setAttribute(name, "")
    else element.removeAttribute(name)
  }
}
