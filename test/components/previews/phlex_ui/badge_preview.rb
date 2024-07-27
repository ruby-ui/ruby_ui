# frozen_string_literal: true

# rubocop:disable Layout/LineLength

module PhlexUi
  class BadgePreview < Lookbook::Preview
    # Default Badge
    # ---------------
    # @param variant [Symbol] select { choices: [primary, secondary, outline, destructive, success, warning, slate, gray, zinc, neutral, stone, red, orange, amber, yellow, lime, green, emerald, teal, cyan, sky, blue, indigo, violet, purple, fuchsia, pink, rose] }
    def default(variant: :primary)
      render(TestView.new) do
        Badge(variant:) { "My Badge" }
      end
    end
  end
end
# rubocop:enable Layout/LineLength
