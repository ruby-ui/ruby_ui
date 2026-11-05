# frozen_string_literal: true

module RubyUI
  class SheetTitle < Base
    def view_template(&)
      h2(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "sheet-title", ruby_ui__sheet_target: "title"},
        class: "font-heading font-medium text-foreground"
      }
    end
  end
end
