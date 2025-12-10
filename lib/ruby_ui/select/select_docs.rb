# frozen_string_literal: true

class Views::Docs::Select < Views::Base
  def view_template
    component = "Select"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Select", description: "Displays a list of options for the user to pick from—triggered by a button.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Select (Deconstructed)", context: self) do
        <<~RUBY
          Select(class: "w-56") do
            SelectInput(value: "apple", id: "select-a-fruit")

            SelectTrigger do
              SelectValue(placeholder: "Select a fruit", id: "select-a-fruit") { "Apple" }
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
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Pre-selected Item", context: self) do
        <<~RUBY
          Select(class: "w-56") do
            SelectInput(value: "banana", id: "select-preselected-fruit")

            SelectTrigger do
              SelectValue(placeholder: "Select a fruit", id: "select-preselected-fruit") { "Banana" }
            end

            SelectContent(outlet_id: "select-preselected-fruit") do
              SelectGroup do
                SelectLabel { "Fruits" }
                SelectItem(value: "apple") { "Apple" }
                SelectItem(value: "orange") { "Orange" }
                SelectItem(value: "banana") { "Banana" }
                SelectItem(value: "watermelon") { "Watermelon" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          Select(class: "w-56") do
            SelectInput(value: "apple", id: "select-a-fruit")

            SelectTrigger(disabled: true) do
              SelectValue(placeholder: "Select a fruit", id: "select-a-fruit") { "Apple" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Data Disabled", context: self) do
        <<~RUBY
          Select(class: "w-56") do
            SelectInput(value: "apple", id: "select-a-fruit")

            SelectTrigger do
              SelectValue(placeholder: "Select a fruit", id: "select-a-fruit") { "Apple" }
            end

            SelectContent(outlet_id: "select-a-fruit") do
              SelectGroup do
                SelectLabel { "Fruits" }
                SelectItem(data: {disabled: true}, value: "apple") { "Apple" }
                SelectItem(value: "orange") { "Orange" }
                SelectItem(value: "banana") { "Banana" }
                SelectItem(data: {disabled: true}, value: "watermelon") { "Watermelon" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Aria Disabled Trigger", context: self) do
        <<~RUBY
          Select(class: "w-56") do
            SelectInput(value: "apple", id: "select-a-fruit")

            SelectTrigger(aria: {disabled: "true"}) do
              SelectValue(placeholder: "Select a fruit", id: "select-a-fruit") { "Apple" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Aria Disabled Item", context: self) do
        <<~RUBY
          Select(class: "w-56") do
            SelectInput(value: "apple", id: "select-a-fruit")

            SelectTrigger do
              SelectValue(placeholder: "Select a fruit", id: "select-a-fruit") { "Apple" }
            end

            SelectContent(outlet_id: "select-a-fruit") do
              SelectGroup do
                SelectLabel { "Fruits" }
                SelectItem(aria: {disabled: "true"}, value: "apple") { "Apple" }
                SelectItem(value: "orange") { "Orange" }
                SelectItem(value: "banana") { "Banana" }
                SelectItem(aria: {disabled: "true"}, value: "watermelon") { "Watermelon" }
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
