# frozen_string_literal: true

module RubyUI
  class DataTableColumnToggle < Component
    attr_reader :columns, :label

    def initialize(columns:, label: "Columns", **attrs)
      @columns = columns
      @label = label
      super(**attrs)
    end

    # A raw <input> in 1.6: its classes are joined, not Tailwind-merged.
    def checkbox_attrs(column)
      Attributes.flat(
        type: "checkbox",
        checked: column.fetch(:visible, true),
        class: [
          "h-4 w-4 rounded border border-input accent-primary cursor-pointer",
          "checked:bg-primary checked:text-primary-foreground dark:checked:bg-secondary checked:text-primary checked:border-primary"
        ],
        data: {
          column_key: column[:key].to_s,
          action: "change->ruby-ui--data-table-column-visibility#toggle"
        }
      )
    end

    private

    def default_attrs
      {
        class: "relative",
        data: {controller: "ruby-ui--data-table-column-visibility"}
      }
    end
  end
end
