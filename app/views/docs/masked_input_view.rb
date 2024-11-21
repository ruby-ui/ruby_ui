# frozen_string_literal: true

class Docs::MaskedInputView < ApplicationView
  def view_template
    component = "MaskedInput"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "MaskedInput", description: "Displays a form input field with applied mask.")

      Heading(level: 2) { "Usage" }

      Text do
        plain "For advanced usage, check out the "
        InlineLink(href: "https://beholdr.github.io/maska/v3", target: "_blank") { "Maska website" }
        plain "."
      end

      render Docs::VisualCodeExample.new(title: "Phone number", context: self) do
        <<~RUBY
          div(class: 'grid w-full max-w-sm items-center gap-1.5') do
            MaskedInput(data: {maska: "(##) #####-####"})
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Hex color code", context: self) do
        <<~RUBY
          div(class: 'grid w-full max-w-sm items-center gap-1.5') do
            MaskedInput(data: {maska: "!#HHHHHH", maska_tokens: "H:[0-9a-fA-F]"})
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "CPF / CNPJ", context: self) do
        <<~RUBY
          div(class: 'grid w-full max-w-sm items-center gap-1.5') do
            MaskedInput(data: {maska: "['###.###.###-##', '##.###.###/####-##']"})
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
