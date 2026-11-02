# frozen_string_literal: true

module RubyUI
  # Shown only while a search matches no item. Put it inside CommandList.
  class CommandEmpty < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        role: "presentation",
        hidden: true,
        class: "py-6 text-center text-sm",
        data: {slot: "command-empty", ruby_ui__command_target: "empty"}
      }
    end
  end
end
