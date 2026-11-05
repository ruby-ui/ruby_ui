# frozen_string_literal: true

module RubyUI
  class PaginationContent < Base
    def view_template(&)
      ul(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "pagination-content"},
        class: "flex items-center gap-1"
      }
    end
  end
end
