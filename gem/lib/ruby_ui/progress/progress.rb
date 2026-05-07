# frozen_string_literal: true

module RubyUI
  class Progress < Base
    def initialize(value: 0, **attrs)
      @value = value.to_f.clamp(0, 100)

      super(**attrs)
    end

    def view_template
      div(**attrs) do
        div(**indicator_attrs)
      end
    end

    private

    def default_attrs
      {
        role: "progressbar",
        aria_valuenow: @value,
        aria_valuemin: 0,
        aria_valuemax: 100,
        aria_valuetext: "#{@value}%",
        class: "relative h-2 overflow-hidden rounded-full bg-primary/20 [&>*]:bg-primary"
      }
    end

    def indicator_attrs
      {
        class: "h-full w-full flex-1",
        style: "transform: translateX(-#{100 - @value}%)"
      }
    end
  end
end
