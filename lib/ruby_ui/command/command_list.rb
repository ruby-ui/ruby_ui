# frozen_string_literal: true

module RubyUI
  class CommandList
    include ComponentBase

    private

    def default_attrs
      {
        class: "divide-y divide-border"
      }
    end
  end
end
