# frozen_string_literal: true

module RubyUI
  class ComboboxList
    include ComponentBase

    private

    def default_attrs
      {
        class: "flex flex-col gap-1 p-1 max-h-72 overflow-y-auto text-foreground",
        role: "listbox"
      }
    end
  end
end
