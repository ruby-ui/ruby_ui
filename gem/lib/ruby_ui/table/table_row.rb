# frozen_string_literal: true

module RubyUI
  class TableRow < Base
    include TableSlot

    def view_template(&)
      tr(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: default_slot("table-row")}.compact,
        class: "border-b transition-colors hover:bg-muted/50 has-aria-expanded:bg-muted/50 data-[state=selected]:bg-muted"
      }
    end
  end
end
