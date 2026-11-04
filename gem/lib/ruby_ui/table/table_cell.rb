# frozen_string_literal: true

module RubyUI
  class TableCell < Base
    def view_template(&)
      td(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "table-cell"},
        class: "p-2 align-middle whitespace-nowrap [&:has([role=checkbox])]:pr-0"
      }
    end
  end
end
