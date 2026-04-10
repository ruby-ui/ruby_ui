# frozen_string_literal: true

module RubyUI
  class SidebarMenuSkeleton
    include ComponentBase

    def initialize(show_icon: false, **attrs)
      @show_icon = show_icon
      super(**attrs)
    end

    def show_icon?
      @show_icon
    end

    def skeleton_width
      @_skeleton_width ||= rand(50..89)
    end

    private

    def default_attrs
      {
        class: "flex h-8 items-center gap-2 rounded-md px-2",
        data: {sidebar: "menu-skeleton"}
      }
    end
  end
end
