# frozen_string_literal: true

module RubyUI
  # Page navigation, styled after shadcn's Pagination (Base UI + vega).
  class Pagination < Base
    def view_template(&)
      nav(**attrs, &)
    end

    private

    def default_attrs
      {
        role: "navigation",
        aria: {label: "pagination"},
        data: {slot: "pagination"},
        class: "mx-auto flex w-full justify-center"
      }
    end
  end
end
