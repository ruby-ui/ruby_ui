# frozen_string_literal: true

class Docs::SheetView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-8") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Sheet" }
        render Typography::P.new { "Extends the Sheet component to display content that complements the main content of the screen." }
      end

      render Docs::VisualCodeExample.new(title: "Default") do
        render Sheet.new do
          render SheetTrigger.new do
            render Button.new(variant: :outline) { "Open Sheet" }
          end
          render SheetContent.new do
            render SheetHeader.new do
              render SheetTitle.new { "Edit profile" }
              render SheetDescription.new { "Make changes to your profile here. Click save when you're done." }
            end
            render SheetMiddle.new do
              render AspectRatio.new(aspect_ratio: "16/9") do
                img(
                  alt: "Placeholder",
                  loading: "lazy",
                  class: "rounded-md object-cover",
                  style:
                    "position:absolute;height:100%;width:100%;inset:0;color:transparent",
                  src:
                    "https://images.unsplash.com/photo-1667373509687-4c4574541218?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=3132&q=80"
                )
              end
            end
            render SheetFooter.new do
              render Button.new(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
              render Button.new { "Save" }
            end
          end
        end
      end

      render Docs::VisualCodeExample.new(title: "Side", description: 'Use the side property to <SheetContent /> to indicate the edge of the screen where the component will appear. The values can be top, right, bottom or left.') do
        sides = %i[top right bottom left]
        
        div(class: 'grid grid-cols-2 gap-4') do
          sides.each do |side|
            render Sheet.new do
              render SheetTrigger.new do
                render Button.new(variant: :outline, class: 'w-full') { side }
              end
              render SheetContent.new(side: side) do
                render SheetHeader.new do
                  render SheetTitle.new { "Edit profile" }
                  render SheetDescription.new { "Make changes to your profile here. Click save when you're done." }
                end
                render Form.new do
                  render SheetMiddle.new do
                    render FormSpacer.new do
                      render FormItem.new do
                        render Label.new { "Name" }
                        render Input.new(placeholder: "Joel Drapper") { "Joel Drapper" }
                      end
                      render FormItem.new do
                        render Label.new { "Email" }
                        render Input.new(placeholder: "joeldrapper@mail.com")
                      end
                    end
                  end
                  render SheetFooter.new do
                    render Button.new(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
                    render Button.new(type: "submit") { "Save" }
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
