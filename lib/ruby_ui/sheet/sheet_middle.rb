# frozen_string_literal: true

module RubyUI
  class SheetMiddle < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: 'py-4'
      }
    end
  end
end
