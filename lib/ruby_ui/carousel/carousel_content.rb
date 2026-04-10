# frozen_string_literal: true

module RubyUI
  class CarouselContent
    include ComponentBase

    private

    def default_attrs
      {
        class: [
          "flex",
          "group-[.is-horizontal]:-ml-4",
          "group-[.is-vertical]:-mt-4 group-[.is-vertical]:flex-col"
        ]
      }
    end
  end
end
