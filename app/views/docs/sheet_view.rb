# frozen_string_literal: true

class Docs::SheetView < ApplicationView
  def initialize
    @premium = true
  end

  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Sheet", description: "Extends the Sheet component to display content that complements the main content of the screen.", premium: @premium)

      TypographyH2 { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self, premium: @premium) do
        <<~RUBY
          Sheet do
            SheetTrigger do
              Button(variant: :outline) { "Open Sheet" }
            end
            SheetContent(class: 'sm:max-w-sm') do
              SheetHeader do
                SheetTitle { "Edit profile" }
                SheetDescription { "Make changes to your profile here. Click save when you're done." }
              end
              Form do
                SheetMiddle do
                  FormSpacer do
                    FormItem do
                      Label { "Name" }
                      Input(placeholder: "Joel Drapper") { "Joel Drapper" }
                    end
                    FormItem do
                      Label { "Email" }
                      Input(placeholder: "joel@drapper.me")
                    end
                  end
                end
                SheetFooter do
                  Button(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
                  Button(type: "submit") { "Save" }
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
            Sheet do
              SheetTrigger do
                Button(variant: :outline, class: 'w-full justify-center') { :top }
              end
              SheetContent(side: :top, class: tokens(-> { [:left, :right].include?(:top) } => "sm:max-w-sm")) do
                SheetHeader do
                  SheetTitle { "Edit profile" }
                  SheetDescription { "Make changes to your profile here. Click save when you're done." }
                end
                Form do
                  SheetMiddle do
                    FormSpacer do
                      FormItem do
                        Label { "Name" }
                        Input(placeholder: "Joel Drapper") { "Joel Drapper" }
                      end
                      FormItem do
                        Label { "Email" }
                        Input(placeholder: "joel@drapper.me")
                      end
                    end
                  end
                  SheetFooter do
                    Button(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
                    Button(type: "submit") { "Save" }
                  end
                end
              end
            end

            # -- BOTTOM --
            Sheet do
              SheetTrigger do
                Button(variant: :outline, class: 'w-full justify-center') { :bottom }
              end
              SheetContent(side: :bottom, class: tokens(-> { [:left, :right].include?(:bottom) } => "sm:max-w-sm")) do
                SheetHeader do
                  SheetTitle { "Edit profile" }
                  SheetDescription { "Make changes to your profile here. Click save when you're done." }
                end
                Form do
                  SheetMiddle do
                    FormSpacer do
                      FormItem do
                        Label { "Name" }
                        Input(placeholder: "Joel Drapper") { "Joel Drapper" }
                      end
                      FormItem do
                        Label { "Email" }
                        Input(placeholder: "joel@drapper.me")
                      end
                    end
                  end
                  SheetFooter do
                    Button(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
                    Button(type: "submit") { "Save" }
                  end
                end
              end
            end

            # -- LEFT --
            Sheet do
              SheetTrigger do
                Button(variant: :outline, class: 'w-full justify-center') { :left }
              end
              SheetContent(side: :left, class: tokens(-> { [:left, :right].include?(:left) } => "sm:max-w-sm")) do
                SheetHeader do
                  SheetTitle { "Edit profile" }
                  SheetDescription { "Make changes to your profile here. Click save when you're done." }
                end
                Form do
                  SheetMiddle do
                    FormSpacer do
                      FormItem do
                        Label { "Name" }
                        Input(placeholder: "Joel Drapper") { "Joel Drapper" }
                      end
                      FormItem do
                        Label { "Email" }
                        Input(placeholder: "joel@drapper.me")
                      end
                    end
                  end
                  SheetFooter do
                    Button(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
                    Button(type: "submit") { "Save" }
                  end
                end
              end
            end

            # -- RIGHT --
            Sheet do
              SheetTrigger do
                Button(variant: :outline, class: 'w-full justify-center') { :right }
              end
              SheetContent(side: :right, class: tokens(-> { [:left, :right].include?(:right) } => "sm:max-w-sm")) do
                SheetHeader do
                  SheetTitle { "Edit profile" }
                  SheetDescription { "Make changes to your profile here. Click save when you're done." }
                end
                Form do
                  SheetMiddle do
                    FormSpacer do
                      FormItem do
                        Label { "Name" }
                        Input(placeholder: "Joel Drapper") { "Joel Drapper" }
                      end
                      FormItem do
                        Label { "Email" }
                        Input(placeholder: "joel@drapper.me")
                      end
                    end
                  end
                  SheetFooter do
                    Button(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
                    Button(type: "submit") { "Save" }
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Custom size", context: self, premium: @premium) do
        <<~RUBY
          Sheet do
            SheetTrigger do
              Button(variant: :outline) { "Open Sheet" }
            end
            SheetContent(class: 'w-3/4') do
              SheetHeader do
                SheetTitle { "Edit profile" }
                SheetDescription { "Make changes to your profile here. Click save when you're done." }
              end
              Form do
                SheetMiddle do
                  FormSpacer do
                    FormItem do
                      Label { "Name" }
                      Input(placeholder: "Joel Drapper") { "Joel Drapper" }
                    end
                    FormItem do
                      Label { "Email" }
                      Input(placeholder: "joel@drapper.me")
                    end
                  end
                end
                SheetFooter do
                  Button(variant: :outline, data: { action: 'click->dismissable#dismiss' }) { "Cancel" }
                  Button(type: "submit") { "Save" }
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
      Docs::ComponentStruct.new(name: "Sheet", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/sheet.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "SheetTrigger", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/sheet/trigger.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "SheetContent", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/sheet/content.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "SheetHeader", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/sheet/header.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "SheetTitle", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/sheet/title.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "SheetDescription", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/sheet/description.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "SheetMiddle", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/sheet/middle.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "SheetFooter", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/sheet/footer.rb", built_using: :phlex)
    ]
  end
end
