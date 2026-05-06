# frozen_string_literal: true

module RubyUI
  class DataTablePaginationBar < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {class: "flex items-center justify-between gap-4 py-2"}
    end
  end
end
