# frozen_string_literal: true

module RubyUI
  class SheetHeader < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "sheet-header"},
        class: "flex flex-col gap-1.5 p-4"
      }
    end
  end
end
