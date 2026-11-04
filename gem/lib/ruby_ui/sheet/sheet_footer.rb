# frozen_string_literal: true

module RubyUI
  class SheetFooter < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "sheet-footer"},
        class: "mt-auto flex flex-col gap-2 p-4"
      }
    end
  end
end
