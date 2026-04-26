# frozen_string_literal: true

module RubyUI
  class NativeSelectIcon < Base
    def view_template(&block)
      span(**attrs) do
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
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round",
        class: "size-4",
        aria_hidden: "true"
      ) do |s|
        s.path(d: "m6 9 6 6 6-6")
      end
    end

    def default_attrs
      {
        class: "text-muted-foreground pointer-events-none absolute top-1/2 right-2.5 -translate-y-1/2 select-none"
      }
    end
  end
end
