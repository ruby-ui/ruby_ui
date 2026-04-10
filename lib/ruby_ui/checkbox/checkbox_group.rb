# frozen_string_literal: true

module RubyUI
  class CheckboxGroup
    include ComponentBase

    private

    def default_attrs
      {
        role: "group",
        data: {
          controller: "ruby-ui--checkbox-group"
        }
      }
    end
  end
end
