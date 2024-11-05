# frozen_string_literal: true

module RubyUI
  class CardContent < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "p-6 pt-0"
      }
    end
  end
end
