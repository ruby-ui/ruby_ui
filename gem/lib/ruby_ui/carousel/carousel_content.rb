# frozen_string_literal: true

module RubyUI
  class CarouselContent < Base
    ORIENTATION_CLASSES = {horizontal: "-ml-4", vertical: "-mt-4 flex-col"}.freeze

    def view_template(&)
      div(class: "overflow-hidden", data: {slot: "carousel-content", ruby_ui__carousel_target: "viewport"}) do
        div(**attrs, class: TAILWIND_MERGER.merge([ORIENTATION_CLASSES.fetch(orientation), attrs[:class]]), &)
      end
    end

    private

    def orientation
      context.dig(:ruby_ui_carousel, :orientation) || :horizontal
    end

    def default_attrs
      {class: "flex"}
    end
  end
end
