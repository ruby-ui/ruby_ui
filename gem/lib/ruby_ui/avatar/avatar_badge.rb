# frozen_string_literal: true

module RubyUI
  # A dot (or a small icon) on the avatar's bottom-right corner, e.g. an
  # online status. Its size follows the avatar's size; on :xs and :sm the
  # icon is hidden and only the dot shows.
  class AvatarBadge < Base
    def view_template(&)
      span(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "avatar-badge"},
        class: [
          "absolute right-0 bottom-0 z-10 inline-flex items-center justify-center rounded-full bg-blend-color ring-2 select-none",
          "bg-primary text-primary-foreground ring-background",
          "group-data-[size=xs]/avatar:size-1.5 group-data-[size=xs]/avatar:[&>svg]:hidden",
          "group-data-[size=sm]/avatar:size-2 group-data-[size=sm]/avatar:[&>svg]:hidden",
          "group-data-[size=default]/avatar:size-2.5 group-data-[size=default]/avatar:[&>svg]:size-2",
          "group-data-[size=lg]/avatar:size-3 group-data-[size=lg]/avatar:[&>svg]:size-2",
          "group-data-[size=xl]/avatar:size-5 group-data-[size=xl]/avatar:[&>svg]:size-3"
        ]
      }
    end
  end
end
