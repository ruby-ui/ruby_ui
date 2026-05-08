# frozen_string_literal: true

module RubyUI
  class AvatarImage < Base
    def initialize(src:, alt: "", **attrs)
      @src = src
      @alt = alt
      super(**attrs)
    end

    def view_template
      img(**attrs)
    end

    private

    def default_attrs
      {
        loading: "lazy",
        data: {
          ruby_ui__avatar_target: "image",
          action: "load->ruby-ui--avatar#showImage error->ruby-ui--avatar#showFallback"
        },
        class: "aspect-square h-full w-full",
        alt: @alt,
        src: @src
      }
    end
  end
end
