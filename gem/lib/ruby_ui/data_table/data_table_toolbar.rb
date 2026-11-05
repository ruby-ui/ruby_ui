# frozen_string_literal: true

module RubyUI
  class DataTableToolbar < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      # pb-2 on top of DataTable's space-y-4 leaves 24px above the table, as the
      # gap-6 between the toolbar and the table in shadcn's dashboard-01 block.
      {class: "flex items-center justify-between gap-2 pb-2"}
    end
  end
end
