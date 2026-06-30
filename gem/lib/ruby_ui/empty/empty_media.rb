# frozen_string_literal: true

module RubyUI
  class EmptyMedia < Base
    VARIANTS = {
      default: "bg-transparent",
      icon: "size-10 rounded-xl bg-muted text-foreground [&_svg:not([class*='size-'])]:size-5"
    }

    def initialize(variant: :default, **attrs)
      @variant = variant
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "empty-icon", variant: @variant},
        class: [
          "mb-2 flex shrink-0 items-center justify-center [&_svg]:pointer-events-none [&_svg]:shrink-0",
          VARIANTS[@variant]
        ]
      }
    end
  end
end
