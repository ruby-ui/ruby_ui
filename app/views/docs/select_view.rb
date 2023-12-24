# frozen_string_literal: true

class Docs::SelectView < ApplicationView
  Person = Struct.new(:name, :id)

  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Select", description: "Displays a list of options for the user to pick from—triggered by a button.")

      render PhlexUI::Typography::H2.new { "Usage" }

      render Docs::VisualCodeExample.new(title: 'Select with object (With Builder)', context: self) do
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

      render Docs::VisualCodeExample.new(title: 'Select with text (With Builder)', context: self) do
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

      render Docs::VisualCodeExample.new(title: 'Select (Deconstructed)', context: self) do
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
    end
  end
end
