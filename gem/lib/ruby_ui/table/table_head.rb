# frozen_string_literal: true

module RubyUI
  class TableHead < Base
    include TableSlot

    def view_template(&)
      th(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: default_slot("table-head")}.compact,
        class: "h-10 px-2 text-left align-middle font-medium whitespace-nowrap text-foreground [&:has([role=checkbox])]:pr-0 [&:has([data-slot=checkbox])]:pr-0"
      }
    end
  end
end
