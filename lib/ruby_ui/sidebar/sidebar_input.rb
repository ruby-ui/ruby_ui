# frozen_string_literal: true

module RubyUI
  class SidebarInput
    include ComponentBase

    private

    def default_attrs
      {
        class: "h-8 w-full bg-background shadow-none focus-visible:ring-2 focus-visible:ring-sidebar-ring",
        data: {sidebar: "input"}
      }
    end
  end
end
