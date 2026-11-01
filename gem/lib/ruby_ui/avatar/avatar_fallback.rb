# frozen_string_literal: true

module RubyUI
  # Shown while the image loads, when it fails, or when there is no image.
  # delay: (ms) waits before showing it, so a fast image doesn't flash the
  # initials first (Base UI's Avatar.Fallback delay).
  class AvatarFallback < Base
    def initialize(delay: nil, **attrs)
      @delay = delay
      super(**attrs)
    end

    def view_template(&)
      span(**attrs, &)
    end

    private

    def delay? = @delay.to_i.positive?

    def default_attrs
      {
        data: {
          slot: "avatar-fallback",
          ruby_ui__avatar_target: "fallback",
          delay: @delay
        },
        # With a delay, start hidden so it can't paint before the controller
        # connects (the controller removes the attribute and runs the timer).
        hidden: delay?,
        class: [
          "flex size-full items-center justify-center rounded-full bg-muted text-sm text-muted-foreground",
          "group-data-[size=xs]/avatar:text-[0.5rem] group-data-[size=sm]/avatar:text-xs group-data-[size=xl]/avatar:text-base",
          # Before the controller connects (or without JS) an image that is
          # still visible wins: the fallback stays out of the way.
          "group-has-[[data-slot=avatar-image]:not(.hidden)]/avatar:hidden"
        ]
      }
    end
  end
end
