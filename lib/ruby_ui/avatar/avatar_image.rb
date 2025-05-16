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
        class: "absolute aspect-square h-full w-full z-1",
        alt: @alt,
        src: @src
      }
    end
  end
end
