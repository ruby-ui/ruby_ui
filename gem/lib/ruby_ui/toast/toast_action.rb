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
        class: "inline-flex h-8 shrink-0 cursor-pointer items-center justify-center rounded-md border border-input bg-transparent px-3 text-sm font-medium ring-offset-background transition-colors hover:bg-secondary hover:text-secondary-foreground focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:pointer-events-none disabled:opacity-50"
      }
    end
  end
end
