# frozen_string_literal: true

module RubyUI
  class SidebarContent
    include ComponentBase

    private

    def default_attrs
      {
        class: "flex min-h-0 flex-1 flex-col gap-2 overflow-auto group-data-[collapsible=icon]:overflow-hidden",
        data: {sidebar: "content"}
      }
    end
  end
end
