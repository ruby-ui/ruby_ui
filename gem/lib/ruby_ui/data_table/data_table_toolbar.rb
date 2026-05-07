# frozen_string_literal: true

module RubyUI
  class DataTableToolbar < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {class: "flex items-center justify-between gap-2"}
    end
  end
end
