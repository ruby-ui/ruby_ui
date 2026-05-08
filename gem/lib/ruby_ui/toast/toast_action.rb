# frozen_string_literal: true

module RubyUI
  class ToastAction < Base
    def initialize(label:, on: nil, **attrs)
      @label = label
      @on = on
      super(**attrs)
    end

    def view_template
      button(**attrs) { @label }
    end

    private

    def default_attrs
      data = {slot: "action"}
      data[:action] = @on if @on
      {
        type: "button",
        data: data,
        class: "inline-flex h-6 shrink-0 cursor-pointer items-center justify-center rounded px-2 text-xs font-medium bg-foreground text-background border-0 ml-auto hover:opacity-90 focus:outline-none focus:ring-2 focus:ring-ring transition-opacity disabled:pointer-events-none disabled:opacity-50"
      }
    end
  end
end
