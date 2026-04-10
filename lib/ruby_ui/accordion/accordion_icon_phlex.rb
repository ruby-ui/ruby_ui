# frozen_string_literal: true

module RubyUI
  class AccordionIcon < Base
    def view_template(&)
      span(**attrs) do
        if block_given?

          yield

          svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 20 20", fill: "currentColor", class: "w-4 h-4") do |s|
            s.path(fill_rule: "evenodd", d: "M5.23 7.21a.75.75 0 011.06.02L10 11.168l3.71-3.938a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z", clip_rule: "evenodd")
          end

        end
      end
    end

    private

    def default_attrs
      {
        class: "opacity-50",
        data: {ruby_ui__accordion_target: "icon"}
      }
    end
  end
end
