# frozen_string_literal: true

module RubyUI
  class TableHeader < Base
    include TableSlot

    def view_template(&)
      thead(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: default_slot("table-header")}.compact,
        class: "[&_tr]:border-b"
      }
    end
  end
end
