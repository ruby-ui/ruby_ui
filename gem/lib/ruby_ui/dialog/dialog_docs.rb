# frozen_string_literal: true

class Views::Docs::Dialog < Views::Base
  def view_template
    component = "Dialog"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Dialog", description: "A window overlaid on either the primary window or another dialog window, rendering the content underneath inert.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          Dialog do
            DialogTrigger do
              Button(variant: :outline) { "Open Dialog" }
            end
            DialogContent do
              DialogHeader do
                DialogTitle { "RubyUI to the rescue" }
                DialogDescription { "RubyUI helps you build accessible standard compliant web apps with ease" }
              end
              DialogMiddle do
                AspectRatio(aspect_ratio: "16/9", class: 'rounded-md overflow-hidden border') do
                  img(
                    alt: "Placeholder",
                    loading: "lazy",
                    src: image_path("pattern.jpg")
                  )
                end
              end
              DialogFooter do
                Button(variant: :outline, data: { action: 'click->ruby-ui--dialog#dismiss' }) { "Cancel" }
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
                Button(variant: :outline) { "Small Dialog" }
              end
              DialogContent(size: :sm) do
                DialogHeader do
                  DialogTitle { "RubyUI to the rescue" }
                  DialogDescription { "RubyUI helps you build accessible standard compliant web apps with ease" }
                end
                DialogMiddle do
                  AspectRatio(aspect_ratio: "16/9", class: 'rounded-md overflow-hidden border') do
                    img(
                      alt: "Placeholder",
                      loading: "lazy",
                      src: image_path("pattern.jpg")
                    )
                  end
                end
                DialogFooter do
                  Button(variant: :outline, data: { action: 'click->ruby-ui--dialog#dismiss' }) { "Cancel" }
                  Button { "Save" }
                end
              end
            end

            Dialog do
              DialogTrigger do
                Button(variant: :outline) { "Large Dialog" }
              end
              DialogContent(size: :lg) do
                DialogHeader do
                  DialogTitle { "RubyUI to the rescue" }
                  DialogDescription { "RubyUI helps you build accessible standard compliant web apps with ease" }
                end
                DialogMiddle do
                  AspectRatio(aspect_ratio: "16/9", class: 'rounded-md overflow-hidden border') do
                    img(
                      alt: "Placeholder",
                      loading: "lazy",
                      src: image_path("pattern.jpg")
                    )
                  end
                end
                DialogFooter do
                  Button(variant: :outline, data: { action: 'click->ruby-ui--dialog#dismiss' }) { "Cancel" }
                  Button { "Save" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "No close button", description: "Hide the corner close button and provide your own close action.", context: self) do
        <<~RUBY
          Dialog do
            DialogTrigger do
              Button(variant: :outline) { "No Close Button" }
            end
            DialogContent(show_close_button: false) do
              DialogHeader do
                DialogTitle { "No close button" }
                DialogDescription { "This dialog has no close button in the corner. Escape and a click outside still close it." }
              end
              DialogFooter do
                Button(variant: :outline, data: { action: 'click->ruby-ui--dialog#dismiss' }) { "Close" }
              end
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
