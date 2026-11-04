# frozen_string_literal: true

module RubyUI
  class SidebarMenuButton < Base
    VARIANT_CLASSES = {
      default: "hover:bg-sidebar-accent hover:text-sidebar-accent-foreground",
      outline: [
        "bg-background shadow-[0_0_0_1px_var(--sidebar-border)]",
        "hover:bg-sidebar-accent hover:text-sidebar-accent-foreground hover:shadow-[0_0_0_1px_var(--sidebar-accent)]"
      ].join(" ")
    }.freeze

    SIZE_CLASSES = {
      default: "h-8 text-sm",
      sm: "h-7 text-xs",
      lg: "h-12 text-sm group-data-[collapsible=icon]:!p-0"
    }.freeze

    # The tooltip controller places the content right after this button, inside
    # its own sidebar, so it hides from that sidebar's state alone: shown only
    # while the desktop sidebar around it is collapsed (shadcn:
    # hidden={state !== "collapsed" || isMobile}). A second, expanded sidebar
    # on the page no longer hides it.
    TOOLTIP_CLASSES = "[[data-slot=sidebar]:not([data-state=collapsed])_&]:hidden max-md:hidden"

    # tooltip: label shown on the right when the sidebar is collapsed to icons.
    def initialize(as: :button, variant: :default, size: :default, active: false, tooltip: nil, **attrs)
      raise ArgumentError, "Invalid variant: #{variant}" unless VARIANT_CLASSES.key?(variant)
      raise ArgumentError, "Invalid size: #{size}" unless SIZE_CLASSES.key?(size)

      @as = as
      @variant = variant
      @size = size
      @active = active
      @tooltip = tooltip
      super(**attrs)
    end

    def view_template(&block)
      return tag(@as, **attrs, &block) unless @tooltip

      tag(@as, **mix(attrs, tooltip_attrs)) do
        # First child, so [&>span:last-child]:truncate still finds the label.
        TooltipContent(side: :right, class: TOOLTIP_CLASSES) { @tooltip }
        yield if block
      end
    end

    private

    def tooltip_attrs
      {
        data: {
          controller: "ruby-ui--tooltip",
          ruby_ui__tooltip_target: "trigger"
        }
      }
    end

    def default_attrs
      {
        class: [
          "peer/menu-button group/menu-button flex w-full items-center gap-2 overflow-hidden",
          "rounded-md p-2 text-left text-sm outline-none ring-sidebar-ring",
          "transition-[width,height,padding] focus-visible:ring-2",
          "active:bg-sidebar-accent active:text-sidebar-accent-foreground",
          "disabled:pointer-events-none disabled:opacity-50",
          "group-has-[[data-sidebar=menu-action]]/menu-item:pr-8",
          "aria-disabled:pointer-events-none aria-disabled:opacity-50",
          "data-[active=true]:bg-sidebar-accent data-[active=true]:font-medium",
          "data-[active=true]:text-sidebar-accent-foreground",
          "data-open:hover:bg-sidebar-accent data-open:hover:text-sidebar-accent-foreground",
          "aria-expanded:hover:bg-sidebar-accent aria-expanded:hover:text-sidebar-accent-foreground",
          "group-data-[collapsible=icon]:!size-8",
          "group-data-[collapsible=icon]:!p-2 [&>span:last-child]:truncate",
          "[&_svg]:size-4 [&_svg]:shrink-0",
          VARIANT_CLASSES[@variant],
          SIZE_CLASSES[@size]
        ],
        data: {
          slot: "sidebar-menu-button",
          sidebar: "menu-button",
          size: @size,
          active: @active.to_s
        }
      }
    end
  end
end
