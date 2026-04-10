# frozen_string_literal: true

module RubyUI
  class PaginationEllipsis
    include ComponentBase

    private

    def default_attrs
      {
        aria: {hidden: true},
        class: "flex h-9 w-9 items-center justify-center"
      }
    end
  end
end
