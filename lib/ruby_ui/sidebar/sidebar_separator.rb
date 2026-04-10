# frozen_string_literal: true

module RubyUI
  class SidebarSeparator
    include ComponentBase

    private

    def default_attrs
      {class: "mx-2 w-auto bg-sidebar-border", data: {sidebar: "separator"}}
    end
  end
end
