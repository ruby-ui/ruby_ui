# frozen_string_literal: true

module RubyUI
  class Pagination
    include ComponentBase

    private

    def default_attrs
      {
        aria: {label: "pagination"},
        class: "mx-auto flex w-full justify-center",
        role: "navigation"
      }
    end
  end
end
