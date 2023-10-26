# frozen_string_literal: true

class Docs::SheetView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render Docs::PremiumBadge.new
        render Typography::H1.new { "Sheet" }
        render Typography::P.new { "Extends the Sheet component to display content that complements the main content of the screen." }
      end

      render Docs::VisualCodeExample.new(title: "Example", locked: true, context: self) do
        <<~RUBY
          render Sheet.new do
            render SheetTrigger.new do
              render Button.new(variant: :outline) { "Open Sheet" }
            end
            render SheetContent.new(class: 'sm:max-w-sm') do
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
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Side", description: 'Use the side property to indicate the edge of the screen where the component will appear.', locked: true, context: self) do        
        <<~RUBY
          div(class: 'grid grid-cols-2 gap-4') do
            # -- TOP --
            render Sheet.new do
              render SheetTrigger.new do
                render Button.new(variant: :outline, class: 'w-full justify-center') { :top }
              end
              render SheetContent.new(side: :top, class: tokens(-> { [:left, :right].include?(:top) } => "sm:max-w-sm")) do
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

            # -- BOTTOM --
            render Sheet.new do
              render SheetTrigger.new do
                render Button.new(variant: :outline, class: 'w-full justify-center') { :bottom }
              end
              render SheetContent.new(side: :bottom, class: tokens(-> { [:left, :right].include?(:bottom) } => "sm:max-w-sm")) do
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

            # -- LEFT --
            render Sheet.new do
              render SheetTrigger.new do
                render Button.new(variant: :outline, class: 'w-full justify-center') { :left }
              end
              render SheetContent.new(side: :left, class: tokens(-> { [:left, :right].include?(:left) } => "sm:max-w-sm")) do
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

            # -- RIGHT --
            render Sheet.new do
              render SheetTrigger.new do
                render Button.new(variant: :outline, class: 'w-full justify-center') { :right }
              end
              render SheetContent.new(side: :right, class: tokens(-> { [:left, :right].include?(:right) } => "sm:max-w-sm")) do
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
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Custom size", locked: true, context: self) do
        <<~RUBY
          render Sheet.new do
            render SheetTrigger.new do
              render Button.new(variant: :outline) { "Open Sheet" }
            end
            render SheetContent.new(class: 'w-3/4') do
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
        RUBY
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
