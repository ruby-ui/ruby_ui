# frozen_string_literal: true

module RubyUI
  class SidebarGroupAction < Base
    def initialize(as: :button, **attrs)
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
          "absolute right-3 top-3.5 flex aspect-square w-5 items-center",
          "justify-center rounded-md p-0 text-sidebar-foreground",
          "outline-none ring-sidebar-ring transition-transform",
          "hover:bg-sidebar-accent hover:text-sidebar-accent-foreground",
          "focus-visible:ring-2 [&>svg]:size-4 [&>svg]:shrink-0",
          "after:absolute after:-inset-2 after:md:hidden",
          "group-data-[collapsible=icon]:hidden"
        ],
        data: {
          sidebar: "group-action"
        }
      }
    end
  end
end
