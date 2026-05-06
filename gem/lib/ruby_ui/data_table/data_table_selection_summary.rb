# frozen_string_literal: true

module RubyUI
  class DataTableSelectionSummary < Base
    def initialize(total_on_page: 0, **attrs)
      @total_on_page = total_on_page
      super(**attrs)
    end

    def view_template
      div(**attrs) do
        plain "0 of #{@total_on_page} row(s) selected."
      end
    end

    private

    def default_attrs
      {
        class: "text-sm text-muted-foreground",
        data: {"ruby-ui--data-table-target": "selectionSummary"}
      }
    end
  end
end
