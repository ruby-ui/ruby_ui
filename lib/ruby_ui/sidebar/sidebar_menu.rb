# frozen_string_literal: true

module RubyUI
  class SidebarMenu
    include ComponentBase

    private

    def default_attrs
      {class: "flex w-full min-w-0 flex-col gap-1", data: {sidebar: "menu"}}
    end
  end
end
