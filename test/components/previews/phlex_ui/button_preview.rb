# frozen_string_literal: true

module PhlexUi
  class ButtonPreview < Lookbook::Preview
    # Primary Button
    # ---------------
    # @param variant [Symbol] select { choices: [primary, destructive, outline, secondary, ghost, link] }
    # @param size [Symbol] select { choices: [sm, md, lg, xl] }
    def primary(variant: :primary, size: :md)
      render(TestView.new) do
        Button(variant:, size:) { variant.capitalize }
      end
    end

    # Destructive Button
    def destructive(variant: :destructive, size: :md)
      render(TestView.new) do
        Button(variant:, size:) { variant.capitalize }
      end
    end

    # Outline Button
    def outline(variant: :outline, size: :md)
      render(TestView.new) do
        Button(variant:, size:) { variant.capitalize }
      end
    end

    # Secondary Button
    def secondary(variant: :secondary, size: :md)
      render(TestView.new) do
        Button(variant:, size:) { variant.capitalize }
      end
    end

    # Ghost Button
    def ghost(variant: :ghost, size: :md)
      render(TestView.new) do
        Button(variant:, size:) { variant.capitalize }
      end
    end

    # Link Button
    def link(variant: :link, size: :md)
      render(TestView.new) do
        Button(variant:, size:) { variant.capitalize }
      end
    end
  end
end
