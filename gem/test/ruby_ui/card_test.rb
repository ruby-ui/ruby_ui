# frozen_string_literal: true

require "test_helper"

class RubyUI::CardTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Card(class: "w-96") do
        RubyUI.CardHeader do
          RubyUI.CardTitle { 'You might like "RubyUI"' }
          RubyUI.CardDescription { "@joeldrapper" }
        end
        RubyUI.CardContent do
          RubyUI.AspectRatio(ratio: "16/9", class: "rounded-md overflow-hidden border") do |aspect_ratio|
            aspect_ratio.img(
              alt: "Placeholder",
              class: "absolute inset-0 size-full object-cover",
              loading: "lazy",
              src: "https://avatars.githubusercontent.com/u/246692?v=4"
            )
          end
        end
        RubyUI.CardFooter(class: "flex justify-end gap-x-2") do
          RubyUI.Button(variant: :outline) { "See more" }
          RubyUI.Button(variant: :primary) { "Buy now" }
        end
      end
    end

    assert_match(/You might like/, output)
  end
end
