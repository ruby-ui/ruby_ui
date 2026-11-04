# frozen_string_literal: true

module RubyUI
  class TableBody < Base
    include TableSlot

    def view_template(&)
      tbody(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: default_slot("table-body")}.compact,
        class: "[&_tr:last-child]:border-0"
      }
    end
  end
end
