# frozen_string_literal: true

module RubyUI
  class Empty < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "empty"},
        class: "flex w-full min-w-0 flex-1 flex-col items-center justify-center gap-4 rounded-3xl border border-dashed p-12 text-center text-balance"
      }
    end
  end
end
