# frozen_string_literal: true

module RubyUI
  class CarouselItem
    include ComponentBase

    private

    def default_attrs
      {
        role: "group",
        aria_roledescription: "slide",
        class: [
          "min-w-0 shrink-0 grow-0 basis-full",
          "group-[.is-horizontal]:pl-4",
          "group-[.is-vertical]:pt-4"
        ]
      }
    end
  end
end
