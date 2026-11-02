import {
  ContextMenu,
  ContextMenuContent,
  ContextMenuGroup,
  ContextMenuItem,
  ContextMenuLabel,
  ContextMenuSeparator,
  ContextMenuShortcut,
  ContextMenuTrigger,
} from "@/components/ui/context-menu"

// collect only left-clicks the trigger: turn it into a contextmenu event at the
// same point (the RubyUI fixture does the same).
function openAsContextMenu(event: React.MouseEvent<HTMLElement>) {
  event.currentTarget.dispatchEvent(
    new MouseEvent("contextmenu", {
      bubbles: true,
      cancelable: true,
      button: 2,
      clientX: event.clientX,
      clientY: event.clientY,
    })
  )
}

export default function ContextMenuFixture() {
  return (
    <ContextMenu>
      <ContextMenuTrigger
        className="flex h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm"
        data-audit-trigger=""
        onClick={openAsContextMenu}
      >
        Right click here
      </ContextMenuTrigger>
      <ContextMenuContent className="w-64">
        <ContextMenuGroup>
          <ContextMenuItem>
            Back
            <ContextMenuShortcut>⌘[</ContextMenuShortcut>
          </ContextMenuItem>
          <ContextMenuItem disabled>
            Forward
            <ContextMenuShortcut>⌘]</ContextMenuShortcut>
          </ContextMenuItem>
          <ContextMenuItem>
            Reload
            <ContextMenuShortcut>⌘R</ContextMenuShortcut>
          </ContextMenuItem>
        </ContextMenuGroup>
        <ContextMenuSeparator />
        <ContextMenuGroup>
          <ContextMenuLabel>More Tools</ContextMenuLabel>
          <ContextMenuItem>Developer Tools</ContextMenuItem>
          <ContextMenuItem>Task Manager</ContextMenuItem>
        </ContextMenuGroup>
      </ContextMenuContent>
    </ContextMenu>
  )
}
