# frozen_string_literal: true

module RubyUI
  class AvatarFallback < Base
    def view_template(&)
      span(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          ruby_ui__avatar_target: "fallback"
        },
        class: "flex h-full w-full items-center justify-center rounded-full bg-muted"
      }
    end
  end
end
