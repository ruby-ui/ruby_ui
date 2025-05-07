# frozen_string_literal: true

module RubyUI
  class FormFieldLabel < Base
    def view_template(&)
      label(**attrs, &)
    end

    private

    def default_attrs
      {
        class: [
          "text-sm font-medium leading-none",
          "peer-disabled:cursor-not-allowed peer-disabled:opacity-70",
          "peer-aria-disabled:cursor-not-allowed peer-aria-disabled:opacity-70 peer-aria-disabled:pointer-events-none"
        ]
      }
    end
  end
end
