# frozen_string_literal: true

class Docs::DialogView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-8") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Dialog" }
        render Typography::P.new { "A window overlaid on either the primary window or another dialog window, rendering the content underneath inert." }
      end

      render Docs::VisualCodeExample.new(title: "Default") do
        render Dialog.new do
          render DialogTrigger.new do
            render Button.new { "Open Dialog" }
          end
          render DialogContent.new do
            render DialogHeader.new do
              render DialogTitle.new { "Edit profile" }
              render DialogDescription.new { "Make changes to your profile here. Click save when you're done." }
            end
            render DialogMiddle.new do
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
            render DialogFooter.new do
              render Button.new(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
              render Button.new { "Save" }
            end
          end
        end
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
