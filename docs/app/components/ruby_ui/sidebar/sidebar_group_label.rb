# frozen_string_literal: true

module RubyUI
  class SidebarGroupLabel < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: [
          "flex h-8 shrink-0 items-center rounded-md px-2 text-xs",
          "font-medium text-sidebar-foreground/70 outline-none",
          "ring-sidebar-ring transition-[margin,opacity] duration-200",
          "ease-linear focus-visible:ring-2 [&>svg]:size-4 [&>svg]:shrink-0",
          "group-data-[collapsible=icon]:-mt-8 group-data-[collapsible=icon]:opacity-0"
        ],
        data: {
          sidebar: "group-label"
        }
      }
    end
  end
end
