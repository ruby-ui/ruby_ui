# frozen_string_literal: true

module RubyUI
  class CommandDialog < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {controller: "ruby-ui--command"}
      }
    end
  end
end
