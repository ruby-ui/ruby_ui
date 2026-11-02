# frozen_string_literal: true

module RubyUI
  # Title and description in a grid; a CardAction takes a second column on
  # the right, spanning both rows.
  class CardHeader < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "card-header"},
        class: [
          "group/card-header @container/card-header grid auto-rows-min items-start gap-1 rounded-t-xl px-(--card-spacing)",
          "has-data-[slot=card-action]:grid-cols-[1fr_auto] has-data-[slot=card-description]:grid-rows-[auto_auto]",
          "[.border-b]:pb-(--card-spacing)"
        ]
      }
    end
  end
end
