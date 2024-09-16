# frozen_string_literal: true

module RBUI
  class AvatarPreview < Lookbook::Preview
    # Avatar sizes
    # ---------------
    # @param size [Symbol] select { choices: [sm, md, lg, xl] }
    def sizes(size: :md)
      render(TestView.new) do
        Avatar(size:) do
          AvatarImage(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
        end
      end
    end

    # Avatar Images
    def image
      render(TestView.new) do
        Avatar do
          AvatarImage(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
        end
      end
    end

    # Avatar fallback
    def fallback
      render(TestView.new) do
        Avatar { AvatarFallback { "JD" } }
      end
    end
  end
end
