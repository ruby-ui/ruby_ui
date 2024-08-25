# frozen_string_literal: true

module Rbui
  class AspectRatioPreview < Lookbook::Preview
    # AspectRatio 16/9
    # ---------------
    def aspect_16x9
      render(TestView.new) do
        div(class: "w-96") do
          AspectRatio(aspect_ratio: "16/9") do |aspect_ratio|
            aspect_ratio.img(alt: "Placeholder", loading: "lazy", src: helpers.image_path("pattern.jpg"))
          end
        end
      end
    end

    # AspectRatio 4/3
    def aspect_4x3
      render(TestView.new) do
        div(class: "w-96") do
          AspectRatio(aspect_ratio: "4/3") do |aspect_ratio|
            aspect_ratio.img(alt: "Placeholder", loading: "lazy", src: helpers.image_path("pattern.jpg"))
          end
        end
      end
    end

    # AspectRatio 1/1
    def aspect_1x1
      render(TestView.new) do
        div(class: "w-96") do
          AspectRatio(aspect_ratio: "1/1") do |aspect_ratio|
            aspect_ratio.img(alt: "Placeholder", loading: "lazy", src: helpers.image_path("pattern.jpg"))
          end
        end
      end
    end
  end
end
