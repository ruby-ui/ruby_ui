import { Controller } from "@hotwired/stimulus"

const VARIANTS = ["default", "success", "error", "warning", "info", "loading"]

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
export default class extends Controller {
  static targets = ["skeleton", "toast", "actionTpl", "cancelTpl", "closeTpl"]
  static values = {
    position: { type: String, default: "bottom-right" },
    expand: { type: Boolean, default: false },
    max: { type: Number, default: 3 },
    duration: { type: Number, default: 4000 },
    gap: { type: Number, default: 14 },
    offset: { type: Number, default: 24 },
    theme: { type: String, default: "system" },
    richColors: { type: Boolean, default: false },
    closeButton: { type: Boolean, default: false },
    hotkey: { type: String, default: "alt+t" },
    dir: { type: String, default: "ltr" },
  }

  connect() {
    this._heights = new Map()
    this._resizeObservers = new WeakMap()
    this._expanded = this.expandValue
    this._listEl = this.element.querySelector("ol") || (this.element.tagName === "OL" ? this.element : null)
    this._registerGlobalApi()
    registerStreamAction()
    if (!this._listEl) return

    this._onPointerEnter = () => this._setExpanded(true)
    this._onPointerLeave = () => { if (!this.expandValue) this._setExpanded(false) }
    this._onWindowToast = (e) => this._spawn(e.detail || {})
    this._onWindowDismissAll = () => this._dismissById(null)
    this._onKey = this._onKey.bind(this)

    window.addEventListener("ruby-ui:toast", this._onWindowToast)
    window.addEventListener("ruby-ui:toast:dismiss-all", this._onWindowDismissAll)
    this._listEl.addEventListener("pointerenter", this._onPointerEnter)
    this._listEl.addEventListener("pointerleave", this._onPointerLeave)
    document.addEventListener("keydown", this._onKey)
  }

  disconnect() {
    window.removeEventListener("ruby-ui:toast", this._onWindowToast)
    window.removeEventListener("ruby-ui:toast:dismiss-all", this._onWindowDismissAll)
    this._listEl?.removeEventListener("pointerenter", this._onPointerEnter)
    this._listEl?.removeEventListener("pointerleave", this._onPointerLeave)
    document.removeEventListener("keydown", this._onKey)
  }

  toastTargetConnected(el) {
    if (typeof ResizeObserver !== "undefined") {
      const ro = new ResizeObserver(() => {
        this._heights.set(el, el.offsetHeight)
        this._reflow()
      })
      ro.observe(el)
      this._resizeObservers.set(el, ro)
    }
    this._heights.set(el, el.offsetHeight || 64)
    this._reflow()
  }

  toastTargetDisconnected(el) {
    this._resizeObservers.get(el)?.disconnect()
    this._resizeObservers.delete(el)
    this._heights.delete(el)
    this._reflow()
  }

  _spawn(detail) {
    const variant = VARIANTS.includes(detail.variant) ? detail.variant : "default"
    const tpl = this._skeletonFor(variant)
    if (!tpl) return null
    if (detail.position) {
      this.element.setAttribute("data-position", detail.position)
      this.positionValue = detail.position
    }
    const node = tpl.content.firstElementChild.cloneNode(true)

    node.id = detail.id || `toast-${this._uuid()}`
    if (detail.duration != null) {
      const dur = detail.duration === Infinity ? 0 : detail.duration
      node.setAttribute("data-ruby-ui--toast-duration-value", String(dur))
    }
    if (detail.dismissible === false) {
      node.setAttribute("data-ruby-ui--toast-dismissible-value", "false")
    }
    if (detail.className) node.className += ` ${detail.className}`

    const titleEl = node.querySelector('[data-slot="title"]')
    if (titleEl) titleEl.textContent = detail.title || detail.message || ""
    const descEl = node.querySelector('[data-slot="description"]')
    if (descEl) {
      if (detail.description) descEl.textContent = detail.description
      else descEl.remove()
    }

    if (detail.action && detail.action.label && this.hasActionTplTarget) {
      const btn = this._cloneSlot(this.actionTplTarget)
      btn.textContent = detail.action.label
      btn.addEventListener("click", (ev) => {
        try { detail.action.onClick?.(ev) } finally {
          node.dispatchEvent(new CustomEvent("ruby-ui:toast:force-dismiss", { bubbles: true }))
        }
      })
      node.appendChild(btn)
    }

    if (detail.cancel && detail.cancel.label && this.hasCancelTplTarget) {
      const btn = this._cloneSlot(this.cancelTplTarget)
      btn.textContent = detail.cancel.label
      node.appendChild(btn)
    }

    if (detail.closeButton && this.hasCloseTplTarget) {
      const x = this._cloneSlot(this.closeTplTarget)
      node.classList.add("pr-10")
      node.appendChild(x)
    }

    this._listEl.appendChild(node)
    return node.id
  }

  _dismissById(id) {
    if (!id) {
      this.toastTargets.forEach((el) =>
        el.dispatchEvent(new CustomEvent("ruby-ui:toast:force-dismiss", { bubbles: true }))
      )
      return
    }
    const el = this._listEl.querySelector(`#${CSS.escape(id)}`)
    if (el) el.dispatchEvent(new CustomEvent("ruby-ui:toast:force-dismiss", { bubbles: true }))
  }

  _skeletonFor(variant) {
    return this.skeletonTargets.find((t) => t.dataset.variant === variant)
  }

  _cloneSlot(tpl) {
    return tpl.content.firstElementChild.cloneNode(true)
  }

  _setExpanded(value) {
    if (this._expanded === value) return
    this._expanded = value
    document.dispatchEvent(new CustomEvent(value ? "ruby-ui:toast:pause" : "ruby-ui:toast:resume"))
    this._reflow()
  }

  _reflow() {
    if (!this._listEl) return
    const isBottom = this.positionValue.startsWith("bottom")
    const items = this.toastTargets
    const order = isBottom ? items.slice().reverse() : items.slice()
    const heights = order.map(el => this._heights.get(el) || el.offsetHeight || 64)
    const gap = this.gapValue
    const peekOffset = 16
    const peekScaleStep = 0.05
    const peekOpacityStep = 0.2

    const expandedHeight = heights.reduce((a, b) => a + b, 0) + gap * Math.max(0, heights.length - 1)
    const collapsedHeight = (heights[0] || 0) + Math.min(2, Math.max(0, heights.length - 1)) * peekOffset
    this._listEl.style.minHeight = `${this._expanded ? expandedHeight : collapsedHeight}px`

    let acc = 0
    order.forEach((el, i) => {
      const visible = i < this.maxValue
      let yOffset, scale, opacity

      if (this._expanded) {
        yOffset = acc + i * gap
        scale = 1
        opacity = visible ? 1 : 0
      } else {
        yOffset = i * peekOffset
        scale = Math.max(0.85, 1 - i * peekScaleStep)
        opacity = visible ? Math.max(0, 1 - i * peekOpacityStep) : 0
      }

      const sign = isBottom ? -1 : 1
      const ty = sign * yOffset

      el.style.setProperty("--opacity", String(opacity))
      el.style.setProperty("--scale", String(scale))
      el.style.setProperty("--y-offset", `${ty}px`)
      el.style.transformOrigin = isBottom ? "center bottom" : "center top"
      el.style.top = isBottom ? "auto" : "0"
      el.style.bottom = isBottom ? "0" : "auto"
      el.style.transform = `translate3d(0, ${ty}px, 0) scale(${scale})`
      el.style.zIndex = String(1000 - i)
      el.style.pointerEvents = visible ? "auto" : "none"
      el.tabIndex = visible ? 0 : -1

      acc += heights[i] || 0
    })

    this._enforceMax(items)
  }

  _enforceMax(items) {
    if (items.length <= this.maxValue) return
    const isBottom = this.positionValue.startsWith("bottom")
    const dropping = items.length - this.maxValue
    const candidates = isBottom ? items.slice(0, dropping) : items.slice(-dropping)
    candidates.forEach(el => {
      if (el.dataset.state !== "closing") {
        el.dispatchEvent(new CustomEvent("ruby-ui:toast:force-dismiss", { bubbles: true }))
      }
    })
  }

  _onKey(e) {
    const parts = (this.hotkeyValue || "alt+t").split("+")
    const key = parts.pop()
    const wantAlt = parts.includes("alt")
    const wantCtrl = parts.includes("ctrl")
    const wantMeta = parts.includes("meta")
    if (e.key.toLowerCase() !== key.toLowerCase()) return
    if (wantAlt !== e.altKey) return
    if (wantCtrl !== e.ctrlKey) return
    if (wantMeta !== e.metaKey) return
    e.preventDefault()
    const first = this._listEl.firstElementChild
    first?.focus()
  }

  _registerGlobalApi() {
    const fire = (variant, message, opts = {}) =>
      window.dispatchEvent(new CustomEvent("ruby-ui:toast", {
        detail: { ...opts, variant, message: opts.title || message }
      }))

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
    api.promise = (p, msgs = {}) => {
      const id = `toast-${this._uuid()}`
      fire("loading", typeof msgs.loading === "function" ? msgs.loading() : (msgs.loading || "Loading..."), { id, duration: 0 })
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
    const el = this._listEl.querySelector(`#${CSS.escape(id)}`)
    if (!el) return
    el.dataset.variant = variant
    el.setAttribute("role", variant === "error" ? "alert" : "status")
    this._swapIcon(el, variant)
    const t = el.querySelector('[data-slot="title"]')
    if (t && text) t.textContent = text
    const dur = String(this.durationValue)
    el.setAttribute("data-ruby-ui--toast-duration-value", dur)
    el.dispatchEvent(new CustomEvent("ruby-ui:toast:restart", { bubbles: true }))
  }

  _swapIcon(el, variant) {
    const iconHost = el.querySelector('[data-slot="icon"]')
    if (!iconHost) return
    const tpl = this._skeletonFor(variant)
    if (!tpl) return
    const sourceIcon = tpl.content.firstElementChild?.querySelector('[data-slot="icon"]')
    iconHost.innerHTML = sourceIcon ? sourceIcon.innerHTML : ""
  }

  _uuid() {
    if (typeof crypto !== "undefined" && crypto.randomUUID) return crypto.randomUUID()
    return Math.random().toString(36).slice(2) + Date.now().toString(36)
  }
}
