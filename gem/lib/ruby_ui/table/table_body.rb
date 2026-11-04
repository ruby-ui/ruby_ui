# frozen_string_literal: true

module RubyUI
  class TableBody < Base
    def view_template(&)
      tbody(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "table-body"},
        class: "[&_tr:last-child]:border-0"
      }
    end
  end
end
