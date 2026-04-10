# frozen_string_literal: true

module RubyUI
  class SheetFooter
    include ComponentBase

    private

    def default_attrs
      {
        class: "flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2 gap-y-2 sm:gap-y-0"
      }
    end
  end
end
