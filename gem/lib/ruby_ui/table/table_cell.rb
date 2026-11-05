# frozen_string_literal: true

module RubyUI
  class TableCell < Base
    include TableSlot

    def view_template(&)
      td(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: default_slot("table-cell")}.compact,
        class: "p-2 align-middle whitespace-nowrap [&:has([role=checkbox])]:pr-0 [&:has([data-slot=checkbox])]:pr-0"
      }
    end
  end
end
