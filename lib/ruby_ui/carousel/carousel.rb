# frozen_string_literal: true

module RubyUI
  class Carousel < Base
    def initialize(orientation: :horizontal, options: {}, **user_attrs)
      @orientation = orientation
      @options = options

      super(**user_attrs)
    end

    def view_template(&)
      CarouselContext.with_context(orientation: @orientation) do
        div(**attrs, &)
      end
    end

    private

    def default_attrs
      {
        class: "relative",
        role: "region",
        aria_roledescription: "carousel",
        data: {
          controller: "ruby-ui--carousel",
          ruby_ui__carousel_options_value: default_options.merge(@options).to_json
        }
      }
    end

    def default_options
      {
        axis: (@orientation == :horizontal) ? "x" : "y"
      }
    end
  end
end
