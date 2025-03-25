# frozen_string_literal: true

module RubyUI
  class Skeleton < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "animate-pulse rounded-md bg-primary/10"
      }
    end
  end
end
