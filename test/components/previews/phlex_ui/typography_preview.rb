# frozen_string_literal: true

module PhlexUi
  class TypographyPreview < Lookbook::Preview
    # H1
    # ---------------
    # @param variant [Symbol] select { choices: [primary, title] }
    # @param weight [Symbol] select { choices: [medium, profile] }
    def h1(variant: :primary, weight: :medium)
      render(TestView.new) do
        TypographyH1(variant:, weight:) { "This is an H1 heading" }
      end
    end

    # H2
    # ---------------
    # @param variant [Symbol] select { choices: [primary, title] }
    # @param weight [Symbol] select { choices: [medium, profile] }
    def h2(variant: :primary, weight: :medium)
      render(TestView.new) do
        TypographyH2(variant:, weight:) { "This is an H2 heading" }
      end
    end

    # H3
    # ---------------
    # @param variant [Symbol] select { choices: [primary, title] }
    # @param weight [Symbol] select { choices: [medium, profile] }
    def h3(variant: :primary, weight: :medium)
      render(TestView.new) do
        TypographyH3(variant:, weight:) { "This is an H3 heading" }
      end
    end

    # H4
    # ---------------
    # @param variant [Symbol] select { choices: [primary, title] }
    # @param weight [Symbol] select { choices: [medium, profile] }
    def h4(variant: :primary, weight: :medium)
      render(TestView.new) do
        TypographyH4(variant:, weight:) { "This is an H4 heading" }
      end
    end

    # p
    # ---------------
    # @param size [Symbol] select { choices: [xsmall, small, base] }
    # @param weight [Symbol] select { choices: [medium, normal] }
    # @param color [Symbol] select { choices: [primary, title, secondary, disabled] }
    def p(size: :base, weight: :medium, color: :primary)
      render(TestView.new) do
        TypographyP(size:, weight:, color:) { "This is an Paragraph" }
      end
    end
  end
end
