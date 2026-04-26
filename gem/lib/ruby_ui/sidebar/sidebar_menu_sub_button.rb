# frozen_string_literal: true

module RubyUI
  class SidebarMenuSubButton < Base
    SIZE_CLASSES = {
      sm: "text-xs",
      md: "text-sm"
    }.freeze

    def initialize(as: :button, size: :md, active: false, **attrs)
      raise ArgumentError, "Invalid size: #{size}" unless SIZE_CLASSES.key?(size)

      @as = as
      @size = size
      @active = active
      super(**attrs)
    end

    def view_template(&)
      tag(@as, **attrs, &)
    end

    private

    def default_attrs
      {
        class: [
          "flex h-7 min-w-0 -translate-x-px items-center gap-2 overflow-hidden",
          "rounded-md px-2 text-sidebar-foreground outline-none",
          "ring-sidebar-ring hover:bg-sidebar-accent",
          "hover:text-sidebar-accent-foreground focus-visible:ring-2",
          "active:bg-sidebar-accent active:text-sidebar-accent-foreground",
          "disabled:pointer-events-none disabled:opacity-50",
          "aria-disabled:pointer-events-none aria-disabled:opacity-50",
          "[&>span:last-child]:truncate [&>svg]:size-4 [&>svg]:shrink-0",
          "[&>svg]:text-sidebar-accent-foreground",
          "data-[active=true]:bg-sidebar-accent",
          "data-[active=true]:text-sidebar-accent-foreground",
          "group-data-[collapsible=icon]:hidden",
          SIZE_CLASSES[@size]
        ],
        data: {
          sidebar: "menu-sub-button",
          size: @size,
          active: @active.to_s
        }
      }
    end
  end
end
