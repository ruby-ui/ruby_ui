# frozen_string_literal: true

module RubyUI
  class FormField
    include ComponentBase

    private

    def default_attrs
      {
        data: {
          controller: "ruby-ui--form-field"
        },
        class: "flex flex-col gap-2"
      }
    end
  end
end
