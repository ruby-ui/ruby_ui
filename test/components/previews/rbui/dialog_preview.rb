# frozen_string_literal: true

module Rbui
  class DialogPreview < Lookbook::Preview
    # Default Dialog
    # ---------------
    # @param size [Symbol] select { choices: [sm, md, lg, xl, full] }
    def default(size: :md)
      render(TestView.new) do
        Dialog do
          DialogTrigger { Button { "Open Dialog" } }
          DialogContent(size:) do
            DialogHeader do
              DialogTitle { "RBUI to the rescue" }
              DialogDescription do
                "RBUI helps you build accessible standard compliant web apps with ease"
              end
            end
            DialogMiddle do
              AspectRatio(aspect_ratio: "16/9", class: "rounded-md overflow-hidden border") do
                img(
                  alt: "Placeholder",
                  loading: "lazy",
                  src: helpers.image_path("pattern.jpg")
                )
              end
            end
            DialogFooter do
              Button(variant: :outline, data: {action: "click->dismissable#dismiss"}) { "Cancel" }

              Button { "Save" }
            end
          end
        end
      end
    end
  end
end
