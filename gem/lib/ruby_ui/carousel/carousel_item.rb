# frozen_string_literal: true

module RubyUI
  class CarouselItem < Base
    ORIENTATION_CLASSES = {horizontal: "pl-4", vertical: "pt-4"}.freeze

    def view_template(&)
      div(**attrs, class: TAILWIND_MERGER.merge([ORIENTATION_CLASSES.fetch(orientation), attrs[:class]]), &)
    end

    private

    def orientation
      context.dig(:ruby_ui_carousel, :orientation) || :horizontal
    end

    def default_attrs
      {
        role: "group",
        aria_roledescription: "slide",
        data: {slot: "carousel-item"},
        class: "min-w-0 shrink-0 grow-0 basis-full"
      }
    end
  end
end
