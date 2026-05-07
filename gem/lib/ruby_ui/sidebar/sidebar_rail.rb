# frozen_string_literal: true

module RubyUI
  class SidebarRail < Base
    def view_template(&)
      button(**attrs, &)
    end

    private

    def default_attrs
      {
        class: [
          "absolute inset-y-0 z-20 hidden w-4 -translate-x-1/2 transition-all",
          "ease-linear after:absolute after:inset-y-0 after:left-1/2",
          "after:w-[2px] hover:after:bg-sidebar-border",
          "group-data-[side=left]:-right-4 group-data-[side=right]:left-0",
          "sm:flex [[data-side=left]_&]:cursor-w-resize",
          "[[data-side=right]_&]:cursor-e-resize",
          "[[data-side=left][data-state=collapsed]_&]:cursor-e-resize",
          "[[data-side=right][data-state=collapsed]_&]:cursor-w-resize",
          "group-data-[collapsible=offcanvas]:translate-x-0",
          "group-data-[collapsible=offcanvas]:after:left-full",
          "group-data-[collapsible=offcanvas]:hover:bg-sidebar",
          "[[data-side=left][data-collapsible=offcanvas]_&]:-right-2",
          "[[data-side=right][data-collapsible=offcanvas]_&]:-left-2"
        ],
        data: {
          sidebar: "rail",
          tabindex: "-1",
          action: "click->ruby-ui--sidebar#toggle"
        }
      }
    end
  end
end
