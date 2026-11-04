# frozen_string_literal: true

module RubyUI
  class TableRow < Base
    def view_template(&)
      tr(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "table-row"},
        class: "border-b transition-colors hover:bg-muted/50 has-aria-expanded:bg-muted/50 data-[state=selected]:bg-muted"
      }
    end
  end
end
