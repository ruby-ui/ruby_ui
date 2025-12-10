# frozen_string_literal: true

class Views::Docs::Sheet < Views::Base
  def view_template
    component = "Sheet"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Sheet", description: "Extends the Sheet component to display content that complements the main content of the screen.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
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

              SheetMiddle do
                label { "Name" }
                Input(placeholder: "Joel Drapper") { "Joel Drapper" }
                label { "Email" }
                Input(placeholder: "joel@drapper.me")
              end
              SheetFooter do
                Button(variant: :outline, data: { action: 'click->ruby-ui--sheet-content#close' }) { "Cancel" }
                Button(type: "submit") { "Save" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Side", description: "Use the side property to indicate the edge of the screen where the component will appear.", context: self) do
        <<~RUBY
          div(class: 'grid grid-cols-2 gap-4') do
            # -- TOP --
            Sheet do
              SheetTrigger do
                Button(variant: :outline, class: 'w-full justify-center') { :top }
              end
              SheetContent(side: :top, class: ("sm:max-w-sm" if [:left, :right].include?(:top))) do
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
                    Button(variant: :outline, data: { action: 'click->ruby-ui--sheet-content#close' }) { "Cancel" }
                    Button(type: "submit") { "Save" }
                  end
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
