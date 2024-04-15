# frozen_string_literal: true

class Docs::AspectRatioView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Aspect Ratio", description: "Displays content within a desired ratio.")

      render PhlexUI::Typography::H2.new { "Usage" }

      render Docs::VisualCodeExample.new(title: "16/9", context: self) do
        <<~RUBY
          render PhlexUI::AspectRatio.new(aspect_ratio: "16/9", class: "rounded-md overflow-hidden border shadow-sm") do
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
          render PhlexUI::AspectRatio.new(aspect_ratio: "4/3", class: "rounded-md overflow-hidden border shadow-sm") do
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
          render PhlexUI::AspectRatio.new(aspect_ratio: "1/1", class: "rounded-md overflow-hidden border shadow-sm") do
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
          render PhlexUI::AspectRatio.new(aspect_ratio: "21/9", class: "rounded-md overflow-hidden border shadow-sm") do
            img(
              alt: "Placeholder",
              loading: "lazy",
              src:
                helpers.image_path('pattern.jpg')
            )
          end
        RUBY
      end

      render Docs::ComponentsTable.new(components)
    end
  end

  private

  def components
    [
      Docs::ComponentStruct.new(name: "PhlexUI::AspectRatio", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/aspect_ratio.rb", built_using: :phlex)
    ]
  end
end
