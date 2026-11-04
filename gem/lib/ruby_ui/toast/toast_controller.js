import { Controller } from "@hotwired/stimulus"

const SWIPE_THRESHOLD = 40
const DEFAULT_DURATION = 5000
const DIRECTIONS = ["up", "down", "left", "right"]

let uid = 0

// Connects to data-controller="ruby-ui--toast"
//
// One toast: its timer, swipe-to-dismiss and exit. The toaster controller
// (region) owns stacking, limits and pausing; it talks to toasts through
// ruby-ui:toast:* events dispatched on the toast element.
export default class extends Controller {
  static values = {
    duration: Number,
    dismissible: { type: Boolean, default: true },
    swipeDirections: String,
  }

  connect() {
    this._timer = null
    this._startedAt = 0
    this._remaining = 0
    this._holds = new Set()
    this._swipe = null

    this._wireLabels()

    this._onPointerDown = this._onPointerDown.bind(this)
    this._onPointerMove = this._onPointerMove.bind(this)
    this._onPointerUp = this._onPointerUp.bind(this)
    this._onForceDismiss = (e) => { e.stopPropagation(); this._close("dismiss") }
    this._onRestart = () => this._restart()
    this._onHold = (e) => this._setHold(e.detail.reason, e.detail.on)
    this._onKeyDown = (e) => {
      if (e.key === "Escape" && this.element.contains(document.activeElement)) this.dismiss(e)
    }

    this.element.addEventListener("pointerdown", this._onPointerDown)
    this.element.addEventListener("ruby-ui:toast:force-dismiss", this._onForceDismiss)
    this.element.addEventListener("ruby-ui:toast:restart", this._onRestart)
    this.element.addEventListener("ruby-ui:toast:hold", this._onHold)
    this.element.addEventListener("keydown", this._onKeyDown)

    if (this.element.dataset.state === "pending") {
      // Two frames: the toaster paints the start position (off-screen) first,
      // so the move to the stack position transitions.
      this._enterFrame = requestAnimationFrame(() => {
        this._enterFrame = requestAnimationFrame(() => {
          this._enterFrame = null
          this.element.dataset.state = "open"
          this.element.dispatchEvent(new CustomEvent("ruby-ui:toast:opened", { bubbles: true }))
        })
      })
    }
    this._start()
  }

  disconnect() {
    if (this._enterFrame) cancelAnimationFrame(this._enterFrame)
    this._endSwipe({ resume: false })
    this._clearTimer()
    this.element.removeEventListener("pointerdown", this._onPointerDown)
    this.element.removeEventListener("ruby-ui:toast:force-dismiss", this._onForceDismiss)
    this.element.removeEventListener("ruby-ui:toast:restart", this._onRestart)
    this.element.removeEventListener("ruby-ui:toast:hold", this._onHold)
    this.element.removeEventListener("keydown", this._onKeyDown)
  }

  // X, Cancel and swipe: respect dismissible.
  dismiss(e) {
    e?.preventDefault()
    if (!this.dismissibleValue) return
    this._close("dismiss")
  }

  // The action button always closes the toast.
  close(e) {
    e?.preventDefault()
    this._close("dismiss")
  }

  // aria-labelledby / aria-describedby, as Base UI's Toast.Root does. A
  // dialog needs a name: without a title, the description names it, else a
  // generic label. Labels the author set are left alone.
  _wireLabels() {
    const el = this.element
    const filled = (node) => node && node.textContent.trim() !== ""
    const title = el.querySelector('[data-slot="toast-title"]')
    const description = el.querySelector('[data-slot="toast-description"]')
    const base = el.id || `ruby-ui-toast-${++uid}`
    const named = el.hasAttribute("aria-labelledby") || el.hasAttribute("aria-label")
    if (filled(title)) title.id ||= `${base}-title`
    if (filled(description)) description.id ||= `${base}-description`
    if (!named) {
      if (filled(title)) el.setAttribute("aria-labelledby", title.id)
      else if (filled(description)) el.setAttribute("aria-labelledby", description.id)
      else el.setAttribute("aria-label", "Notification")
    }
    const describedByTitle = filled(title) || named
    if (filled(description) && describedByTitle && !el.hasAttribute("aria-describedby")) {
      el.setAttribute("aria-describedby", description.id)
    }
  }

  _duration() {
    if (this.hasDurationValue) return this.durationValue
    const region = this.element.closest('[data-controller~="ruby-ui--toaster"]')
    const inherited = Number(region?.getAttribute("data-ruby-ui--toaster-duration-value"))
    return Number.isNaN(inherited) || region === null ? DEFAULT_DURATION : inherited
  }

  // 0, Infinity and non-numbers mean "stays until dismissed".
  _start() {
    this._clearTimer()
    const duration = this._duration()
    if (!Number.isFinite(duration) || duration <= 0) { this._remaining = Infinity; return }
    this._remaining = duration
    const region = this.element.closest('[data-controller~="ruby-ui--toaster"]')
    if (region?.dataset.paused) this._holds.add("region")
    if (this.element.hasAttribute("data-limited")) this._holds.add("limited")
    if (this._holds.size === 0) this._run()
  }

  _restart() {
    this._start()
  }

  _run() {
    if (!Number.isFinite(this._remaining)) return
    if (this._remaining <= 0) return this._close("auto")
    this._startedAt = performance.now()
    this._timer = setTimeout(() => this._close("auto"), this._remaining)
  }

  _setHold(reason, on) {
    const wasHeld = this._holds.size > 0
    if (on) this._holds.add(reason)
    else this._holds.delete(reason)
    const held = this._holds.size > 0
    if (held && !wasHeld && this._timer) {
      this._clearTimer()
      this._remaining -= performance.now() - this._startedAt
    } else if (!held && wasHeld && this.element.dataset.state !== "closing") {
      this._run()
    }
  }

  _clearTimer() {
    if (this._timer) clearTimeout(this._timer)
    this._timer = null
  }

  _close(reason, exitTransform = null) {
    if (this.element.dataset.state === "closing") return
    const el = this.element
    const detail = { id: el.id, reason }
    el.dataset.state = "closing"
    this._clearTimer()
    this._endSwipe()
    el.removeAttribute("data-behind")
    el.dispatchEvent(new CustomEvent("ruby-ui:toast:close", { bubbles: true, detail }))
    el.dispatchEvent(new CustomEvent(reason === "auto" ? "ruby-ui:toast:auto-close" : "ruby-ui:toast:dismiss", { bubbles: true, detail }))

    const top = el.closest("[data-position]")?.dataset.position?.startsWith("top")
    el.style.transform = exitTransform || `translateY(${top ? "-150%" : "150%"})`

    const transforming = () => el.getAnimations().some((a) => a.transitionProperty === "transform")
    let removed = false
    const remove = () => {
      if (removed) return
      removed = true
      el.removeEventListener("transitionend", onEnd)
      el.removeEventListener("transitioncancel", onEnd)
      el.dispatchEvent(new CustomEvent("ruby-ui:toast:remove", { bubbles: true, detail }))
      el.remove()
    }
    // A cancelled enter transition also fires here; wait for the exit one.
    const onEnd = (e) => { if (e.target === el && e.propertyName === "transform" && !transforming()) remove() }
    el.addEventListener("transitionend", onEnd)
    el.addEventListener("transitioncancel", onEnd)
    // Flush styles so the exit transition starts now; with none running
    // (reduced motion, same transform) there is nothing to wait for.
    void el.offsetWidth
    if (document.hidden || !transforming()) remove()
  }

  _directions() {
    const own = this.swipeDirectionsValue
    const region = this.element.closest('[data-controller~="ruby-ui--toaster"]')
    const list = own || region?.dataset.swipeDirections || "down right"
    if (list === "none") return []
    return list.split(/\s+/).filter((d) => DIRECTIONS.includes(d))
  }

  _onPointerDown(e) {
    if (!this.dismissibleValue || e.button !== 0) return
    if (e.target.closest("button, a, input, select, textarea")) return
    const directions = this._directions()
    if (directions.length === 0) return
    try { this.element.setPointerCapture(e.pointerId) } catch {}
    this._swipe = { x: e.clientX, y: e.clientY, startedAt: performance.now(), base: this.element.style.transform, directions, dx: 0, dy: 0 }
    this._setHold("swipe", true)
    this.element.addEventListener("pointermove", this._onPointerMove)
    this.element.addEventListener("pointerup", this._onPointerUp)
    this.element.addEventListener("pointercancel", this._onPointerUp)
  }

  // Free movement along allowed directions, resistance along the others.
  _onPointerMove(e) {
    const s = this._swipe
    if (!s) return
    const rawX = e.clientX - s.x
    const rawY = e.clientY - s.y
    const allowedX = (rawX > 0 && s.directions.includes("right")) || (rawX < 0 && s.directions.includes("left"))
    const allowedY = (rawY > 0 && s.directions.includes("down")) || (rawY < 0 && s.directions.includes("up"))
    s.dx = allowedX ? rawX : Math.sign(rawX) * Math.sqrt(Math.abs(rawX))
    s.dy = allowedY ? rawY : Math.sign(rawY) * Math.sqrt(Math.abs(rawY))
    this.element.dataset.swipe = "move"
    this.element.style.transform = `translateX(${s.dx}px) translateY(${s.dy}px) ${s.base}`
  }

  _onPointerUp() {
    const s = this._swipe
    if (!s) return
    const elapsed = Math.max(performance.now() - s.startedAt, 1)
    const exits = {
      right: { distance: s.dx, transform: `translateX(calc(${s.dx}px + 150%)) translateY(${s.dy}px) ${s.base}` },
      left: { distance: -s.dx, transform: `translateX(calc(${s.dx}px - 150%)) translateY(${s.dy}px) ${s.base}` },
      down: { distance: s.dy, transform: `translateX(${s.dx}px) translateY(calc(${s.dy}px + 150%)) ${s.base}` },
      up: { distance: -s.dy, transform: `translateX(${s.dx}px) translateY(calc(${s.dy}px - 150%)) ${s.base}` },
    }
    const direction = s.directions.find((d) => {
      const distance = exits[d].distance
      return distance > SWIPE_THRESHOLD || (distance > 10 && distance / elapsed > 0.5)
    })
    const base = s.base
    this._endSwipe()
    if (direction) {
      this.element.dataset.swipe = "end"
      this.element.dataset.swipeDirection = direction
      this._close("dismiss", exits[direction].transform)
    } else {
      this.element.dataset.swipe = "cancel"
      this.element.style.transform = base
    }
  }

  _endSwipe({ resume = true } = {}) {
    if (!this._swipe) return
    this._swipe = null
    this.element.removeEventListener("pointermove", this._onPointerMove)
    this.element.removeEventListener("pointerup", this._onPointerUp)
    this.element.removeEventListener("pointercancel", this._onPointerUp)
    if (resume) this._setHold("swipe", false)
    else this._holds.delete("swipe")
  }
}
