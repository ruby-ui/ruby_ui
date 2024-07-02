# frozen_string_literal: true

class Docs::SelectView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Select", description: "Displays a list of options for the user to pick from—triggered by a button.")

      TypographyH2 { "Usage" }

      render Docs::VisualCodeExample.new(title: "Select (Deconstructed)", context: self) do
        <<~RUBY
          div(class: 'w-56 flex items-center justify-center') do
            Select do
              SelectInput(value: "apple", id: "select-a-fruit")
              SelectTrigger do
                SelectValue(placeholder: 'Select a fruit', id: "select-a-fruit") { "Apple" }
              end
              SelectContent(outlet_id: "select-a-fruit") do
                SelectGroup do
                  SelectLabel { "Fruits" }
                  SelectItem(value: "apple") { "Apple" }
                  SelectItem(value: "orange") { "Orange" }
                  SelectItem(value: "banana") { "Banana" }
                  SelectItem(value: "watermelon") { "Watermelon" }
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
      Docs::ComponentStruct.new(name: "SelectController", source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/select_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "TextController", source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/text_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "InputController", source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/input_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "Select", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/select.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "SelectTrigger", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/select/trigger.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "SelectContent", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/select/content.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "SelectLabel", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/select/label.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "SelectItem", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/select/item.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "SelectGroup", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/select/group.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "SelectInput", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/select/input.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "SelectValue", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/select/value.rb", built_using: :phlex)
    ]
  end
end
