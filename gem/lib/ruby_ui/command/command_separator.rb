# frozen_string_literal: true

module RubyUI
  # A rule between CommandGroups, hidden while a search is typed.
  class CommandSeparator < Base
    def view_template
      div(**attrs)
    end

    private

    def default_attrs
      {
        role: "separator",
        class: "-mx-1 h-px w-auto bg-border",
        data: {slot: "command-separator", ruby_ui__command_target: "separator"}
      }
    end
  end
end
