# frozen_string_literal: true

class Docs::AspectRatioView < ApplicationView
  def view_template
    component = "AspectRatio"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Aspect Ratio", description: "Displays content within a desired ratio.")

      TypographyH2 { "Usage" }

      render Docs::VisualCodeExample.new(title: "16/9", context: self) do
        <<~RUBY
          AspectRatio(aspect_ratio: "16/9", class: "rounded-md overflow-hidden border shadow-sm") do
            img(
              alt: "Placeholder",
              loading: "lazy",
              src:
                helpers.image_path('pattern.jpg')
            )
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "4/3", context: self) do
        <<~RUBY
          AspectRatio(aspect_ratio: "4/3", class: "rounded-md overflow-hidden border shadow-sm") do
            img(
              alt: "Placeholder",
              loading: "lazy",
              src:
                helpers.image_path('pattern.jpg')
            )
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "1/1", context: self) do
        <<~RUBY
          AspectRatio(aspect_ratio: "1/1", class: "rounded-md overflow-hidden border shadow-sm") do
            img(
              alt: "Placeholder",
              loading: "lazy",
              src:
                helpers.image_path('pattern.jpg')
            )
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "21/9", context: self) do
        <<~RUBY
          AspectRatio(aspect_ratio: "21/9", class: "rounded-md overflow-hidden border shadow-sm") do
            img(
              alt: "Placeholder",
              loading: "lazy",
              src:
                helpers.image_path('pattern.jpg')
            )
          end
        RUBY
      end

      render Docs::ComponentsTable.new(component_references(component, Docs::VisualCodeExample.collected_code), component_files(component))
    end
  end
end
