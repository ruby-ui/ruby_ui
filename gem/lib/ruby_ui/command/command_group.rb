# frozen_string_literal: true

module RubyUI
  # A titled group of CommandItems. The items sit in a role=group named after
  # the heading; the group hides while a search matches none of its items.
  class CommandGroup < Base
    def initialize(title: nil, **attrs)
      @title = title
      super(**attrs)
    end

    def view_template(&)
      div(**attrs) do
        if @title
          div(
            aria_hidden: "true",
            class: "px-2 py-1.5 text-xs font-medium text-muted-foreground",
            data: {slot: "command-group-heading", ruby_ui__command_target: "heading"}
          ) { @title }
        end
        div(role: "group", data: {slot: "command-group-items"}, &)
      end
    end

    private

    def default_attrs
      {
        role: "presentation",
        class: "overflow-hidden p-1 text-foreground",
        data: {slot: "command-group", ruby_ui__command_target: "group"}
      }
    end
  end
end
