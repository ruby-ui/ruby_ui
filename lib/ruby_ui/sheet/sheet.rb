# frozen_string_literal: true

module RubyUI
  class Sheet
    include ComponentBase

    private

    def default_attrs
      {
        data: {controller: "ruby-ui--sheet"}
      }
    end
  end
end
