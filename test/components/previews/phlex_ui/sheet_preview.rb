# frozen_string_literal: true

module PhlexUi
  class SheetPreview < Lookbook::Preview
    # Default Sheet
    # ---------------
    # @param side [Symbol] select { choices: [top, right, bottom, left] }
    # @param size [String] select { choices: ["", "w-3/4", "w-1/2"] }
    def default(side: :top, size: "")
      render(TestView.new) do
        Sheet do
          SheetTrigger { Button(variant: :outline) { "Open Sheet" } }
          SheetContent(side:, class: size) do
            SheetHeader do
              SheetTitle { "Edit profile" }
              SheetDescription { "Make changes to your profile here. Click save when you're done." }
            end

            Form do
              SheetMiddle do
                label { "Name" }
                Input(placeholder: "Joel Drapper") { "Joel Drapper" }

                label { "Email" }
                Input(placeholder: "joel@drapper.me")
              end

              SheetFooter do
                Button(variant: :outline, data: {action: "click->dismissable#dismiss"}) { "Cancel" }
                Button(type: "submit") { "Save" }
              end
            end
          end
        end
      end
    end
  end
end
