# frozen_string_literal: true

module RubyUI
  class SidebarWrapper < Base
    def view_template(&)
      div(**attrs, &)
    end
    private

    def default_attrs
      {
        class: "group/sidebar-wrapper has-data-[variant=inset]:bg-sidebar flex min-h-svh w-full",
        data: {
          controller: "ruby-ui--sidebar"
        }
      }
    end
  end
end
