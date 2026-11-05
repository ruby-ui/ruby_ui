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
        width: "24",
        height: "24",
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round",
        aria_hidden: "true"
      ) do |s|
        s.path(d: "M5 12h14")
      end
    end

    private

    def default_attrs
      {
        role: "separator",
        data: {slot: "input-otp-separator"},
        class: "flex items-center [&_svg:not([class*='size-'])]:size-4"
      }
    end
  end
end
