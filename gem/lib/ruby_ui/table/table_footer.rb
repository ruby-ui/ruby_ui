# frozen_string_literal: true

module RubyUI
  class TableFooter < Base
    include TableSlot

    def view_template(&)
      tfoot(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: default_slot("table-footer")}.compact,
        class: "border-t bg-muted/50 font-medium [&>tr]:last:border-b-0"
      }
    end
  end
end
