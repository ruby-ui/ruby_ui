# frozen_string_literal: true

module RubyUI
  class SidebarFooter
    include ComponentBase

    private

    def default_attrs
      {class: "flex flex-col gap-2 p-2", data: {sidebar: "footer"}}
    end
  end
end
