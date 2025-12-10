# frozen_string_literal: true

class Views::Docs::Carousel < Views::Base
  def view_template
    component = "Carousel"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Carousel", description: "A carousel with motion and swipe built using Embla.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          Carousel(options: {loop:false}, class: "w-full max-w-xs") do
            CarouselContent do
              5.times do |index|
                CarouselItem do
                  div(class: "p-1") do
                    Card do
                      CardContent(class: "flex aspect-square items-center justify-center p-6") do
                        span(class: "text-4xl font-semibold") { index + 1 }
                      end
                    end
                  end
                end
              end
            end
            CarouselPrevious()
            CarouselNext()
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Sizes", context: self) do
        <<~RUBY
          Carousel(class: "w-full max-w-sm") do
            CarouselContent do
              5.times do |index|
                CarouselItem(class: "md:basis-1/2 lg:basis-1/3") do
                  div(class: "p-1") do
                    Card do
                      CardContent(class: "flex aspect-square items-center justify-center p-6") do
                        span(class: "text-3xl font-semibold") { index + 1 }
                      end
                    end
                  end
                end
              end
            end
            CarouselPrevious()
            CarouselNext()
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Spacing", context: self) do
        <<~RUBY
          Carousel(class: "w-full max-w-sm") do
            CarouselContent(class: "-ml-1") do
              5.times do |index|
                CarouselItem(class: "pl-1 md:basis-1/2 lg:basis-1/3") do
                  div(class: "p-1") do
                    Card do
                      CardContent(class: "flex aspect-square items-center justify-center p-6") do
                        span(class: "text-2xl font-semibold") { index + 1 }
                      end
                    end
                  end
                end
              end
            end
            CarouselPrevious()
            CarouselNext()
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Orientation", context: self) do
        <<~RUBY
          Carousel(orientation: :vertical, options: {align: "start"}, class: "w-full max-w-xs") do
            CarouselContent(class: "-mt-1 h-[200px]") do
              5.times do |index|
                CarouselItem(class: "pt-1 md:basis-1/2") do
                  div(class: "p-1") do
                    Card do
                      CardContent(class: "flex items-center justify-center p-6") do
                        span(class: "text-3xl font-semibold") { index + 1 }
                      end
                    end
                  end
                end
              end
            end
            CarouselPrevious()
            CarouselNext()
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
