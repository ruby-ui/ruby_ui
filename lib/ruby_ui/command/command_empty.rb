# frozen_string_literal: true

module RubyUI
  class CommandEmpty
    include ComponentBase

    private

    def default_attrs
      {
        class: "py-6 text-center text-sm",
        role: "presentation",
        data: {ruby_ui__command_target: "empty"}
      }
    end
  end
end
