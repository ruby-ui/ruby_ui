# frozen_string_literal: true

module RubyUI
  class CardHeader < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "flex flex-col space-y-1.5 p-6"
      }
    end
  end
end
