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
        # NB: do not set loading: "lazy" here. avatar_controller hides a not-yet-loaded
        # image with `display:none` (the `hidden` class) so the fallback shows. The
        # browser never fetches a `loading="lazy"` image that generates no box, so its
        # `load` event never fires and the image stays hidden forever (#415). shadcn/radix
        # do not lazy-load the avatar image either.
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
