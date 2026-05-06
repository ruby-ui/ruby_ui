# frozen_string_literal: true

module RubyUI
  class ComboboxItem < Base
    def view_template(&)
      label(**attrs, &)
    end

    private

    def default_attrs
      {
        class: [
          "flex flex-row w-full text-wrap [&>span,&>div]:truncate gap-2 items-center rounded-sm px-2 py-1 text-sm outline-none cursor-pointer",
          "select-none has-[:checked]:bg-accent hover:bg-accent p-2",
          "[&>svg]:pointer-events-none [&>svg]:size-4 [&>svg]:shrink-0 aria-[current=true]:bg-accent aria-[current=true]:ring aria-[current=true]:ring-offset-2",
          "has-disabled:opacity-50 has-disabled:cursor-not-allowed"
        ],
        role: "option",
        data: {
          ruby_ui__combobox_target: "item"
        }
      }
    end
  end
end
