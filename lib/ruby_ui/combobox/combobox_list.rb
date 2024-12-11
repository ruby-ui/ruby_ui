# frozen_string_literal: true

module RubyUI
  class ComboboxList < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "flex flex-col gap-1 p-1 max-h-72 overflow-y-auto text-foreground",
        role: "listbox"
      }
    end
  end
end
