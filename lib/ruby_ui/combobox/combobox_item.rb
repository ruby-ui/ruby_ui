# frozen_string_literal: true

module RubyUI
  class ComboboxItem < Base
    def view_template(&)
      label(**attrs) do
        yield if block_given?
        render ComboboxItemIndicator.new
      end
    end

    private

    def default_attrs
      {
        class: "relative flex cursor-default select-none items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-none hover:bg-accent hover:text-accent-foreground",
        role: "option",
        data: {
          ruby_ui__combobox_target: "item"
        }
      }
    end
  end
end
