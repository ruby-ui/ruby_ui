# frozen_string_literal: true

module RubyUI
  class SheetClose < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {action: "click->ruby-ui--sheet-content#close"}
      }
    end
  end
end
