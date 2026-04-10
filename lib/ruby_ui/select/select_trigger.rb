# frozen_string_literal: true

module RubyUI
  class SelectTrigger
    include ComponentBase

    private

    def default_attrs
      {
        type: "button",
        role: "combobox",
        data: {
          action: "ruby-ui--select#onClick",
          ruby_ui__select_target: "trigger"
        },
        aria: {
          controls: "radix-:r0:",
          expanded: "false",
          autocomplete: "none",
          haspopup: "listbox",
          activedescendant: true
        },
        class: [
          "truncate w-full flex h-9 items-center justify-between whitespace-nowrap rounded-md border border-input bg-transparent px-3 py-2 text-sm shadow-sm ring-offset-background",
          "placeholder:text-muted-foreground",
          "focus:outline-none focus:ring-1 focus:ring-ring",
          "disabled:cursor-not-allowed disabled:opacity-50",
          "aria-disabled:cursor-not-allowed aria-disabled:opacity-50 aria-disabled:pointer-events-none"
        ]
      }
    end
  end
end
