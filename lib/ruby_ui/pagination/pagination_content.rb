# frozen_string_literal: true

module RubyUI
  class PaginationContent
    include ComponentBase

    private

    def default_attrs
      {
        class: "flex flex-row items-center gap-1"
      }
    end
  end
end
