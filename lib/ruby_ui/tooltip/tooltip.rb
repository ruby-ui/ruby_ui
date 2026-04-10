# frozen_string_literal: true

module RubyUI
  class Tooltip
    include ComponentBase

    def initialize(placement: "top", **attrs)
      @placement = placement
      super(**attrs)
    end

    private

    def default_attrs
      {
        data: {
          controller: "ruby-ui--tooltip",
          ruby_ui__tooltip_placement_value: @placement
        },
        class: "group"
      }
    end
  end
end
