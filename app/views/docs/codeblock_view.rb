# frozen_string_literal: true

class Docs::CodeblockView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-8") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Codeblock" }
        render Typography::P.new { "A component for displaying highlighted code." }
      end

      code_example = <<~RUBY
        render Codeblock.new do
          <<~CODE 
            def hello_world
              puts "Hello, world!"
            end
          CODE
        end
      RUBY
      render Docs::VisualCodeExample.new(code: code_example) do
        eval(code_example)
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
