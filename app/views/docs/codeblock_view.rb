# frozen_string_literal: true

class Docs::CodeblockView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render PhlexUI::Typography::H1.new { "Codeblock" }
        render PhlexUI::Typography::P.new { "A component for displaying highlighted code." }
      end

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

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
