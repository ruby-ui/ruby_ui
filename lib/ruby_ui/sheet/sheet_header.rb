# frozen_string_literal: true

module RubyUI
  class SheetHeader
    include ComponentBase

    private

    def default_attrs
      {
        class: "flex flex-col space-y-1.5 text-center sm:text-left"
      }
    end
  end
end
