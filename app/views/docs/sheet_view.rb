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
          render SheetContent.new(class: 'sm:max-w-sm') do
            profile_form
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
              render SheetContent.new(side: side, class: tokens(-> { [:left, :right].include?(side) } => "sm:max-w-sm")) do
                profile_form
              end
            end
          end
        end
      end

      render Docs::VisualCodeExample.new(title: "Custom size") do
        render Sheet.new do
          render SheetTrigger.new do
            render Button.new(variant: :outline) { "Open Sheet" }
          end
          render SheetContent.new(class: 'w-3/4') do
            profile_form
          end
        end
      end
    end
  end

  def profile_form
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
            render Input.new(placeholder: "joel@drapper.me")
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
