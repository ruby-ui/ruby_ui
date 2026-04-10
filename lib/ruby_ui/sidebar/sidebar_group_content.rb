# frozen_string_literal: true

module RubyUI
  class SidebarGroupContent
    include ComponentBase

    private

    def default_attrs
      {class: "w-full text-sm", data: {sidebar: "group-content"}}
    end
  end
end
