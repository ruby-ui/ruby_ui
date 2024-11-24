# frozen_string_literal: true

module RubyUI
  class BreadcrumbSeparator < Base
    def view_template(&block)
      li(**attrs) do
        if block
          block.call
        else
          icon
        end
      end
    end

    private

    def icon
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        class: "w-4 h-4",
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round"
      ) { |s| s.path(d: "m9 18 6-6-6-6") }
    end

    def default_attrs
      {
        aria: {hidden: true},
        class: "[&>svg]:w-3.5 [&>svg]:h-3.5",
        role: "presentation"
      }
    end
  end
end
