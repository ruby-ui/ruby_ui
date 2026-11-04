# frozen_string_literal: true

module RubyUI
  class TableHeader < Base
    def view_template(&)
      thead(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "table-header"},
        class: "[&_tr]:border-b"
      }
    end
  end
end
