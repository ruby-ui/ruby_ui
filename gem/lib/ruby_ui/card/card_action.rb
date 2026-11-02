# frozen_string_literal: true

module RubyUI
  # Top-right slot of a CardHeader for a control (a button, a link). It spans
  # the title and description rows.
  class CardAction < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "card-action"},
        class: "col-start-2 row-span-2 row-start-1 self-start justify-self-end"
      }
    end
  end
end
