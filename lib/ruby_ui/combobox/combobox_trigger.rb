# frozen_string_literal: true

module RubyUI
  class ComboboxTrigger
    include ComponentBase

    def initialize(placeholder: "", **attrs)
      @placeholder = placeholder
      super(**attrs)
    end

    attr_reader :placeholder

    private

    def default_attrs
      {
        type: "button",
        class: [
          "flex h-full w-full items-center whitespace-nowrap rounded-md text-sm ring-offset-background transition-colors border border-input bg-background h-9 px-4 py-2 justify-between",
          "hover:bg-accent hover:text-accent-foreground",
          "disabled:pointer-events-none disabled:opacity-50",
          "aria-disabled:pointer-events-none aria-disabled:opacity-50 aria-disabled:cursor-not-allowed",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
        ],
        data: {
          placeholder: @placeholder,
          ruby_ui__combobox_target: "trigger",
          action: "ruby-ui--combobox#togglePopover"
        },
        aria: {
          haspopup: "listbox",
          expanded: "false"
        }
      }
    end
  end
end
