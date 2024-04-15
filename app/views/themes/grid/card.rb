module Themes
  module Grid
    class Card < ApplicationComponent
      def view_template
        render PhlexUI::Card.new(class: "w-full") do
          render PhlexUI::Card::Header.new do
            render PhlexUI::Card::Title.new { 'You might like "PhlexUI"' }
            render PhlexUI::Card::Description.new { "@joeldrapper" }
          end
          render PhlexUI::Card::Content.new do
            render PhlexUI::AspectRatio.new(aspect_ratio: "16/9", class: "rounded-md overflow-hidden border") do
              img(
                alt: "Placeholder",
                loading: "lazy",
                src:
                  helpers.image_url("pattern.jpg")
              )
            end
          end
          render PhlexUI::Card::Footer.new(class: "flex justify-end gap-x-2") do
            render PhlexUI::Button.new(variant: :outline) { "See more" }
            render PhlexUI::Button.new(variant: :primary) { "Buy now" }
          end
        end
      end
    end
  end
end
