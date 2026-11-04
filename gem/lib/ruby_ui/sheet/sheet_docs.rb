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
              Button(variant: :outline) { "Open" }
            end
            SheetContent do
              SheetHeader do
                SheetTitle { "Edit profile" }
                SheetDescription { "Make changes to your profile here. Click save when you're done." }
              end
              SheetMiddle(class: "grid gap-6") do
                div(class: "grid gap-3") do
                  FormFieldLabel(for: "sheet-demo-name") { "Name" }
                  Input(id: "sheet-demo-name", value: "Joel Drapper")
                end
                div(class: "grid gap-3") do
                  FormFieldLabel(for: "sheet-demo-email") { "Email" }
                  Input(id: "sheet-demo-email", value: "joel@drapper.me")
                end
              end
              SheetFooter do
                Button(type: "submit") { "Save changes" }
                Button(variant: :outline, data: { action: 'click->ruby-ui--sheet#dismiss' }) { "Close" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Side", description: "Use the side keyword to choose the edge of the screen the sheet slides in from: :top, :right (default), :bottom or :left.", context: self) do
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
                    p(class: 'text-sm text-muted-foreground') { "The sheet slides in from the \#{side}." }
                  end
                  SheetFooter do
                    Button(type: "submit") { "Save changes" }
                    Button(variant: :outline, data: { action: 'click->ruby-ui--sheet#dismiss' }) { "Cancel" }
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "No close button", description: "Pass show_close_button: false to hide the close button in the corner. Esc and a click outside still close the sheet.", context: self) do
        <<~RUBY
          Sheet do
            SheetTrigger do
              Button(variant: :outline) { "Open Sheet" }
            end
            SheetContent(show_close_button: false) do
              SheetHeader do
                SheetTitle { "No close button" }
                SheetDescription { "This sheet doesn't have a close button in the top-right corner. Press Esc or click outside to close it." }
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
