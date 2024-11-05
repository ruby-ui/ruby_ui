# frozen_string_literal: true

module RubyUI
  class Tooltip < Base
    def initialize(placement: "top", **attrs)
      @placement = placement
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          controller: "rbui--tooltip",
          rbui__tooltip_placement_value: @placement
        },
        class: "group"
      }
    end
  end
end
