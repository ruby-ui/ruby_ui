# frozen_string_literal: true

module RubyUI
  class SidebarRail < Base
    def view_template(&)
      button(**attrs, &)
    end

    private

    def default_attrs
      {
        aria_label: "Toggle Sidebar",
        title: "Toggle Sidebar",
        tabindex: "-1",
        class: [
          "absolute inset-y-0 z-20 hidden w-4 transition-all ease-linear",
          "group-data-[side=left]:-right-4 group-data-[side=right]:left-0",
          "after:absolute after:inset-y-0 after:start-1/2 after:w-[2px]",
          "hover:after:bg-sidebar-border sm:flex ltr:-translate-x-1/2 rtl:-translate-x-1/2",
          "in-data-[side=left]:cursor-w-resize in-data-[side=right]:cursor-e-resize",
          "[[data-side=left][data-state=collapsed]_&]:cursor-e-resize",
          "[[data-side=right][data-state=collapsed]_&]:cursor-w-resize",
          "group-data-[collapsible=offcanvas]:translate-x-0",
          "group-data-[collapsible=offcanvas]:after:left-full",
          "hover:group-data-[collapsible=offcanvas]:bg-sidebar",
          "[[data-side=left][data-collapsible=offcanvas]_&]:-right-2",
          "[[data-side=right][data-collapsible=offcanvas]_&]:-left-2"
        ],
        data: {
          slot: "sidebar-rail",
          sidebar: "rail",
          action: "click->ruby-ui--sidebar#toggle"
        }
      }
    end
  end
end
