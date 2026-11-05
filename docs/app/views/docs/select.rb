# frozen_string_literal: true

class Views::Docs::Select < Views::Base
  def view_template
    component = "Select"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Select", description: "Displays a list of options for the user to pick from—triggered by a button.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Basic", context: self) do
        <<~RUBY
          Select do
            SelectInput(name: "fruit")

            SelectTrigger(class: "w-56") do
              SelectValue(placeholder: "Select a fruit")
            end

            SelectContent do
              SelectGroup do
                SelectLabel { "Fruits" }
                SelectItem(value: "apple") { "Apple" }
                SelectItem(value: "banana") { "Banana" }
                SelectItem(value: "blueberry") { "Blueberry" }
                SelectItem(value: "grapes") { "Grapes" }
                SelectItem(value: "pineapple") { "Pineapple" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Pre-selected Item", context: self) do
        <<~RUBY
          Select do
            SelectInput(name: "preselected_fruit", value: "banana")

            SelectTrigger(class: "w-56") do
              SelectValue(placeholder: "Select a fruit") { "Banana" }
            end

            SelectContent do
              SelectGroup do
                SelectLabel { "Fruits" }
                SelectItem(value: "apple") { "Apple" }
                SelectItem(value: "banana") { "Banana" }
                SelectItem(value: "blueberry") { "Blueberry" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Sizes", context: self) do
        <<~RUBY
          div(class: "flex flex-wrap items-center gap-2") do
            [:default, :sm].each do |size|
              Select do
                SelectInput()

                SelectTrigger(size: size, class: "w-40") do
                  SelectValue(placeholder: size == :sm ? "Small" : "Default")
                end

                SelectContent do
                  SelectGroup do
                    SelectItem(value: "apple") { "Apple" }
                    SelectItem(value: "banana") { "Banana" }
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Placement", context: self) do
        <<~RUBY
          Select do
            SelectInput(name: "placement_fruit")

            SelectTrigger(class: "w-56") do
              SelectValue(placeholder: "Opens above, aligned to the start")
            end

            SelectContent(side: :top, align: :start, side_offset: 8) do
              SelectGroup do
                SelectItem(value: "apple") { "Apple" }
                SelectItem(value: "banana") { "Banana" }
                SelectItem(value: "blueberry") { "Blueberry" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          Select do
            SelectInput(name: "disabled_fruit", value: "apple")

            SelectTrigger(disabled: true, class: "w-56") do
              SelectValue(placeholder: "Select a fruit") { "Apple" }
            end

            SelectContent do
              SelectGroup do
                SelectItem(value: "apple") { "Apple" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled Items", context: self) do
        <<~RUBY
          Select do
            SelectInput(name: "disabled_items_fruit")

            SelectTrigger(class: "w-56") do
              SelectValue(placeholder: "Select a fruit")
            end

            SelectContent do
              SelectGroup do
                SelectLabel { "Fruits" }
                SelectItem(value: "apple", disabled: true) { "Apple" }
                SelectItem(value: "banana") { "Banana" }
                SelectItem(value: "blueberry") { "Blueberry" }
                SelectItem(value: "grapes", disabled: true) { "Grapes" }
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
