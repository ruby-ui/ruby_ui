# frozen_string_literal: true

module RubyUI
  class DataTableToolbar < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      # mb-6 overrides DataTable's space-y-4 (zero specificity) below the
      # toolbar: the dashboard-01 block puts 24px (gap-6) between the toolbar
      # and the table, 16px between the table and the pagination.
      {class: "mb-6 flex items-center justify-between gap-2"}
    end
  end
end
