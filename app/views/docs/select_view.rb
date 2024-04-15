# frozen_string_literal: true

class Docs::SelectView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Select", description: "Displays a list of options for the user to pick from—triggered by a button.")

      render PhlexUI::Typography::H2.new { "Usage" }

      render Docs::VisualCodeExample.new(title: "Select with object (With Builder)", description: "Change the Post object for your own", context: self) do
        <<~RUBY
          people = [
            ["John Doe", 1],
            ["Jane Doe", 2],
            ["Sam Smith", 3],
          ]

          div(class: 'w-56 flex items-center justify-center') do
            render PhlexUI::Select::Builder.new(Post.new(id: 1, person_id: 2), "person_id", collection: people, placeholder: 'Select a person')
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Select with text (With Builder)", context: self) do
        <<~RUBY
          people = [
            ["John Doe", 1],
            ["Jane Doe", 2],
            ["Sam Smith", 3],
          ]

          div(class: 'w-56 flex items-center justify-center') do
            render PhlexUI::Select::Builder.new("post", "person_id", collection: people, placeholder: 'Select a person')
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Select (Deconstructed)", context: self) do
        <<~RUBY
          div(class: 'w-56 flex items-center justify-center') do
            render PhlexUI::Select.new do
              render PhlexUI::Select::Input.new(value: "apple", id: "select-a-fruit")
              render PhlexUI::Select::Trigger.new do
                render PhlexUI::Select::Value.new(placeholder: 'Select a fruit', id: "select-a-fruit") { "Apple" }
              end
              render PhlexUI::Select::Content.new(outlet_id: "select-a-fruit") do
                render PhlexUI::Select::Group.new do
                  render PhlexUI::Select::Label.new { "Fruits" }
                  render PhlexUI::Select::Item.new(value: "apple") { "Apple" }
                  render PhlexUI::Select::Item.new(value: "orange") { "Orange" }
                  render PhlexUI::Select::Item.new(value: "banana") { "Banana" }
                  render PhlexUI::Select::Item.new(value: "watermelon") { "Watermelon" }
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

      Docs::ComponentStruct.new(name: "PhlexUI::Select", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/select.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Select::Trigger", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/select/trigger.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Select::Content", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/select/content.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Select::Label", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/select/label.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Select::Item", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/select/item.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Select::Group", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/select/group.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Select::Input", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/select/input.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Select::Value", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/select/value.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Select::Builder", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/select/builder.rb", built_using: :phlex)
    ]
  end
end
