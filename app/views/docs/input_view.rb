# frozen_string_literal: true

class Docs::InputView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Input", description: "Displays a form input field or a component that looks like an input field.")

      TypographyH2 { "Usage" }

      render Docs::VisualCodeExample.new(title: "Email", context: self) do
        <<~RUBY
          div(class: 'grid w-full max-w-sm items-center gap-1.5') do
            Input(type: "email", placeholder: "Email")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "File", context: self) do
        <<~RUBY
          div(class: "grid w-full max-w-sm items-center gap-1.5") do
            label(for: "picture") { "Picture" }
            Input(type: "file", id: "picture")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          div(class: 'grid w-full max-w-sm items-center gap-1.5') do
            Input(disabled: true, type: "email", placeholder: "Email")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With label", context: self) do
        <<~RUBY
          div(class: 'grid w-full max-w-sm items-center gap-1.5') do
            label(for: "email1") { "Email" }
            Input(type: "email", placeholder: "Email", id: "email1")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With button", context: self) do
        <<~RUBY
          div(class: 'flex w-full max-w-sm items-center space-x-2') do
            Input(type: "email", placeholder: "Email")
            Button { "Subscribe" }
          end
        RUBY
      end

      render Docs::ComponentsTable.new(components)
    end
  end

  private

  def components
    [
      Docs::ComponentStruct.new(name: "InputController", source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/input_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "Input", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/input.rb", built_using: :phlex)
    ]
  end
end
