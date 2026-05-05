# frozen_string_literal: true

module RubyUI
  class ComboboxItemIndicator < Base
    def view_template
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        width: "24",
        height: "24",
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round",
        **attrs
      ) do |s|
        s.path(d: "M20 6 9 17l-5-5")
      end
    end

    private

    def default_attrs
      {
        class: "ml-auto size-4 shrink-0 opacity-0 peer-checked:opacity-100"
      }
    end
  end
end
