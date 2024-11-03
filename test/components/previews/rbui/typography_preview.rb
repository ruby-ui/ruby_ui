# frozen_string_literal: true

module RBUI
  class TypographyPreview < Lookbook::Preview
    # Heading
    # ---------------
    # @param level [Symbol] select { choices: [1, 2, 3, 4] }
    # @param as [Symbol] select { choices: [h1, h2] }
    # @param size [Symbol] select { choices: [1,2,3,4,5,6,7,8,9] }
    def heading(level: 1, as: "h1", size: 6)
      render(TestView.new) do
        Heading(level:, as:, size:) { "This is an H1 heading" }
      end
    end
  end
end
