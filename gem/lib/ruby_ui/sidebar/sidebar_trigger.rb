# frozen_string_literal: true

module RubyUI
  class SidebarTrigger < Base
    def view_template(&)
      Button(variant: :ghost, size: :icon_sm, **trigger_attrs) do
        panel_left_icon
        span(class: "sr-only") { "Toggle Sidebar" }
      end
    end

    private

    # slot! makes Button replace its own data-slot="button" instead of joining
    # it. Added after Base's mix, which would strip the bang.
    def trigger_attrs
      attrs.merge(data: attrs.fetch(:data, {}).merge(slot!: "sidebar-trigger"))
    end

    def default_attrs
      {
        data: {
          sidebar: "trigger",
          action: "click->ruby-ui--sidebar#toggle"
        }
      }
    end

    def panel_left_icon
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        width: "24",
        height: "24",
        viewBox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round",
        aria_hidden: "true",
        class: "lucide lucide-panel-left"
      ) do |s|
        s.rect(width: "18", height: "18", x: "3", y: "3", rx: "2")
        s.path(d: "M9 3v18")
      end
    end
  end
end
