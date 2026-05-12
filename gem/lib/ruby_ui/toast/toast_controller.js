import { Controller } from "@hotwired/stimulus"

const SWIPE_THRESHOLD = 45
const TIME_BEFORE_UNMOUNT = 200

// Connects to data-controller="ruby-ui--toast"
export default class extends Controller {
  static values = {
    duration: { type: Number, default: 4000 },
    dismissible: { type: Boolean, default: true },
    invert: { type: Boolean, default: false },
    onDismiss: String,
    onAutoClose: String,
  }

  connect() {
    this._timer = null
    this._startedAt = 0
    this._remaining = this.durationValue
    this._paused = false
    this._swipe = { active: false, x: 0, y: 0, startedAt: 0 }

    this._onPointerDown = this._onPointerDown.bind(this)
    this._onPointerMove = this._onPointerMove.bind(this)
    this._onPointerUp = this._onPointerUp.bind(this)
    this._onPointerEnter = () => this._pause()
    this._onPointerLeave = () => { if (!this._swipe.active) this._resume() }
    this._onKeyDown = this._onKeyDown.bind(this)
    this._onForceDismiss = (e) => { e.stopPropagation(); this._close() }
    this._onRestart = () => this._restart()
    this._onRegionPause = () => this._pause()
    this._onRegionResume = () => this._resume()

    this.element.addEventListener("pointerdown", this._onPointerDown)
    this.element.addEventListener("pointerenter", this._onPointerEnter)
    this.element.addEventListener("pointerleave", this._onPointerLeave)
    this.element.addEventListener("keydown", this._onKeyDown)
    this.element.addEventListener("ruby-ui:toast:force-dismiss", this._onForceDismiss)
    this.element.addEventListener("ruby-ui:toast:restart", this._onRestart)
    document.addEventListener("ruby-ui:toast:pause", this._onRegionPause)
    document.addEventListener("ruby-ui:toast:resume", this._onRegionResume)

    requestAnimationFrame(() => {
      this.element.dataset.state = "open"
      this._start()
    })
  }

  disconnect() {
    this._clearTimer()
    this.element.removeEventListener("pointerdown", this._onPointerDown)
    this.element.removeEventListener("pointerenter", this._onPointerEnter)
    this.element.removeEventListener("pointerleave", this._onPointerLeave)
    this.element.removeEventListener("keydown", this._onKeyDown)
    this.element.removeEventListener("ruby-ui:toast:force-dismiss", this._onForceDismiss)
    this.element.removeEventListener("ruby-ui:toast:restart", this._onRestart)
    document.removeEventListener("ruby-ui:toast:pause", this._onRegionPause)
    document.removeEventListener("ruby-ui:toast:resume", this._onRegionResume)
  }

  dismiss(e) {
    e?.preventDefault()
    if (!this.dismissibleValue) return
    this._close("dismiss")
  }

  _close(reason) {
    if (this.element.dataset.state === "closing") return
    this.element.dataset.state = "closing"
    this.element.dispatchEvent(new CustomEvent(reason === "auto" ? "ruby-ui:toast:auto-close" : "ruby-ui:toast:dismiss", { bubbles: true, detail: { id: this.element.id } }))
    setTimeout(() => this.element.remove(), TIME_BEFORE_UNMOUNT)
  }

  _start() {
    if (!Number.isFinite(this.durationValue) || this.durationValue <= 0) return
    this._startedAt = performance.now()
    this._remaining = this.durationValue
    this._timer = setTimeout(() => this._close("auto"), this._remaining)
  }

  _restart() {
    this._clearTimer()
    this._start()
  }

  _pause() {
    if (this._paused || !this._timer) return
    this._paused = true
    clearTimeout(this._timer)
    this._timer = null
    this._remaining -= performance.now() - this._startedAt
  }

  _resume() {
    if (!this._paused) return
    this._paused = false
    if (this._remaining <= 0) return this._close("auto")
    this._startedAt = performance.now()
    this._timer = setTimeout(() => this._close("auto"), this._remaining)
  }

  _clearTimer() {
    if (this._timer) clearTimeout(this._timer)
    this._timer = null
  }

  _onKeyDown(e) {
    if (e.key === "Escape" && this.dismissibleValue) this.dismiss(e)
  }

  _onPointerDown(e) {
    if (!this.dismissibleValue) return
    if (e.target.closest("button")) return
    try { this.element.setPointerCapture(e.pointerId) } catch {}
    this._swipe = { active: true, x: e.clientX, y: e.clientY, startedAt: performance.now(), pointerId: e.pointerId }
    this.element.dataset.swipe = "start"
    this.element.addEventListener("pointermove", this._onPointerMove)
    this.element.addEventListener("pointerup", this._onPointerUp)
    this.element.addEventListener("pointercancel", this._onPointerUp)
  }

  _onPointerMove(e) {
    const dx = e.clientX - this._swipe.x
    const dy = e.clientY - this._swipe.y
    this.element.dataset.swipe = "move"
    this.element.style.transform = `translate(${dx}px, ${dy}px)`
  }

  _onPointerUp(e) {
    const dx = e.clientX - this._swipe.x
    const dy = e.clientY - this._swipe.y
    const dist = Math.hypot(dx, dy)
    const dt = performance.now() - this._swipe.startedAt
    const velocity = dist / Math.max(dt, 1)
    this.element.removeEventListener("pointermove", this._onPointerMove)
    this.element.removeEventListener("pointerup", this._onPointerUp)
    this.element.removeEventListener("pointercancel", this._onPointerUp)
    this._swipe.active = false
    if (dist > SWIPE_THRESHOLD || velocity > 0.5) {
      this.element.style.setProperty("--swipe-end-x", `${Math.sign(dx) * 500}px`)
      this.element.style.setProperty("--swipe-end-y", `${Math.sign(dy) * 500}px`)
      this.element.dataset.swipe = "end"
      this.element.style.transform = ""
      this._close("dismiss")
    } else {
      this.element.dataset.swipe = "cancel"
      this.element.style.transform = ""
      this._resume()
    }
  }
}
