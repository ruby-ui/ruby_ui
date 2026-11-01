# frozen_string_literal: true

module RubyUI
  # Overlapping avatars, each ringed in the background color. End it with an
  # AvatarGroupCount for the "+N" bubble.
  class AvatarGroup < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "avatar-group"},
        class: "group/avatar-group flex -space-x-2 *:data-[slot=avatar]:ring-2 *:data-[slot=avatar]:ring-background"
      }
    end
  end
end
