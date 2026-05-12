import { Controller } from "@hotwired/stimulus"

const PRESETS = {
  default: { variant: "default", title: "Event has been created", description: "Sunday, December 03, 2023 at 9:00 AM" },
  success: { variant: "success", title: "Event has been created" },
  info: { variant: "info", title: "Be at the area 10 minutes before the event time" },
  warning: { variant: "warning", title: "Event start time cannot be earlier than 8am" },
  error: { variant: "error", title: "Event has not been created" },
  with_action: { variant: "default", title: "Event has been created", action: { label: "Undo" } },
  text_only: { variant: "default", title: "Event has been created" },
  close_button: { variant: "default", title: "Event has been created", description: "Close it manually with the X.", closeButton: true },
  close_action: { variant: "default", title: "Event has been created", description: "Friday at 3:00 PM", closeButton: true, action: { label: "Undo" } },
}

export default class extends Controller {
  fire(e) {
    const kind = e.params.kind || "default"
    const t = window.RubyUI?.toast
    if (!t) return

    if (kind === "promise") {
      t.promise(
        new Promise((r) => setTimeout(() => r({ name: "Sonner" }), 1500)),
        {
          loading: "Loading...",
          success: (data) => `${data.name} toast has been added`,
          error: "Error",
        }
      )
      return
    }

    const preset = PRESETS[kind] || PRESETS.default
    const opts = {
      description: preset.description,
      action: preset.action,
      closeButton: preset.closeButton,
    }
    const fn = t[preset.variant] || t
    fn(preset.title, opts)
  }

  position(e) {
    const position = e.params.position || "bottom-right"
    window.dispatchEvent(new CustomEvent("ruby-ui:toast", {
      detail: {
        variant: "default",
        title: `Position: ${position}`,
        description: "Toast spawned in this corner",
        position,
      }
    }))
  }

  dismissAll() {
    window.RubyUI?.toast.dismiss()
  }
}
