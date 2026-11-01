# frozen_string_literal: true

module RubyUI
  # The "+N" bubble at the end of an AvatarGroup. It takes the size of the
  # group's avatars.
  class AvatarGroupCount < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "avatar-group-count"},
        class: [
          "relative flex size-8 shrink-0 items-center justify-center rounded-full bg-muted text-sm text-muted-foreground ring-2 ring-background [&>svg]:size-4",
          "group-has-data-[size=xs]/avatar-group:size-4 group-has-data-[size=xs]/avatar-group:text-[0.5rem] group-has-data-[size=xs]/avatar-group:[&>svg]:size-2",
          "group-has-data-[size=sm]/avatar-group:size-6 group-has-data-[size=sm]/avatar-group:text-xs group-has-data-[size=sm]/avatar-group:[&>svg]:size-3",
          "group-has-data-[size=lg]/avatar-group:size-10 group-has-data-[size=lg]/avatar-group:[&>svg]:size-5",
          "group-has-data-[size=xl]/avatar-group:size-20 group-has-data-[size=xl]/avatar-group:text-base group-has-data-[size=xl]/avatar-group:[&>svg]:size-8"
        ]
      }
    end
  end
end
