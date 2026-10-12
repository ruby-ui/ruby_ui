# frozen_string_literal: true

class Views::Docs::Sheet < Views::Base
  def view_template
    component = "Sheet"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Sheet", description: "Extends the Dialog component to display content that complements the main content of the screen.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          Sheet do
            SheetTrigger do
              Button(variant: :outline) { "Open Sheet" }
            end
            SheetContent do
              SheetHeader do
                SheetTitle { "Edit profile" }
                SheetDescription { "Make changes to your profile here. Click save when you're done." }
              end

              SheetMiddle do
                label { "Name" }
                Input(placeholder: "Joel Drapper") { "Joel Drapper" }
                label { "Email" }
                Input(placeholder: "joel@drapper.me")
              end
              SheetFooter do
                SheetClose do
                  Button(variant: :outline) { "Cancel" }
                end
                Button { "Save" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Side", description: "Use the side property to indicate the edge of the screen where the component will appear.", context: self) do
        <<~RUBY
          div(class: 'flex flex-wrap gap-2') do
            [:top, :right, :bottom, :left].each do |side|
              Sheet do
                SheetTrigger do
                  Button(variant: :outline, class: 'capitalize') { side.to_s }
                end
                SheetContent(side: side) do
                  SheetHeader do
                    SheetTitle { "Edit profile" }
                    SheetDescription { "Make changes to your profile here. Click save when you're done." }
                  end
                  SheetMiddle do
                    label { "Name" }
                    Input(placeholder: "Joel Drapper") { "Joel Drapper" }
                  end
                  SheetFooter do
                    SheetClose do
                      Button(variant: :outline) { "Cancel" }
                    end
                    Button { "Save" }
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "No close button", description: "Pass show_close_button: false to hide the close button in the corner. The sheet still closes on Escape or a click outside.", context: self) do
        <<~RUBY
          Sheet do
            SheetTrigger do
              Button(variant: :outline) { "Open Sheet" }
            end
            SheetContent(show_close_button: false) do
              SheetHeader do
                SheetTitle { "No close button" }
                SheetDescription { "This sheet has no close button in the corner. Press Escape or click outside to close it." }
              end
              SheetFooter do
                SheetClose do
                  Button(variant: :outline) { "Close" }
                end
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
