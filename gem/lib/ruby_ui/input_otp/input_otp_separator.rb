# frozen_string_literal: true

module RubyUI
  class InputOtpSeparator < Base
    def view_template(&block)
      div(**attrs) do
        if block
          block.call
        else
          icon
        end
      end
    end

    def icon
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round",
        class: "h-4 w-4"
      ) do |s|
        s.path(d: "M5 12h14")
      end
    end

    private

    def default_attrs
      {
        role: "separator",
        class: "text-muted-foreground"
      }
    end
  end
end
