import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ruby-ui--input-otp"
export default class extends Controller {
  static targets = ["input", "slot"]
  static values = { length: Number, charClass: String }

  connect() {
    this.paint()
    this.boundOnSelectionChange = this.onSelectionChange.bind(this)
    document.addEventListener("selectionchange", this.boundOnSelectionChange)
  }

  disconnect() {
    document.removeEventListener("selectionchange", this.boundOnSelectionChange)
  }

  onInput() {
    const filtered = this.filter(this.inputTarget.value).slice(0, this.lengthValue)
    if (filtered !== this.inputTarget.value) this.inputTarget.value = filtered

    this.paint()
    this.dispatch("input", { detail: { value: filtered } })
    if (filtered.length === this.lengthValue) {
      this.dispatch("complete", { detail: { value: filtered } })
    }
  }

  onFocus() {
    const end = this.inputTarget.value.length
    const start = Math.min(end, this.lengthValue - 1)
    this.inputTarget.setSelectionRange(start, end)
    this.paint()
  }

  onBlur() {
    this.paint()
  }

  onKeydown(event) {
    const moves = { ArrowLeft: -1, ArrowUp: -1, ArrowRight: 1, ArrowDown: 1 }
    if (!(event.key in moves)) return

    event.preventDefault()
    const current = this.inputTarget.selectionStart ?? 0
    const next = Math.min(Math.max(current + moves[event.key], 0), this.lengthValue - 1)
    this.inputTarget.setSelectionRange(next, next)
    this.paint()
  }

  onPaste(event) {
    event.preventDefault()
    const pasted = this.filter(event.clipboardData.getData("text/plain"))
    if (!pasted) return

    const start = this.inputTarget.selectionStart ?? 0
    const end = this.inputTarget.selectionEnd ?? start
    const current = this.inputTarget.value
    const merged = (current.slice(0, start) + pasted + current.slice(end)).slice(0, this.lengthValue)

    this.inputTarget.value = merged
    const caret = Math.min(merged.length, this.lengthValue - 1)
    this.inputTarget.setSelectionRange(caret, merged.length)

    this.paint()
    this.dispatch("input", { detail: { value: merged } })
    if (merged.length === this.lengthValue) this.dispatch("complete", { detail: { value: merged } })
  }

  onSelectionChange() {
    if (document.activeElement !== this.inputTarget) return
    this.paint()
  }

  filter(raw) {
    const re = new RegExp(this.charClassValue)
    return raw.split("").filter((char) => re.test(char)).join("")
  }

  paint() {
    const value = this.inputTarget.value
    const isFocused = document.activeElement === this.inputTarget
    const start = this.inputTarget.selectionStart ?? value.length
    const end = this.inputTarget.selectionEnd ?? value.length
    const activeIndex = Math.min(start, this.lengthValue - 1)

    this.slotTargets.forEach((slot) => {
      const index = Number(slot.dataset.index)
      const char = value[index] ?? ""
      const isActive = isFocused && ((start === end && index === activeIndex) || (index >= start && index < end))

      slot.textContent = char
      slot.dataset.active = isActive ? "true" : "false"
      slot.dataset.caret = isActive && char === "" ? "true" : "false"
    })
  }
}
