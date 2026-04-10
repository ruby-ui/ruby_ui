# frozen_string_literal: true

module RubyUI
  class ComboboxSearchInput
    include ComponentBase

    def initialize(placeholder:, **attrs)
      @placeholder = placeholder
      super(**attrs)
    end

    private

    def default_attrs
      {
        type: "search",
        role: "searchbox",
        autocorrect: "off",
        autocomplete: "off",
        spellcheck: "false",
        placeholder: @placeholder,
        class: [
          "flex h-9 w-full rounded-md bg-transparent py-3 text-sm outline-none border-none",
          "focus:ring-0",
          "placeholder:text-muted-foreground",
          "disabled:cursor-not-allowed disabled:opacity-50",
          "aria-disabled:cursor-not-allowed aria-disabled:opacity-50 aria-disabled:pointer-events-none"
        ],
        data: {
          ruby_ui__combobox_target: "searchInput",
          action: "keyup->ruby-ui--combobox#filterItems search->ruby-ui--combobox#filterItems"
        }
      }
    end
  end
end
