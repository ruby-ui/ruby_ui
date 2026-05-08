import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  fire(e) {
    const variant = e.params.variant || "default"
    const t = window.RubyUI?.toast
    if (!t) return
    const titles = { success: "Saved", error: "Boom", info: "Heads up", warning: "Storage almost full", default: "Hello" }
    const descs = { success: "Project updated.", error: "Server returned 500.", info: "New version available.", warning: "Almost out of space.", default: "Just so you know." }
    t[variant]?.(titles[variant], { description: descs[variant] })
  }

  promise() {
    const p = new Promise((r) => setTimeout(() => r({ id: 42 }), 1500))
    window.RubyUI?.toast.promise(p, {
      loading: "Saving...",
      success: (v) => `Saved (id ${v.id})`,
      error: "Failed",
    })
  }

  dismissAll() {
    window.RubyUI?.toast.dismiss()
  }
}
