# frozen_string_literal: true

module RubyUI
  class DataTableSelectionSummary < Component
    attr_reader :total_on_page

    def initialize(total_on_page: 0, **attrs)
      @total_on_page = total_on_page
      super(**attrs)
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
