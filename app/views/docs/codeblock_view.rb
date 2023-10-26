# frozen_string_literal: true

class Docs::CodeblockView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Codeblock" }
        render Typography::P.new { "A component for displaying highlighted code." }
      end

      render Docs::VisualCodeExample.new(context: self) do
        <<~RUBY
          render Codeblock.new do
            <<~CODE 
              def hello_world
                puts "Hello, world!"
              end
            CODE
          end
        RUBY
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
