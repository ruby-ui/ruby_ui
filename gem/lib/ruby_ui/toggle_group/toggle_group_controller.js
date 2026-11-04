import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ruby-ui--toggle-group"
export default class extends Controller {
  static targets = ["item", "input"]
  static values = {
    type: String,
    name: String,
    orientation: { type: String, default: "horizontal" },
    loopFocus: { type: Boolean, default: true }
  }

  connect() {
    this.reconcile()
    // Keep one tab stop when an item gets disabled or enabled later.
    this.observer = new MutationObserver(() => this.ensureTabStop())
    this.observer.observe(this.element, { subtree: true, attributes: true, attributeFilter: ["disabled"] })
  }

  disconnect() {
    this.observer?.disconnect()
    this.observer = null
  }

  // Items added or removed after connect: keep one tab stop and the hidden
  // inputs in sync with what is pressed.
  itemTargetConnected() {
    this.ensureTabStop()
    this.rebuildInputs()
  }

  itemTargetDisconnected() {
    this.ensureTabStop()
    this.rebuildInputs()
  }

  // Native <button> activation (click, Enter, Space) lands here.
  select(event) {
    const item = event.currentTarget
    if (item.disabled) return

    if (this.typeValue === "single") {
      // Like Base UI: pressing the pressed item clears the value.
      const pressed = !this.isPressed(item)
      this.itemTargets.forEach(el => this.setPressed(el, el === item && pressed))
    } else {
      this.setPressed(item, !this.isPressed(item))
    }

    this.rebuildInputs()
    this.setTabStop(item)
  }

  navigate(event) {
    const items = this.enabledItems()
    const currentIndex = items.indexOf(event.currentTarget)
    if (currentIndex === -1) return

    const step = this.stepFor(event.key)
    let nextIndex

    if (event.key === "Home") {
      nextIndex = 0
    } else if (event.key === "End") {
      nextIndex = items.length - 1
    } else if (step) {
      nextIndex = currentIndex + step
      if (nextIndex < 0 || nextIndex >= items.length) {
        // At an end with loop_focus: false the key is still ours: don't scroll the page.
        if (!this.loopFocusValue) return event.preventDefault()
        nextIndex = (nextIndex + items.length) % items.length
      }
    } else {
      return
    }

    event.preventDefault()
    const next = items[nextIndex]
    this.setTabStop(next)
    next.focus()
  }

  // Arrow keys follow the orientation: Left/Right when horizontal (flipped in
  // RTL), Up/Down when vertical.
  stepFor(key) {
    if (this.orientationValue === "vertical") {
      if (key === "ArrowDown") return 1
      if (key === "ArrowUp") return -1
      return 0
    }

    const rtl = getComputedStyle(this.element).direction === "rtl"
    if (key === "ArrowRight") return rtl ? -1 : 1
    if (key === "ArrowLeft") return rtl ? 1 : -1
    return 0
  }

  // One tab stop per group: the first pressed enabled item, else the first
  // enabled item.
  reconcile() {
    const enabled = this.enabledItems()
    this.setTabStop(enabled.find(el => this.isPressed(el)) || enabled[0])
    this.rebuildInputs()
  }

  // Keeps exactly one tab stop: the current one if it is still enabled, else
  // the first pressed enabled item, else the first enabled item.
  ensureTabStop() {
    const enabled = this.enabledItems()
    this.setTabStop(
      enabled.find(el => el.getAttribute("tabindex") === "0") ||
        enabled.find(el => this.isPressed(el)) ||
        enabled[0]
    )
  }

  isPressed(item) {
    return item.dataset.state === "on"
  }

  setPressed(item, pressed) {
    item.dataset.state = pressed ? "on" : "off"
    item.setAttribute("aria-pressed", pressed ? "true" : "false")
    item.toggleAttribute("data-pressed", pressed)
  }

  setTabStop(stop) {
    this.itemTargets.forEach(el => {
      el.setAttribute("tabindex", el === stop ? "0" : "-1")
    })
  }

  enabledItems() {
    return this.itemTargets.filter(el => !el.disabled)
  }

  rebuildInputs() {
    if (!this.nameValue) return
    this.inputTargets.forEach(el => el.remove())

    const pressed = this.itemTargets.filter(el => this.isPressed(el))

    if (this.typeValue === "single") {
      const val = pressed[0]?.dataset.value || ""
      this.element.appendChild(this.buildInput(this.nameValue, val))
    } else {
      pressed.forEach(item => {
        this.element.appendChild(this.buildInput(`${this.nameValue}[]`, item.dataset.value))
      })
    }
  }

  buildInput(name, value) {
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = name
    input.value = value
    input.setAttribute("data-ruby-ui--toggle-group-target", "input")
    return input
  }
}
