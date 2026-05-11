import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ruby-ui--toggle-group"
export default class extends Controller {
  static targets = ["item", "input"]
  static values = { type: String, name: String }

  connect() {
    this.reconcile()
  }

  select(event) {
    const item = event.currentTarget
    if (item.disabled) return

    if (this.typeValue === "single") {
      this.itemTargets.forEach(el => this.setPressed(el, el === item))
    } else {
      this.setPressed(item, !this.isPressed(item))
    }

    this.rebuildInputs()
    this.updateRovingTabindex(item)
  }

  navigate(event) {
    if (this.typeValue !== "single") return
    const items = this.enabledItems()
    if (items.length === 0) return

    const isRtl = document.documentElement.dir === "rtl"
    const currentIndex = items.indexOf(event.currentTarget)
    let nextIndex = currentIndex

    switch (event.key) {
      case "ArrowRight":
      case "ArrowDown":
        nextIndex = (currentIndex + (isRtl && event.key === "ArrowRight" ? -1 : 1) + items.length) % items.length
        break
      case "ArrowLeft":
      case "ArrowUp":
        nextIndex = (currentIndex + (isRtl && event.key === "ArrowLeft" ? 1 : -1) + items.length) % items.length
        break
      case "Home":
        nextIndex = 0
        break
      case "End":
        nextIndex = items.length - 1
        break
      case " ":
      case "Enter":
        event.preventDefault()
        event.currentTarget.click()
        return
      default:
        return
    }

    event.preventDefault()
    const next = items[nextIndex]
    this.updateRovingTabindex(next)
    next.focus()
  }

  reconcile() {
    if (this.typeValue === "single") {
      const pressed = this.itemTargets.find(el => this.isPressed(el))
      const first = pressed || this.enabledItems()[0]
      this.itemTargets.forEach(el => {
        el.setAttribute("tabindex", el === first ? "0" : "-1")
      })
    } else {
      this.itemTargets.forEach(el => el.setAttribute("tabindex", "0"))
    }
    this.rebuildInputs()
  }

  isPressed(item) {
    return item.dataset.state === "on"
  }

  setPressed(item, pressed) {
    item.dataset.state = pressed ? "on" : "off"
    if (this.typeValue === "single") {
      item.setAttribute("aria-checked", pressed ? "true" : "false")
    } else {
      item.setAttribute("aria-pressed", pressed ? "true" : "false")
    }
  }

  updateRovingTabindex(focusedItem) {
    if (this.typeValue !== "single") return
    this.itemTargets.forEach(el => {
      el.setAttribute("tabindex", el === focusedItem ? "0" : "-1")
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
