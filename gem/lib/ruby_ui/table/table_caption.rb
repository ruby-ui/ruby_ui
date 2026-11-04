# frozen_string_literal: true

module RubyUI
  class TableCaption < Base
    include TableSlot

    def view_template(&)
      caption(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: default_slot("table-caption")}.compact,
        class: "mt-4 text-sm text-muted-foreground"
      }
    end
  end
end
