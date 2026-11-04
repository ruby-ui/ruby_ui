# frozen_string_literal: true

module RubyUI
  class SidebarWrapper < Base
    SIDEBAR_WIDTH = "16rem"
    SIDEBAR_WIDTH_ICON = "3rem"

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "group/sidebar-wrapper flex min-h-svh w-full has-data-[variant=inset]:bg-sidebar",
        style: "--sidebar-width: #{SIDEBAR_WIDTH}; --sidebar-width-icon: #{SIDEBAR_WIDTH_ICON};",
        data: {
          slot: "sidebar-wrapper",
          controller: "ruby-ui--sidebar",
          # Ctrl+B / Cmd+B toggles the sidebar, like shadcn's SidebarProvider.
          action: "keydown.ctrl+b@window->ruby-ui--sidebar#toggle keydown.meta+b@window->ruby-ui--sidebar#toggle"
        }
      }
    end
  end
end
