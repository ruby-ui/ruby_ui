# frozen_string_literal: true

module RubyUI
  class DataTableSelectAllCheckbox < Component
    private

    def default_attrs
      {
        aria_label: "Select all",
        data: {
          "ruby-ui--data-table-target": "selectAll",
          action: "change->ruby-ui--data-table#toggleAll"
        }
      }
    end
  end
end
