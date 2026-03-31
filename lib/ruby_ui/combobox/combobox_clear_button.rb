# frozen_string_literal: true

module RubyUI
  class ComboboxClearButton < Base
    def view_template
      button(**attrs) do
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
          class: "size-4"
        ) do |s|
          s.path(d: "M18 6 6 18")
          s.path(d: "m6 6 12 12")
        end
      end
    end

    private

    def default_attrs
      {
        type: "button",
        class: "ml-auto shrink-0 rounded-sm opacity-50 hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring hidden",
        data: {
          ruby_ui__combobox_target: "clearButton",
          action: "ruby-ui--combobox#clearAll"
        }
      }
    end
  end
end
