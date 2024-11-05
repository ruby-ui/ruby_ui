# frozen_string_literal: true

module RubyUI
  class PaginationContent < Base
    def view_template(&)
      ul(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "flex flex-row items-center gap-1"
      }
    end
  end
end
