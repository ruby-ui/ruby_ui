# frozen_string_literal: true

module RubyUI
  class SidebarTrigger < Base
    def view_template(&)
      Button(variant: :ghost, size: :icon, **attrs) do
        panel_left_icon
        span(class: "sr-only") { "Toggle Sidebar" }
      end
    end

    private

    def default_attrs
      {
        class: "h-7 w-7 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0",
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
        class: "lucide lucide-panel-left"
      ) do |s|
        s.rect(width: "18", height: "18", x: "3", y: "3", rx: "2")
        s.path(d: "M9 3v18")
      end
    end
  end
end
