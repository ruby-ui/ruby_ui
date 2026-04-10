# frozen_string_literal: true

module RubyUI
  class CommandDialog
    include ComponentBase

    private

    def default_attrs
      {
        data: {controller: "ruby-ui--command"}
      }
    end
  end
end
