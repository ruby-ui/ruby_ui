# frozen_string_literal: true

module RubyUI
  class Skeleton
    include ComponentBase

    private

    def default_attrs
      {
        class: "animate-pulse rounded-md bg-primary/10"
      }
    end
  end
end
