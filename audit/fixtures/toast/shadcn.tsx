// timeout: 0 (shadcn) / duration: Infinity (RubyUI) keeps the toast up while collect observes it.
// window.__auditToast exposes the toast manager to the browser-driven checks,
// as RubyUI's window.RubyUI.toast (fixture shim).
import { useEffect } from "react"

import { Button } from "@/components/ui/button"
import { toast, Toaster } from "@/components/ui/toast"

export default function ToastFixture() {
  useEffect(() => {
    ;(window as unknown as { __auditToast: typeof toast }).__auditToast = toast
  }, [])

  return (
    <Toaster>
      <Button
        variant="outline"
        data-audit-trigger=""
        onClick={() =>
          toast.add({
            title: "Event created",
            description: "Sunday, December 3 at 9:00 AM",
            timeout: 0,
          })
        }
      >
        Show Toast
      </Button>
    </Toaster>
  )
}
