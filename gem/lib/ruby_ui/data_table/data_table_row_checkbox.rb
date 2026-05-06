# frozen_string_literal: true

module RubyUI
  class DataTableRowCheckbox < Base
    def initialize(value:, name: "ids[]", label: nil, **attrs)
      @value = value
      @name = name
      @label = label
      super(**attrs)
    end

    def view_template
      render RubyUI::Checkbox.new(**attrs)
    end

    private

    def default_attrs
      {
        name: @name,
        value: @value,
        aria_label: @label || "Select row #{@value}",
        data: {
          "ruby-ui--data-table-target": "rowCheckbox",
          action: "change->ruby-ui--data-table#toggleRow"
        }
      }
    end
  end
end
