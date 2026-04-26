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
        class: "group/sidebar-wrapper [&:has([data-variant=inset])]:bg-sidebar flex min-h-svh w-full",
        style: "--sidebar-width: #{SIDEBAR_WIDTH}; --sidebar-width-icon: #{SIDEBAR_WIDTH_ICON};",
        data: {
          controller: "ruby-ui--sidebar"
        }
      }
    end
  end
end
