# frozen_string_literal: true

class Views::Docs::Codeblock < Views::Base
  def view_template
    component = "Codeblock"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Codeblock", description: "Displays a block of code with syntax highlighting and a copy button.")

      Heading(level: 2) { "Setup" }

      Text { "Syntax colors come from CodeblockTheme, Rouge's GitHub theme in light and dark. Render it once in your layout's <head>: render RubyUI::CodeblockTheme.new" }

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          code = <<~CODE
            def hello_world
              puts "Hello, world!"
            end
          CODE

          Codeblock(code, syntax: :ruby)
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Without copy button", context: self) do
        <<~RUBY
          Codeblock("bin/rails generate ruby_ui:component Codeblock", syntax: :shell, clipboard: false)
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Line numbers", context: self) do
        <<~RUBY
          code = <<~CODE
            class User < ApplicationRecord
              has_many :posts
              validates :email, presence: true
            end
          CODE

          Codeblock(code, syntax: :ruby, line_numbers: true, start_line: 10)
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Header and footer", context: self) do
        <<~RUBY
          code = <<~CODE
            Rails.application.routes.draw do
              resources :posts
            end
          CODE

          Codeblock do
            CodeblockHeader do
              CodeblockTitle { "config/routes.rb" }
              CodeblockActions do
                CodeblockCopyButton(value: code)
              end
            end
            CodeblockContent(code, syntax: :ruby)
            CodeblockFooter { "Ruby" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Diff", description: "Mark lines with variant: :added, :removed or :highlighted.", context: self) do
        <<~RUBY
          Codeblock do
            CodeblockActions do
              CodeblockCopyButton(value: %(gem 'ruby_ui', '~> 1.6'))
            end
            CodeblockContent do
              CodeblockLine { "source 'https://rubygems.org'" }
              CodeblockLine()
              CodeblockLine(variant: :removed) { "gem 'ruby_ui', '~> 1.5'" }
              CodeblockLine(variant: :added) { "gem 'ruby_ui', '~> 1.6'" }
              CodeblockLine(variant: :highlighted) { "gem 'rouge'" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Wrap", description: "Long lines wrap instead of scrolling sideways.", context: self) do
        <<~RUBY
          code = "curl -fsSL https://example.com/install.sh | bash -s -- --prefix=/usr/local --with-extra-options --verbose"

          Codeblock(code, syntax: :shell, wrap: true)
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Small", context: self) do
        <<~RUBY
          Codeblock("bundle add ruby_ui --group development --require false", syntax: :shell, size: :sm)
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Destructive", context: self) do
        <<~RUBY
          code = <<~CODE
            NameError: uninitialized constant User
              app/controllers/users_controller.rb:4:in 'index'
          CODE

          Codeblock(variant: :destructive) do
            CodeblockHeader { CodeblockTitle { "Error" } }
            CodeblockContent(code)
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Custom copy message", description: "Copy the code to hear the message with a screen reader.", context: self) do
        <<~RUBY
          Codeblock("puts 'Hello'", syntax: :ruby, clipboard_success: "Nice one!")
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
