# frozen_string_literal: true

module RubyUI
  class SidebarMenuButton < Base
    VARIANT_CLASSES = {
      default: "hover:bg-sidebar-accent hover:text-sidebar-accent-foreground",
      outline:
        "bg-background shadow-[0_0_0_1px_hsl(var(--sidebar-border))] hover:bg-sidebar-accent hover:text-sidebar-accent-foreground hover:shadow-[0_0_0_1px_hsl(var(--sidebar-accent))]"
    }.freeze

    SIZE_CLASSES = {
      default: "h-8 text-sm",
      sm: "h-7 text-xs",
      lg: "h-12 text-sm group-data-[collapsible=icon]:!p-0"
    }.freeze

    def initialize(as: :button, variant: :default, size: :default, active: false, **attrs)
      raise ArgumentError, "Invalid variant: #{variant}" unless VARIANT_CLASSES.key?(variant)
      raise ArgumentError, "Invalid size: #{size}" unless SIZE_CLASSES.key?(size)

      @as = as
      @variant = variant
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
          "peer/menu-button flex w-full items-center gap-2 overflow-hidden",
          "rounded-md p-2 text-left text-sm outline-none ring-sidebar-ring",
          "transition-[width,height,padding] hover:bg-sidebar-accent",
          "hover:text-sidebar-accent-foreground focus-visible:ring-2",
          "active:bg-sidebar-accent active:text-sidebar-accent-foreground",
          "disabled:pointer-events-none disabled:opacity-50",
          "group-has-[[data-sidebar=menu-action]]/menu-item:pr-8",
          "aria-disabled:pointer-events-none aria-disabled:opacity-50",
          "data-[active=true]:bg-sidebar-accent data-[active=true]:font-medium",
          "data-[active=true]:text-sidebar-accent-foreground",
          "data-[state=open]:hover:bg-sidebar-accent",
          "data-[state=open]:hover:text-sidebar-accent-foreground",
          "group-data-[collapsible=icon]:!size-8",
          "group-data-[collapsible=icon]:!p-2 [&>span:last-child]:truncate",
          "[&>svg]:size-4 [&>svg]:shrink-0",
          VARIANT_CLASSES[@variant],
          SIZE_CLASSES[@size]
        ],
        data: {
          sidebar: "menu-button",
          size: @size,
          active: @active.to_s
        }
      }
    end
  end
end
