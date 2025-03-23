# frozen_string_literal: true

module RubyUI
  class SidebarMenuBadge < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: [
          "pointer-events-none absolute right-1 flex h-5 min-w-5 select-none",
          "items-center justify-center rounded-md px-1 text-xs font-medium",
          "tabular-nums text-sidebar-foreground",
          "peer-hover/menu-button:text-sidebar-accent-foreground",
          "peer-data-[active=true]/menu-button:text-sidebar-accent-foreground",
          "peer-data-[size=sm]/menu-button:top-1",
          "peer-data-[size=default]/menu-button:top-1.5",
          "peer-data-[size=lg]/menu-button:top-2.5",
          "group-data-[collapsible=icon]:hidden"
        ],
        data: {
          sidebar: "menu-badge"
        }
      }
    end
  end
end
