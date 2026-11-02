# frozen_string_literal: true

module RubyUI
  # A container for a header, content and footer, like shadcn's Card. The card
  # owns the spacing: it stacks its parts with --card-spacing as gap and
  # vertical padding, and each part pads only its sides. size: :sm tightens
  # the spacing and the title; it is exposed as data-size for the parts.
  class Card < Base
    SIZES = %i[default sm].freeze

    def initialize(size: :default, **attrs)
      @size = size.to_s.to_sym
      @size = :default unless SIZES.include?(@size) # nil or unknown: default size
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "card", size: @size},
        class: [
          "group/card flex flex-col gap-(--card-spacing) overflow-hidden rounded-xl bg-card py-(--card-spacing) text-sm text-card-foreground shadow-xs ring-1 ring-foreground/10",
          "[--card-spacing:--spacing(6)] data-[size=sm]:[--card-spacing:--spacing(4)]",
          # An image as the first or last child runs to the card's edge.
          "has-[>img:first-child]:pt-0 *:[img:first-child]:rounded-t-xl *:[img:last-child]:rounded-b-xl"
        ]
      }
    end
  end
end
