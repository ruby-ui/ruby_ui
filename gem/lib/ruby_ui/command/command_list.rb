# frozen_string_literal: true

module RubyUI
  # The listbox of a Command. It scrolls past 18rem (max-h-72).
  class CommandList < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        role: "listbox",
        tabindex: "-1",
        class: "max-h-72 scroll-py-1 overflow-x-hidden overflow-y-auto outline-none [scrollbar-width:none] [&::-webkit-scrollbar]:hidden",
        data: {slot: "command-list", ruby_ui__command_target: "list"}
      }
    end
  end
end
