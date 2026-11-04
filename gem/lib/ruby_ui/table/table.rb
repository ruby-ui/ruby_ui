# frozen_string_literal: true

module RubyUI
  # A native <table> inside a horizontally scrolling container, like shadcn's
  # Table: wide tables scroll instead of wrapping their cells. Attributes go
  # to the <table>; the wrapper is data-slot="table-container".
  class Table < Base
    def view_template(&block)
      div(data: {slot: "table-container"}, class: "relative w-full overflow-x-auto") do
        table(**attrs, &block)
      end
    end

    private

    def default_attrs
      {
        data: {slot: "table"},
        class: "w-full caption-bottom text-sm"
      }
    end
  end
end
