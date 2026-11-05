# frozen_string_literal: true

module RubyUI
  # Wraps the element that opens the sheet. The controller puts
  # aria-haspopup/aria-expanded/aria-controls on the button or link inside.
  class SheetTrigger < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          slot: "sheet-trigger",
          ruby_ui__sheet_target: "trigger",
          action: "click->ruby-ui--sheet#open"
        },
        class: "inline-block"
      }
    end
  end
end
