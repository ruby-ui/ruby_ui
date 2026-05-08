import { Controller } from "@hotwired/stimulus"

const VARIANTS = ["default", "success", "error", "warning", "info", "loading"]

// Connects to data-controller="ruby-ui--toaster"
export default class extends Controller {
  static targets = ["skeleton"]
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
    this._items = []
    this._heights = new Map()
    this._expanded = this.expandValue
    this._listEl = this.element.querySelector("ol") || (this.element.tagName === "OL" ? this.element : null)
    this._registerGlobalApi()
    if (!this._listEl) return

    this._observer = new MutationObserver((records) => {
      for (const r of records) {
        for (const n of r.addedNodes) {
          if (n.nodeType === 1 && n.matches?.('[data-controller~="ruby-ui--toast"]')) this._track(n)
        }
        for (const n of r.removedNodes) {
          if (n.nodeType === 1) this._untrack(n)
        }
      }
      this._reflow()
    })
    this._observer.observe(this._listEl, { childList: true })

    this._onCustomEvent = this._onCustomEvent.bind(this)
    this._onPointerEnter = () => this._setExpanded(true)
    this._onPointerLeave = () => { if (!this.expandValue) this._setExpanded(false) }
    this._onKey = this._onKey.bind(this)

    window.addEventListener("ruby-ui:toast", this._onCustomEvent)
    window.addEventListener("ruby-ui:toast:dismiss-all", this._onCustomEvent)
    this._listEl.addEventListener("pointerenter", this._onPointerEnter)
    this._listEl.addEventListener("pointerleave", this._onPointerLeave)
    document.addEventListener("keydown", this._onKey)

    Array.from(this._listEl.children).filter(c => c.matches?.('[data-controller~="ruby-ui--toast"]')).forEach((c) => this._track(c))
    this._reflow()
  }

  disconnect() {
    this._observer?.disconnect()
    window.removeEventListener("ruby-ui:toast", this._onCustomEvent)
    window.removeEventListener("ruby-ui:toast:dismiss-all", this._onCustomEvent)
    this._listEl?.removeEventListener("pointerenter", this._onPointerEnter)
    this._listEl?.removeEventListener("pointerleave", this._onPointerLeave)
    document.removeEventListener("keydown", this._onKey)
  }

  _onCustomEvent(e) {
    if (e.type === "ruby-ui:toast") this._spawn(e.detail || {})
    if (e.type === "ruby-ui:toast:dismiss-all") this._dismissById(null)
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

    if (detail.action && detail.action.label) {
      const btn = document.createElement("button")
      btn.type = "button"
      btn.dataset.slot = "action"
      btn.className = "inline-flex h-6 shrink-0 cursor-pointer items-center justify-center rounded px-2 text-xs font-medium bg-foreground text-background border-0 ml-auto hover:opacity-90 focus:outline-none focus:ring-2 focus:ring-ring transition-opacity"
      btn.textContent = detail.action.label
      btn.addEventListener("click", (ev) => {
        try { detail.action.onClick?.(ev) } finally {
          node.dispatchEvent(new CustomEvent("ruby-ui:toast:force-dismiss", { bubbles: true }))
        }
      })
      node.appendChild(btn)
    }

    if (detail.cancel && detail.cancel.label) {
      const btn = document.createElement("button")
      btn.type = "button"
      btn.dataset.slot = "cancel"
      btn.dataset.action = "click->ruby-ui--toast#dismiss"
      btn.className = "inline-flex h-6 shrink-0 cursor-pointer items-center justify-center rounded px-2 text-xs font-medium bg-foreground/10 text-foreground border-0 ml-auto hover:bg-foreground/15 focus:outline-none focus:ring-2 focus:ring-ring transition-colors"
      btn.textContent = detail.cancel.label
      node.appendChild(btn)
    }

    this._listEl.appendChild(node)
    return node.id
  }

  _dismissById(id) {
    if (!id) {
      this._items.slice().forEach((el) =>
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

  _track(el) {
    if (this._items.includes(el)) return
    this._items.push(el)
    if (typeof ResizeObserver !== "undefined") {
      const ro = new ResizeObserver(() => { this._heights.set(el, el.offsetHeight); this._reflow() })
      ro.observe(el)
      el._rubyUiResizeObserver = ro
    }
    this._heights.set(el, el.offsetHeight || 64)
  }

  _untrack(el) {
    this._items = this._items.filter((i) => i !== el)
    el._rubyUiResizeObserver?.disconnect()
    this._heights.delete(el)
    this._reflow()
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
    const items = Array.from(this._listEl.children).filter(c => c.matches?.('[data-controller~="ruby-ui--toast"]'))
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

      acc += heights[i] || 0
    })

    this._enforceMax(items)
  }

  _enforceMax(items) {
    if (items.length <= this.maxValue) return
    // Items in DOM order: oldest first, newest last (bottom positions reverse for stack).
    // Drop excess oldest by triggering force-dismiss; let exit anim run.
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
      this._spawn({ ...opts, variant, message: opts.title || message })

    const api = (message, opts) => fire("default", message, opts)
    api.success = (m, o) => fire("success", m, o)
    api.error = (m, o) => fire("error", m, o)
    api.warning = (m, o) => fire("warning", m, o)
    api.info = (m, o) => fire("info", m, o)
    api.loading = (m, o = {}) => fire("loading", m, { ...o, duration: o.duration ?? 0 })
    api.dismiss = (id) => this._dismissById(id ?? null)
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
