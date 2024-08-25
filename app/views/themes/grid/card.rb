module Themes
  module Grid
    class Card < ApplicationComponent
      def view_template
        Card(class: "w-full") do
          CardHeader do
            CardTitle { 'You might like "RBUI"' }
            CardDescription { "@joeldrapper" }
          end
          CardContent do
            AspectRatio(aspect_ratio: "16/9", class: "rounded-md overflow-hidden border") do
              img(
                alt: "Placeholder",
                loading: "lazy",
                src:
                  helpers.image_url("pattern.jpg")
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
