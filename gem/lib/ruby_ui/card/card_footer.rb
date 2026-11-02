# frozen_string_literal: true

module RubyUI
  class CardFooter < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "card-footer"},
        class: "flex items-center rounded-b-xl px-(--card-spacing) [.border-t]:pt-(--card-spacing)"
      }
    end
  end
end
