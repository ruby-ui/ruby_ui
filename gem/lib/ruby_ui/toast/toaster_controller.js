import { Controller } from "@hotwired/stimulus"

const VARIANTS = ["default", "success", "error", "warning", "info", "loading"]
const PEEK = 12
const SCALE_STEP = 0.1

let streamActionRegistered = false

function registerStreamAction() {
  if (streamActionRegistered) return
  if (typeof window === "undefined") return
  const Turbo = window.Turbo
  if (!Turbo?.StreamActions) return
  Turbo.StreamActions.toast = function () {
    const detail = {}
    for (const attr of this.attributes) {
      if (attr.name === "action" || attr.name === "target" || attr.name === "targets") continue
      detail[attr.name] = attr.value
    }
    if (detail.duration != null && detail.duration !== "") detail.duration = Number(detail.duration)
    if (detail.dismissible != null) detail.dismissible = detail.dismissible !== "false"
    window.dispatchEvent(new CustomEvent("ruby-ui:toast", { detail }))
  }
  streamActionRegistered = true
}

// Connects to data-controller="ruby-ui--toaster"
//
// The toast viewport (shadcn's Base UI Toaster): stacks the toasts, limits how
// many show, pauses every timer while the region is hovered or focused (or the
// window is blurred), focuses the region on the hotkey (F6), and spawns
// toasts from window.RubyUI.toast / the ruby-ui:toast event / Turbo Streams.
export default class extends Controller {
  static targets = ["skeleton", "toast", "actionTpl", "cancelTpl", "closeTpl"]
  static values = {
    position: { type: String, default: "bottom-right" },
    expand: { type: Boolean, default: false },
    max: { type: Number, default: 3 },
    duration: { type: Number, default: 5000 },
    gap: { type: Number, default: 12 },
    closeButton: { type: Boolean, default: true },
    hotkey: { type: String, default: "F6" },
    swipeDirections: String,
  }

  initialize() {
    this._hovered = false
    this._holds = new Set()
    this._heights = new WeakMap()
    this._resizeObservers = new WeakMap()
    this._announcers = new Map() // toast element -> its hidden role=alert
  }

  connect() {
    // Turbo moves this permanent region between pages: start from a clean
    // pause state instead of whatever the last page left behind.
    this._hovered = this.element.matches(":hover")
    this._holds.clear()
    delete this.element.dataset.paused
    this._listEl = this.element.querySelector("#ruby-ui-toaster") || this.element
    this._registerGlobalApi()
    registerStreamAction()
    this._showPopover()

    this._onPointerEnter = () => { this._hovered = true; this._setHold("hover", true); this._reflow() }
    this._onPointerLeave = () => { this._hovered = false; this._setHold("hover", false); this._reflow() }
    this._onFocusIn = () => { this._setHold("focus", true); this._reflow() }
    this._onFocusOut = (e) => {
      if (this.element.contains(e.relatedTarget)) return
      this._setHold("focus", false)
      this._reflow()
    }
    this._onWindowBlur = (e) => { if (e.target === window) this._setHold("window", true) }
    this._onWindowFocus = (e) => { if (e.target === window) this._setHold("window", false) }
    this._onWindowToast = (e) => this._spawn(e.detail || {})
    this._onWindowDismissAll = () => this._dismissById(null)
    this._onToastChange = () => this._reflow()
    this._onToastRemove = (e) => this._handOffFocus(e.target)
    this._onRegionKeyDown = (e) => {
      // Base UI: Tab from the focused viewport goes to the front toast.
      if (e.key !== "Tab" || e.shiftKey || document.activeElement !== this.element) return
      const front = this._frontToast()
      if (!front) return
      e.preventDefault()
      front.focus()
    }
    this._onKey = this._onKey.bind(this)

    window.addEventListener("ruby-ui:toast", this._onWindowToast)
    window.addEventListener("ruby-ui:toast:dismiss-all", this._onWindowDismissAll)
    window.addEventListener("blur", this._onWindowBlur, true)
    window.addEventListener("focus", this._onWindowFocus, true)
    this.element.addEventListener("pointerenter", this._onPointerEnter)
    this.element.addEventListener("pointerleave", this._onPointerLeave)
    this.element.addEventListener("focusin", this._onFocusIn)
    this.element.addEventListener("focusout", this._onFocusOut)
    this.element.addEventListener("ruby-ui:toast:opened", this._onToastChange)
    this.element.addEventListener("ruby-ui:toast:close", this._onToastChange)
    this.element.addEventListener("ruby-ui:toast:remove", this._onToastRemove)
    this.element.addEventListener("keydown", this._onRegionKeyDown)
    document.addEventListener("keydown", this._onKey)

    if (this._hovered) this._setHold("hover", true)
    if (this.element.contains(document.activeElement)) this._setHold("focus", true)
    this._syncSwipeDirections()
    this._reflow()
  }

  disconnect() {
    window.removeEventListener("ruby-ui:toast", this._onWindowToast)
    window.removeEventListener("ruby-ui:toast:dismiss-all", this._onWindowDismissAll)
    window.removeEventListener("blur", this._onWindowBlur, true)
    window.removeEventListener("focus", this._onWindowFocus, true)
    this.element.removeEventListener("pointerenter", this._onPointerEnter)
    this.element.removeEventListener("pointerleave", this._onPointerLeave)
    this.element.removeEventListener("focusin", this._onFocusIn)
    this.element.removeEventListener("focusout", this._onFocusOut)
    this.element.removeEventListener("ruby-ui:toast:opened", this._onToastChange)
    this.element.removeEventListener("ruby-ui:toast:close", this._onToastChange)
    this.element.removeEventListener("ruby-ui:toast:remove", this._onToastRemove)
    this.element.removeEventListener("keydown", this._onRegionKeyDown)
    document.removeEventListener("keydown", this._onKey)
    this._holds.clear()
    delete this.element.dataset.paused
    this._announcers.forEach((node) => node.remove())
    this._announcers.clear()
  }

  positionValueChanged(value) {
    this.element.setAttribute("data-position", value)
    this._syncSwipeDirections()
    this._reflow()
  }

  expandValueChanged() {
    this._reflow()
  }

  swipeDirectionsValueChanged() {
    this._syncSwipeDirections()
  }

  toastTargetConnected(el) {
    this._resizeObservers.get(el)?.disconnect()
    if (typeof ResizeObserver !== "undefined") {
      const ro = new ResizeObserver(() => {
        // Only a toast at its own height tells us its natural height.
        if (el.style.height !== "") return
        if (this._heights.get(el) === el.offsetHeight) return
        this._heights.set(el, el.offsetHeight)
        this._reflow()
      })
      ro.observe(el)
      this._resizeObservers.set(el, ro)
    }
    this._heights.set(el, el.offsetHeight)
    if (this._holds.size > 0) el.dispatchEvent(new CustomEvent("ruby-ui:toast:hold", { detail: { reason: "region", on: true } }))
    if (el.dataset.priority === "high") this._announce(el)
    this._raiseAboveModals()
    this._reflow()
  }

  toastTargetDisconnected(el) {
    this._resizeObservers.get(el)?.disconnect()
    this._resizeObservers.delete(el)
    this._removeAnnouncer(el)
    this._reflow()
  }

  // ---- top layer -------------------------------------------------------

  _showPopover() {
    if (typeof this.element.showPopover !== "function") return
    try {
      if (!this.element.matches(":popover-open")) this.element.showPopover()
    } catch {}
  }

  // A modal <dialog> (RubyUI Dialog, AlertDialog, Sheet) sits in the top
  // layer; showing the region again puts it above that dialog so new toasts
  // are visible. (The page behind a modal stays inert, so they are not
  // clickable until it closes.)
  _raiseAboveModals() {
    if (typeof this.element.showPopover !== "function") return
    if (!document.querySelector("dialog:modal")) return
    if (this.element.contains(document.activeElement)) return
    try {
      if (this.element.matches(":popover-open")) this.element.hidePopover()
      this.element.showPopover()
    } catch {}
  }

  // ---- pausing ---------------------------------------------------------

  _setHold(reason, on) {
    const wasHeld = this._holds.size > 0
    if (on) this._holds.add(reason)
    else this._holds.delete(reason)
    const held = this._holds.size > 0
    if (held) this.element.dataset.paused = [...this._holds].join(" ")
    else delete this.element.dataset.paused
    if (reason === "focus") this._syncHighPriorityVisibility(on)
    if (held === wasHeld) return
    this.toastTargets.forEach((el) =>
      el.dispatchEvent(new CustomEvent("ruby-ui:toast:hold", { detail: { reason: "region", on: held } }))
    )
  }

  // A focused toast leaving the DOM fires no focusout: move focus to the next
  // front toast, else back to where it was before F6, and drop the focus hold.
  _handOffFocus(toast) {
    if (!toast.contains(document.activeElement)) return
    const next = this._frontToast(toast)
    if (next) return next.focus()
    const previous = this._previousFocus
    this._previousFocus = null
    if (previous?.isConnected) previous.focus({ preventScroll: true })
    else document.activeElement?.blur()
    this._setHold("focus", false)
    this._reflow()
  }

  _frontToast(except = null) {
    return this.toastTargets
      .filter((el) => el !== except && el.dataset.state !== "closing" && !el.hasAttribute("data-limited"))
      .at(-1)
  }

  // ---- high priority (Base UI): role=alertdialog, announced through a
  // visually hidden role=alert; the toast itself is hidden from AT until
  // focus enters the region, so it isn't read twice.

  _announce(el) {
    if (this._holds.has("focus")) return
    const title = el.querySelector('[data-slot="toast-title"]')?.textContent || ""
    const description = el.querySelector('[data-slot="toast-description"]')?.textContent || ""
    const node = document.createElement("div")
    node.setAttribute("role", "alert")
    node.setAttribute("aria-atomic", "true")
    node.className = "sr-only"
    node.dataset.toastAnnouncement = ""
    node.textContent = [title, description].filter(Boolean).join(". ")
    this.element.insertAdjacentElement("afterend", node)
    this._announcers.get(el)?.remove()
    this._announcers.set(el, node)
    el.setAttribute("aria-hidden", "true")
  }

  _removeAnnouncer(el) {
    this._announcers.get(el)?.remove()
    this._announcers.delete(el)
  }

  // With focus inside, the toasts themselves are read: drop the hidden
  // announcements (so nothing is read twice) and expose the toasts.
  _syncHighPriorityVisibility(focused) {
    if (focused) {
      this._announcers.forEach((node) => node.remove())
      this._announcers.clear()
    }
    this.toastTargets
      .filter((el) => el.dataset.priority === "high")
      .forEach((el) => (focused ? el.removeAttribute("aria-hidden") : el.setAttribute("aria-hidden", "true")))
  }

  // ---- stacking --------------------------------------------------------

  _isTop() {
    return this.positionValue.startsWith("top")
  }

  _syncSwipeDirections() {
    let directions = this.swipeDirectionsValue
    if (!directions) {
      const position = this.positionValue
      directions = [
        position.startsWith("top") ? "up" : "down",
        position.endsWith("right") ? "right" : position.endsWith("left") ? "left" : null,
      ].filter(Boolean).join(" ")
    }
    this.element.dataset.swipeDirections = directions
  }

  _naturalHeight(el) {
    return this._heights.get(el) || el.offsetHeight || 64
  }

  // Base UI's stack: newest in front; collapsed toasts peek 12px and shrink
  // 10% per step, at the front toast's height with their content hidden;
  // expanded toasts sit `gap` apart. Toasts past `max` stay mounted but hidden
  // (data-limited) and come back when a front toast closes.
  _reflow() {
    if (!this._listEl) return
    const top = this._isTop()
    const sign = top ? 1 : -1
    const expanded = this.expandValue || this._hovered || this._holds.has("focus")
    const order = this.toastTargets.filter((el) => el.dataset.state !== "closing").reverse()
    const frontHeight = order.length ? this._naturalHeight(order[0]) : 0
    let offset = 0

    order.forEach((el, i) => {
      const limited = i >= this.maxValue
      this._setLimited(el, limited)
      el.style.zIndex = String(1000 - i)
      el.style.transformOrigin = top ? "center top" : "center bottom"
      el.style.top = top ? "0" : "auto"
      el.style.bottom = top ? "auto" : "0"

      if (expanded) {
        el.removeAttribute("data-behind")
        el.style.height = ""
        el.style.transform = el.dataset.state === "pending" ? this._startTransform() : `translateY(${sign * offset}px)`
      } else {
        const scale = Math.max(0, 1 - i * SCALE_STEP)
        const lift = i * PEEK + (1 - scale) * frontHeight
        if (i > 0) el.setAttribute("data-behind", "")
        else el.removeAttribute("data-behind")
        el.style.height = i > 0 ? `${frontHeight}px` : ""
        el.style.transform = el.dataset.state === "pending" ? this._startTransform() : `translateY(${sign * lift}px) scale(${scale})`
      }
      if (el.dataset.state === "pending") void el.offsetWidth // paint the start position before it opens

      offset += this._naturalHeight(el) + this.gapValue
    })
    this.element.dataset.expanded = String(expanded)
  }

  _startTransform() {
    return `translateY(${this._isTop() ? "-150%" : "150%"})`
  }

  _setLimited(el, limited) {
    if (limited === el.hasAttribute("data-limited")) return
    if (limited) {
      el.setAttribute("data-limited", "")
      el.inert = true
    } else {
      el.removeAttribute("data-limited")
      el.inert = false
    }
    el.dispatchEvent(new CustomEvent("ruby-ui:toast:hold", { detail: { reason: "limited", on: limited } }))
  }

  // ---- spawning --------------------------------------------------------

  _spawn(detail) {
    if (!this._listEl) return null
    const variant = VARIANTS.includes(detail.variant) ? detail.variant : "default"
    const tpl = this._skeletonFor(variant)
    if (!tpl) return null
    if (detail.position) this.positionValue = detail.position
    const node = tpl.content.firstElementChild.cloneNode(true)
    const content = node.querySelector('[data-slot="toast-content"]') || node

    node.id = detail.id || `toast-${this._uuid()}`
    const duration = detail.duration ?? this.durationValue
    node.setAttribute("data-ruby-ui--toast-duration-value", String(duration === Infinity ? 0 : duration))
    if (detail.dismissible === false) node.setAttribute("data-ruby-ui--toast-dismissible-value", "false")
    if (detail.swipeDirections) {
      const list = [].concat(detail.swipeDirections)
      node.setAttribute("data-ruby-ui--toast-swipe-directions-value", list.length ? list.join(" ") : "none")
    }
    if (detail.priority === "high") {
      node.dataset.priority = "high"
      node.setAttribute("role", "alertdialog")
    }
    if (detail.className) node.className += ` ${detail.className}`

    const titleEl = node.querySelector('[data-slot="toast-title"]')
    if (titleEl) titleEl.textContent = detail.title || detail.message || ""
    const descEl = node.querySelector('[data-slot="toast-description"]')
    if (descEl) {
      if (detail.description) descEl.textContent = detail.description
      else descEl.remove()
    }

    let close = node.querySelector('[data-slot="toast-close"]')
    if (detail.closeButton === false && close) {
      close.remove()
      close = null
    } else if (detail.closeButton === true && !close && this.hasCloseTplTarget) {
      close = this._cloneSlot(this.closeTplTarget)
      content.appendChild(close)
    }

    if (detail.cancel?.label && this.hasCancelTplTarget) {
      const btn = this._cloneSlot(this.cancelTplTarget)
      btn.textContent = detail.cancel.label
      if (detail.cancel.onClick) btn.addEventListener("click", (ev) => detail.cancel.onClick(ev))
      content.insertBefore(btn, close)
    }

    if (detail.action?.label && this.hasActionTplTarget) {
      const btn = this._cloneSlot(this.actionTplTarget)
      btn.textContent = detail.action.label
      if (detail.action.onClick) btn.addEventListener("click", (ev) => detail.action.onClick(ev))
      content.insertBefore(btn, close)
    }

    if (typeof detail.onClose === "function") node.addEventListener("ruby-ui:toast:close", (e) => detail.onClose(e.detail))
    if (typeof detail.onRemove === "function") node.addEventListener("ruby-ui:toast:remove", (e) => detail.onRemove(e.detail))

    this._listEl.appendChild(node)
    return node.id
  }

  _dismissById(id) {
    const targets = id ? [this._listEl?.querySelector(`#${CSS.escape(id)}`)].filter(Boolean) : this.toastTargets
    targets.forEach((el) => el.dispatchEvent(new CustomEvent("ruby-ui:toast:force-dismiss", { bubbles: true })))
  }

  _skeletonFor(variant) {
    return this.skeletonTargets.find((t) => t.dataset.variant === variant)
  }

  _cloneSlot(tpl) {
    return tpl.content.firstElementChild.cloneNode(true)
  }

  // Base UI: the hotkey (F6) moves focus to the viewport; Tab then goes to
  // the front toast.
  _onKey(e) {
    if (!e.key) return
    const parts = (this.hotkeyValue || "F6").toLowerCase().split("+")
    const key = parts.pop()
    if (e.key.toLowerCase() !== key) return
    if (parts.includes("alt") !== e.altKey) return
    if (parts.includes("ctrl") !== e.ctrlKey) return
    if (parts.includes("meta") !== e.metaKey) return
    if (parts.includes("shift") !== e.shiftKey) return
    if (!this._frontToast() || document.activeElement === this.element) return
    e.preventDefault()
    if (!this.element.contains(document.activeElement)) this._previousFocus = document.activeElement
    this.element.focus({ preventScroll: true })
  }

  _registerGlobalApi() {
    const fire = (variant, message, opts = {}) => {
      const id = opts.id || `toast-${this._uuid()}`
      window.dispatchEvent(new CustomEvent("ruby-ui:toast", {
        detail: { ...opts, id, variant, message: opts.title || message }
      }))
      return id
    }

    const api = (message, opts) => fire("default", message, opts)
    api.success = (m, o) => fire("success", m, o)
    api.error = (m, o) => fire("error", m, o)
    api.warning = (m, o) => fire("warning", m, o)
    api.info = (m, o) => fire("info", m, o)
    api.loading = (m, o = {}) => fire("loading", m, { ...o, duration: o.duration ?? 0 })
    api.dismiss = (id) => {
      if (id) this._dismissById(id)
      else window.dispatchEvent(new CustomEvent("ruby-ui:toast:dismiss-all"))
    }
    api.close = api.dismiss
    api.promise = (p, msgs = {}) => {
      const id = fire("loading", typeof msgs.loading === "function" ? msgs.loading() : (msgs.loading || "Loading..."), { duration: 0 })
      Promise.resolve(p).then(
        (val) => this._mutate(id, "success", typeof msgs.success === "function" ? msgs.success(val) : msgs.success),
        (err) => this._mutate(id, "error", typeof msgs.error === "function" ? msgs.error(err) : msgs.error)
      )
      return id
    }

    window.RubyUI = window.RubyUI || {}
    window.RubyUI.toast = api
  }

  _mutate(id, variant, text) {
    const el = this._listEl?.querySelector(`#${CSS.escape(id)}`)
    if (!el) return
    el.dataset.variant = variant
    el.dataset.type = variant
    this._swapIcon(el, variant)
    const t = el.querySelector('[data-slot="toast-title"]')
    if (t && text) t.textContent = text
    el.setAttribute("data-ruby-ui--toast-duration-value", String(this.durationValue))
    el.dispatchEvent(new CustomEvent("ruby-ui:toast:restart", { bubbles: true }))
  }

  _swapIcon(el, variant) {
    const iconHost = el.querySelector('[data-slot="toast-icon"]')
    if (!iconHost) return
    const tpl = this._skeletonFor(variant)
    if (!tpl) return
    const sourceIcon = tpl.content.firstElementChild?.querySelector('[data-slot="toast-icon"]')
    iconHost.innerHTML = sourceIcon ? sourceIcon.innerHTML : ""
  }

  _uuid() {
    if (typeof crypto !== "undefined" && crypto.randomUUID) return crypto.randomUUID()
    return Math.random().toString(36).slice(2) + Date.now().toString(36)
  }
}
