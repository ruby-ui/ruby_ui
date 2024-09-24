# frozen_string_literal: true

class Docs::DialogView < ApplicationView
  def view_template
    component = "Dialog"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Dialog", description: "A window overlaid on either the primary window or another dialog window, rendering the content underneath inert.")

      TypographyH2 { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          Dialog do
            DialogTrigger do
              Button { "Open Dialog" }
            end
            DialogContent do
              DialogHeader do
                DialogTitle { "RBUI to the rescue" }
                DialogDescription { "RBUI helps you build accessible standard compliant web apps with ease" }
              end
              DialogMiddle do
                AspectRatio(aspect_ratio: "16/9", class: 'rounded-md overflow-hidden border') do
                  img(
                    alt: "Placeholder",
                    loading: "lazy",
                    src:
                      helpers.image_path("pattern.jpg")
                  )
                end
              end
              DialogFooter do
                Button(variant: :outline, data: { action: 'click->rbui--dialog#dismiss' }) { "Cancel" }
                Button { "Save" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Size", description: "Applicable for wider screens", context: self) do
        <<~RUBY
          div(class: 'flex flex-wrap justify-center gap-2') do
            Dialog do
              DialogTrigger do
                Button { "Small Dialog" }
              end
              DialogContent(size: :sm) do
                DialogHeader do
                  DialogTitle { "RBUI to the rescue" }
                  DialogDescription { "RBUI helps you build accessible standard compliant web apps with ease" }
                end
                DialogMiddle do
                  AspectRatio(aspect_ratio: "16/9", class: 'rounded-md overflow-hidden border') do
                    img(
                      alt: "Placeholder",
                      loading: "lazy",
                      src:
                        helpers.image_path("pattern.jpg")
                    )
                  end
                end
                DialogFooter do
                  Button(variant: :outline, data: { action: 'click->rbui--dialog#dismiss' }) { "Cancel" }
                  Button { "Save" }
                end
              end
            end

            Dialog do
              DialogTrigger do
                Button { "Large Dialog" }
              end
              DialogContent(size: :lg) do
                DialogHeader do
                  DialogTitle { "RBUI to the rescue" }
                  DialogDescription { "RBUI helps you build accessible standard compliant web apps with ease" }
                end
                DialogMiddle do
                  AspectRatio(aspect_ratio: "16/9", class: 'rounded-md overflow-hidden border') do
                    img(
                      alt: "Placeholder",
                      loading: "lazy",
                      src:
                        helpers.image_path("pattern.jpg")
                    )
                  end
                end
                DialogFooter do
                  Button(variant: :outline, data: { action: 'click->rbui--dialog#dismiss' }) { "Cancel" }
                  Button { "Save" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::ComponentsTable.new(component_references(component, Docs::VisualCodeExample.collected_code), component_files(component))
    end
  end
end
