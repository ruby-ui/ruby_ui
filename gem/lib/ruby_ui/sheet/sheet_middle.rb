# frozen_string_literal: true

module RubyUI
  # Body between header and footer. shadcn has no part for it; its examples
  # wrap the body in <div className="px-4">, which this mirrors.
  class SheetMiddle < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "px-4"
      }
    end
  end
end
