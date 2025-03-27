# frozen_string_literal: true

module RubyUI
  class SidebarMenuAction < Base
    def initialize(as: :button, show_on_hover: false, **attrs)
      @as = as
      super(**attrs)
    end

    def view_template(&)
      tag(@as, **attrs, &)
    end

    private

    def default_attrs
      {
        class: [
          "absolute right-1 top-1.5 flex aspect-square w-5 items-center",
          "justify-center rounded-md p-0 text-sidebar-foreground outline-none",
          "ring-sidebar-ring transition-transform hover:bg-sidebar-accent",
          "hover:text-sidebar-accent-foreground focus-visible:ring-2",
          "peer-hover/menu-button:text-sidebar-accent-foreground",
          "[&>svg]:size-4 [&>svg]:shrink-0",
          "after:absolute after:-inset-2 after:md:hidden",
          "peer-data-[size=sm]/menu-button:top-1",
          "peer-data-[size=default]/menu-button:top-1.5",
          "peer-data-[size=lg]/menu-button:top-2.5",
          "group-data-[collapsible=icon]:hidden",
          show_on_hover_classes
        ],
        data: {
          sidebar: "menu-action"
        }
      }
    end

    def show_on_hover_classes
      return unless @show_on_hover

      [
        "group-focus-within/menu-item:opacity-100",
        "group-hover/menu-item:opacity-100 data-[state=open]:opacity-100",
        "peer-data-[active=true]/menu-button:text-sidebar-accent-foreground md:opacity-0"
      ].join(" ")
    end
  end
end
