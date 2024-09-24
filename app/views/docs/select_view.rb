# frozen_string_literal: true

class Docs::SelectView < ApplicationView
  def view_template
    component = "Select"

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

      render Docs::ComponentsTable.new(component_references(component, Docs::VisualCodeExample.collected_code), component_files(component))
    end
  end
end
