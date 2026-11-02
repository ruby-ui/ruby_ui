# frozen_string_literal: true

module RubyUI
  # A div, as in shadcn: the card can't know its heading level. Wrap the text
  # in an h2/h3 when the title should be a heading.
  class CardTitle < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "card-title"},
        class: "font-heading text-base leading-normal font-medium group-data-[size=sm]/card:text-sm"
      }
    end
  end
end
