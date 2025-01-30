# frozen_string_literal: true

module RubyUI
  class CarouselItem < Base
    ORIENTATION_CLASSES = {
      horizontal: "pl-4",
      vertical: "pt-4"
    }

    def initialize(**attrs)
      @orientation = CarouselContext.orientation || :horizontal

      super
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        role: "group",
        aria_roledescription: "slide",
        class: ["min-w-0 shrink-0 grow-0 basis-full", ORIENTATION_CLASSES[@orientation]]
      }
    end
  end
end
