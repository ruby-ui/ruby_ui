# frozen_string_literal: true

module RubyUI
  # A keyboard hint at the end of a CommandItem (e.g. "⌘P").
  class CommandShortcut < Base
    def view_template(&)
      span(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "ml-auto text-xs tracking-widest text-muted-foreground group-data-selected/command-item:text-foreground",
        data: {slot: "command-shortcut"}
      }
    end
  end
end
