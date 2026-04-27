# frozen_string_literal: true

module RubyUI
  class DataTableSelectAllCheckbox < Base
    def view_template
      render RubyUI::Checkbox.new(**attrs)
    end

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
