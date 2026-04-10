# frozen_string_literal: true

module RubyUI
  class CommandInput
    include ComponentBase

    def initialize(placeholder: "Type a command or search...", **attrs)
      @placeholder = placeholder
      super(**attrs)
    end

    private

    def default_attrs
      {
        class: "flex h-10 w-full rounded-md bg-transparent py-3 text-sm outline-none placeholder:text-muted-foreground disabled:cursor-not-allowed disabled:opacity-50",
        placeholder: @placeholder,
        data_action: "input->ruby-ui--command#filter keydown.down->ruby-ui--command#handleKeydown keydown.up->ruby-ui--command#handleKeydown keydown.enter->ruby-ui--command#handleKeydown keydown.esc->ruby-ui--command#dismiss",
        data_ruby_ui__command_target: "input",
        autocomplete: "off",
        autocorrect: "off",
        spellcheck: false,
        autofocus: true,
        aria_autocomplete: "list",
        role: "combobox",
        aria_expanded: true,
        value: ""
      }
    end
  end
end
