# frozen_string_literal: true

class Docs::SheetView < ApplicationView
  def initialize
    @premium = true
  end

  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Sheet", description: "Extends the Sheet component to display content that complements the main content of the screen.", premium: @premium)

      render PhlexUI::Typography::H2.new { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self, premium: @premium) do
        <<~RUBY
          render PhlexUI::Sheet.new do
            render PhlexUI::Sheet::Trigger.new do
              render PhlexUI::Button.new(variant: :outline) { "Open Sheet" }
            end
            render PhlexUI::Sheet::Content.new(class: 'sm:max-w-sm') do
              render PhlexUI::Sheet::Header.new do
                render PhlexUI::Sheet::Title.new { "Edit profile" }
                render PhlexUI::Sheet::Description.new { "Make changes to your profile here. Click save when you're done." }
              end
              render PhlexUI::Form.new do
                render PhlexUI::Sheet::Middle.new do
                  render PhlexUI::Form::Spacer.new do
                    render PhlexUI::Form::Item.new do
                      render PhlexUI::Label.new { "Name" }
                      render PhlexUI::Input.new(placeholder: "Joel Drapper") { "Joel Drapper" }
                    end
                    render PhlexUI::Form::Item.new do
                      render PhlexUI::Label.new { "Email" }
                      render PhlexUI::Input.new(placeholder: "joel@drapper.me")
                    end
                  end
                end
                render PhlexUI::Sheet::Footer.new do
                  render PhlexUI::Button.new(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
                  render PhlexUI::Button.new(type: "submit") { "Save" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Side", description: "Use the side property to indicate the edge of the screen where the component will appear.", context: self, premium: @premium) do
        <<~RUBY
          div(class: 'grid grid-cols-2 gap-4') do
            # -- TOP --
            render PhlexUI::Sheet.new do
              render PhlexUI::Sheet::Trigger.new do
                render PhlexUI::Button.new(variant: :outline, class: 'w-full justify-center') { :top }
              end
              render PhlexUI::Sheet::Content.new(side: :top, class: tokens(-> { [:left, :right].include?(:top) } => "sm:max-w-sm")) do
                render PhlexUI::Sheet::Header.new do
                  render PhlexUI::Sheet::Title.new { "Edit profile" }
                  render PhlexUI::Sheet::Description.new { "Make changes to your profile here. Click save when you're done." }
                end
                render PhlexUI::Form.new do
                  render PhlexUI::Sheet::Middle.new do
                    render PhlexUI::Form::Spacer.new do
                      render PhlexUI::Form::Item.new do
                        render PhlexUI::Label.new { "Name" }
                        render PhlexUI::Input.new(placeholder: "Joel Drapper") { "Joel Drapper" }
                      end
                      render PhlexUI::Form::Item.new do
                        render PhlexUI::Label.new { "Email" }
                        render PhlexUI::Input.new(placeholder: "joel@drapper.me")
                      end
                    end
                  end
                  render PhlexUI::Sheet::Footer.new do
                    render PhlexUI::Button.new(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
                    render PhlexUI::Button.new(type: "submit") { "Save" }
                  end
                end
              end
            end

            # -- BOTTOM --
            render PhlexUI::Sheet.new do
              render PhlexUI::Sheet::Trigger.new do
                render PhlexUI::Button.new(variant: :outline, class: 'w-full justify-center') { :bottom }
              end
              render PhlexUI::Sheet::Content.new(side: :bottom, class: tokens(-> { [:left, :right].include?(:bottom) } => "sm:max-w-sm")) do
                render PhlexUI::Sheet::Header.new do
                  render PhlexUI::Sheet::Title.new { "Edit profile" }
                  render PhlexUI::Sheet::Description.new { "Make changes to your profile here. Click save when you're done." }
                end
                render PhlexUI::Form.new do
                  render PhlexUI::Sheet::Middle.new do
                    render PhlexUI::Form::Spacer.new do
                      render PhlexUI::Form::Item.new do
                        render PhlexUI::Label.new { "Name" }
                        render PhlexUI::Input.new(placeholder: "Joel Drapper") { "Joel Drapper" }
                      end
                      render PhlexUI::Form::Item.new do
                        render PhlexUI::Label.new { "Email" }
                        render PhlexUI::Input.new(placeholder: "joel@drapper.me")
                      end
                    end
                  end
                  render PhlexUI::Sheet::Footer.new do
                    render PhlexUI::Button.new(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
                    render PhlexUI::Button.new(type: "submit") { "Save" }
                  end
                end
              end
            end

            # -- LEFT --
            render PhlexUI::Sheet.new do
              render PhlexUI::Sheet::Trigger.new do
                render PhlexUI::Button.new(variant: :outline, class: 'w-full justify-center') { :left }
              end
              render PhlexUI::Sheet::Content.new(side: :left, class: tokens(-> { [:left, :right].include?(:left) } => "sm:max-w-sm")) do
                render PhlexUI::Sheet::Header.new do
                  render PhlexUI::Sheet::Title.new { "Edit profile" }
                  render PhlexUI::Sheet::Description.new { "Make changes to your profile here. Click save when you're done." }
                end
                render PhlexUI::Form.new do
                  render PhlexUI::Sheet::Middle.new do
                    render PhlexUI::Form::Spacer.new do
                      render PhlexUI::Form::Item.new do
                        render PhlexUI::Label.new { "Name" }
                        render PhlexUI::Input.new(placeholder: "Joel Drapper") { "Joel Drapper" }
                      end
                      render PhlexUI::Form::Item.new do
                        render PhlexUI::Label.new { "Email" }
                        render PhlexUI::Input.new(placeholder: "joel@drapper.me")
                      end
                    end
                  end
                  render PhlexUI::Sheet::Footer.new do
                    render PhlexUI::Button.new(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
                    render PhlexUI::Button.new(type: "submit") { "Save" }
                  end
                end
              end
            end

            # -- RIGHT --
            render PhlexUI::Sheet.new do
              render PhlexUI::Sheet::Trigger.new do
                render PhlexUI::Button.new(variant: :outline, class: 'w-full justify-center') { :right }
              end
              render PhlexUI::Sheet::Content.new(side: :right, class: tokens(-> { [:left, :right].include?(:right) } => "sm:max-w-sm")) do
                render PhlexUI::Sheet::Header.new do
                  render PhlexUI::Sheet::Title.new { "Edit profile" }
                  render PhlexUI::Sheet::Description.new { "Make changes to your profile here. Click save when you're done." }
                end
                render PhlexUI::Form.new do
                  render PhlexUI::Sheet::Middle.new do
                    render PhlexUI::Form::Spacer.new do
                      render PhlexUI::Form::Item.new do
                        render PhlexUI::Label.new { "Name" }
                        render PhlexUI::Input.new(placeholder: "Joel Drapper") { "Joel Drapper" }
                      end
                      render PhlexUI::Form::Item.new do
                        render PhlexUI::Label.new { "Email" }
                        render PhlexUI::Input.new(placeholder: "joel@drapper.me")
                      end
                    end
                  end
                  render PhlexUI::Sheet::Footer.new do
                    render PhlexUI::Button.new(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
                    render PhlexUI::Button.new(type: "submit") { "Save" }
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Custom size", context: self, premium: @premium) do
        <<~RUBY
          render PhlexUI::Sheet.new do
            render PhlexUI::Sheet::Trigger.new do
              render PhlexUI::Button.new(variant: :outline) { "Open Sheet" }
            end
            render PhlexUI::Sheet::Content.new(class: 'w-3/4') do
              render PhlexUI::Sheet::Header.new do
                render PhlexUI::Sheet::Title.new { "Edit profile" }
                render PhlexUI::Sheet::Description.new { "Make changes to your profile here. Click save when you're done." }
              end
              render PhlexUI::Form.new do
                render PhlexUI::Sheet::Middle.new do
                  render PhlexUI::Form::Spacer.new do
                    render PhlexUI::Form::Item.new do
                      render PhlexUI::Label.new { "Name" }
                      render PhlexUI::Input.new(placeholder: "Joel Drapper") { "Joel Drapper" }
                    end
                    render PhlexUI::Form::Item.new do
                      render PhlexUI::Label.new { "Email" }
                      render PhlexUI::Input.new(placeholder: "joel@drapper.me")
                    end
                  end
                end
                render PhlexUI::Sheet::Footer.new do
                  render PhlexUI::Button.new(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
                  render PhlexUI::Button.new(type: "submit") { "Save" }
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
      Docs::ComponentStruct.new(name: "SheetController", source: "https://github.com/PhlexUI/phlex_ui_stimulus_pro/blob/main/controllers/sheet_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "PhlexUI::Sheet", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/sheet.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Sheet::Trigger", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/sheet/trigger.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Sheet::Content", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/sheet/content.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Sheet::Header", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/sheet/header.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Sheet::Title", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/sheet/title.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Sheet::Description", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/sheet/description.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Sheet::Middle", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/sheet/middle.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Sheet::Footer", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/sheet/footer.rb", built_using: :phlex)
    ]
  end
end
