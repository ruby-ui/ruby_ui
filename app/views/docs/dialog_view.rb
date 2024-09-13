# frozen_string_literal: true

class Docs::DialogView < ApplicationView
  def view_template
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

      render Docs::ComponentsTable.new(components)
    end
  end

  private

  def components
    [
      Docs::ComponentStruct.new(name: "DialogController", source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/dialog_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "DismissableController", source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/dismissable_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "Dialog", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dialog.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "Trigger", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dialog/trigger.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "Content", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dialog/content.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "Header", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dialog/header.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "Title", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dialog/title.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "Description", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dialog/description.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "Middle", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dialog/middle.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "Footer", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dialog/footer.rb", built_using: :phlex)
    ]
  end
end
