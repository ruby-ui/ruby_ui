# frozen_string_literal: true

module Rbui
  class CardPreview < Lookbook::Preview
    # Default CardPreview
    # ---------------
    def default
      render(TestView.new) do
        Card(class: "w-96") do
          CardHeader do
            CardTitle { 'You might like "PhlexUi"' }
            CardDescription { "@joeldrapper" }
          end

          CardContent do
            AspectRatio(aspect_ratio: "16/9", class: "rounded-md overflow-hidden border") do
              img(
                alt: "Placeholder",
                loading: "lazy",
                src: helpers.image_url("pattern.jpg")
              )
            end
          end

          CardFooter(class: "flex justify-end gap-x-2") do
            Button(variant: :outline) { "See more" }
            Button(variant: :primary) { "Buy now" }
          end
        end
      end
    end
  end
end
