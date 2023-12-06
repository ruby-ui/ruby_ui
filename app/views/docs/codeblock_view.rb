# frozen_string_literal: true

class Docs::CodeblockView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Codeblock", description: "A component for displaying highlighted code.")

      render PhlexUI::Typography::H2.new { "Usage" }

      render Docs::VisualCodeExample.new(title: "With clipboard", context: self) do
        <<~RUBY
          code = <<~CODE 
              def hello_world
                puts "Hello, world!"
              end
            CODE
          div(class: 'w-full') do
            render PhlexUI::Codeblock.new(code, syntax: :ruby)
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Without clipboard", context: self) do
        <<~RUBY
          code = <<~CODE 
              def hello_world
                puts "Hello, world!"
              end
            CODE
          div(class: 'w-full') do
            render PhlexUI::Codeblock.new(code, syntax: :ruby, clipboard: false)
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Custom message", description: "Copy the code to see the message", context: self) do
        <<~RUBY
          code = <<~CODE 
              def hello_world
                puts "Hello, world!"
              end
            CODE
          div(class: 'w-full') do
            render PhlexUI::Codeblock.new(code, syntax: :ruby, clipboard_success: "Nice one!")
          end
        RUBY
      end

      render Docs::ComponentsTable.new(components)
    end
  end

  private

  def components
    [
      Docs::ComponentStruct.new(name: "ClipboardController", source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/clipboard_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "PhlexUI::Codeblock", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/codeblock.rb", built_using: :phlex),
    ]
  end
end
