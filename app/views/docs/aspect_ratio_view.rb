# frozen_string_literal: true

class Docs::AspectRatioView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render PhlexUI::Typography::H1.new { "Aspect Ratio" }
        render PhlexUI::Typography::P.new { "Displays content within a desired ratio." }
      end

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

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
