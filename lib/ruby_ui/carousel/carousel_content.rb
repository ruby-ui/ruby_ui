# frozen_string_literal: true

module RubyUI
  class CarouselContent < Base
    ORIENTATION_CLASSES = {
      horizontal: "-ml-4",
      vertical: "-mt-4 flex-col"
    }

    def initialize(**attrs)
      @orientation = CarouselContext.orientation || :horizontal

      super
    end

    def view_template(&)
      div(class: "overflow-hidden", data: {ruby_ui__carousel_target: "viewport"}) do
        div(**attrs, &)
      end
    end

    private

    def default_attrs
      {
        class: ["flex", ORIENTATION_CLASSES[@orientation]]
      }
    end
  end
end
