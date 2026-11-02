# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/context_menu (strings in content.yml).
  class ContextMenu < Phlex::HTML
    include RubyUI

    # collect only left-clicks the trigger: turn it into a contextmenu event at
    # the same point (the shadcn fixture does the same).
    OPEN_AS_CONTEXT_MENU = <<~JS
      document.querySelector("[data-audit-trigger]").addEventListener("click", (event) => {
        event.currentTarget.dispatchEvent(new MouseEvent("contextmenu", {
          bubbles: true, cancelable: true, button: 2, clientX: event.clientX, clientY: event.clientY
        }))
      })
    JS

    def view_template
      ContextMenu do
        ContextMenuTrigger(
          class: "flex h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm",
          data: {audit_trigger: true}
        ) { "Right click here" }
        ContextMenuContent(class: "w-64") do
          ContextMenuGroup do
            ContextMenuItem do
              plain "Back"
              ContextMenuShortcut { "⌘[" }
            end
            ContextMenuItem(disabled: true) do
              plain "Forward"
              ContextMenuShortcut { "⌘]" }
            end
            ContextMenuItem do
              plain "Reload"
              ContextMenuShortcut { "⌘R" }
            end
          end
          ContextMenuSeparator()
          ContextMenuGroup do
            ContextMenuLabel { "More Tools" }
            ContextMenuItem { "Developer Tools" }
            ContextMenuItem { "Task Manager" }
          end
        end
      end
      script { raw(safe(OPEN_AS_CONTEXT_MENU)) }
    end
  end
end
