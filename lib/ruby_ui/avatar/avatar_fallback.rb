# frozen_string_literal: true

module RubyUI
  class AvatarFallback
    include ComponentBase

    private

    def default_attrs
      {class: "flex h-full w-full items-center justify-center rounded-full bg-muted"}
    end
  end
end
