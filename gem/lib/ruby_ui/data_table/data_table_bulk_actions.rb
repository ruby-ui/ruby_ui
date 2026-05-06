# frozen_string_literal: true

module RubyUI
  class DataTableBulkActions < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "hidden items-center gap-2",
        data: {"ruby-ui--data-table-target": "bulkActions"}
      }
    end
  end
end
