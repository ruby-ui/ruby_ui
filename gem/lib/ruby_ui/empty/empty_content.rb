# frozen_string_literal: true

module RubyUI
  class EmptyContent < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "empty-content"},
        class: "flex w-full max-w-sm min-w-0 flex-col items-center gap-4 text-sm text-balance"
      }
    end
  end
end
