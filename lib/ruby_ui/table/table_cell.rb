# frozen_string_literal: true

module RubyUI
  class TableCell
    include ComponentBase

    private

    def default_attrs
      {class: "p-2 align-middle [&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px]"}
    end
  end
end
