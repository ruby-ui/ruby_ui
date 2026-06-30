# frozen_string_literal: true

module RubyUI
  class EmptyHeader < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "empty-header"},
        class: "flex max-w-sm flex-col items-center gap-2"
      }
    end
  end
end
