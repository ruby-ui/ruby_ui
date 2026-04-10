# frozen_string_literal: true

module RubyUI
  class SidebarMenuSkeleton < Base
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

    def view_template(&)
      div(**attrs) do
        if show_icon?

          div(class: "size-4 rounded-md animate-pulse bg-muted", data_sidebar: "menu-skeleton-icon")

        end

        div(class: "h-4 max-w-[var(--skeleton-width)] flex-1 animate-pulse bg-muted", data_sidebar: "menu-skeleton-text", style: "--skeleton-width: #{skeleton_width}%;")
      end
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
