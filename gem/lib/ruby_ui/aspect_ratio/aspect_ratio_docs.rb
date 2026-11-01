# frozen_string_literal: true

class Views::Docs::AspectRatio < Views::Base
  def view_template
    component = "AspectRatio"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Aspect Ratio", description: "Displays content within a desired ratio.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "16/9", description: "ratio: takes a \"W/H\" String or a Numeric (16.0 / 9). The image is positioned by its own classes; AspectRatio only sizes the box.", context: self) do
        <<~RUBY
          AspectRatio(ratio: "16/9", class: "rounded-lg bg-muted") do
            img(
              alt: "Placeholder",
              class: "absolute inset-0 size-full rounded-lg object-cover",
              loading: "lazy",
              src: image_path('pattern.jpg')
            )
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "4/3", context: self) do
        <<~RUBY
          AspectRatio(ratio: "4/3", class: "rounded-lg bg-muted") do
            img(
              alt: "Placeholder",
              class: "absolute inset-0 size-full rounded-lg object-cover",
              loading: "lazy",
              src: image_path('pattern.jpg')
            )
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "1/1", context: self) do
        <<~RUBY
          AspectRatio(ratio: "1/1", class: "rounded-lg bg-muted") do
            img(
              alt: "Placeholder",
              class: "absolute inset-0 size-full rounded-lg object-cover",
              loading: "lazy",
              src: image_path('pattern.jpg')
            )
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "21/9", context: self) do
        <<~RUBY
          AspectRatio(ratio: "21/9", class: "rounded-lg bg-muted") do
            img(
              alt: "Placeholder",
              class: "absolute inset-0 size-full rounded-lg object-cover",
              loading: "lazy",
              src: image_path('pattern.jpg')
            )
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Content taller than the ratio", description: "The box grows when its content is taller than the ratio allows. With overflow-hidden it keeps its 4/1 ratio and clips the lines that don't fit. Remove overflow-hidden and the box grows to show all eight.", context: self) do
        <<~RUBY
          AspectRatio(ratio: "4/1", class: "overflow-hidden rounded-lg bg-muted p-3 text-sm text-muted-foreground") do
            %w[One Two Three Four Five Six Seven Eight].each do |line|
              div { line }
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
