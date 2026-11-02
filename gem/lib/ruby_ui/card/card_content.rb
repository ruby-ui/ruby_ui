# frozen_string_literal: true

module RubyUI
  class CardContent < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "card-content"},
        class: "px-(--card-spacing)"
      }
    end
  end
end
