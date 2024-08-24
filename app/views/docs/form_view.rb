# frozen_string_literal: true

class Docs::FormView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Form", description: "Building forms with built-in client-side validations.")

      TypographyH2 { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          Form(class: "w-2/3 space-y-6") do
            FormField do
              FormFieldLabel { "Default error" }
              Input(placeholder: "Joel Drapper", required: true, minlength: "3") { "Joel Drapper" }
              FormFieldHint()
              FormFieldError()
            end
            Button(type: "submit") { "Save" }
          end
        RUBY
      end

      render Docs::ComponentsTable.new(components)
    end
  end

  private

  def components
    [
      Docs::ComponentStruct.new(name: "DialogController", source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/dialog_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "DismissableController", source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/dismissable_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "Dialog", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dialog.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "Trigger", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dialog/trigger.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "Content", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dialog/content.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "Header", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dialog/header.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "Title", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dialog/title.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "Description", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dialog/description.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "Middle", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dialog/middle.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "Footer", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/dialog/footer.rb", built_using: :phlex)
    ]
  end
end
