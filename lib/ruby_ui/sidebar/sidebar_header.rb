# frozen_string_literal: true

module RubyUI
  class SidebarHeader
    include ComponentBase

    private

    def default_attrs
      {class: "flex flex-col gap-2 p-2", data: {sidebar: "header"}}
    end
  end
end
