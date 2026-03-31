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
        class: "relative flex cursor-default select-none items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-none hover:bg-accent hover:text-accent-foreground has-[:checked]:bg-accent aria-[current=true]:bg-accent aria-[current=true]:ring aria-[current=true]:ring-offset-2 has-[input:disabled]:opacity-50 has-[input:disabled]:cursor-not-allowed",
        role: "option",
        data: {
          ruby_ui__combobox_target: "item"
        }
      }
    end
  end
end
