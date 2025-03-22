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
        class: "h-7 w-7",
        data: {
          sidebar: "trigger"
        }
      }
    end

    def panel_left_icon
      svg(
        xmlns: "http://www.w3.org/2000/svg", 
        width: 24, 
        height: 24, 
        viewBox: "0 0 24 24", 
        fill: "none", 
        stroke: "currentColor", 
        strokeWidth: 2, 
        strokeLinecap: "round", 
        strokeLinejoin: "round", 
        class: "lucide lucide-panel-left"
      ) do |s|
        s.rect(width: 18, height: 18, x: 3, y: 3, rx: 2)
        s.path(d: "M9 3v18")
      end
    end
  end
end
