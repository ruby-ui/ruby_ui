# frozen_string_literal: true

class Docs::InputView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Input" }
        render Typography::P.new { "Displays a form input field or a component that looks like an input field." }
      end

      render Docs::VisualCodeExample.new(title: 'Email', context: self) do
        <<~RUBY
          div(class: 'grid w-full max-w-sm items-center gap-1.5') do
            render Input.new(type: "email", placeholder: "Email")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'File', context: self) do
        <<~RUBY
          div(class: "grid w-full max-w-sm items-center gap-1.5") do
            render Label.new(for: "picture") { "Picture" }
            render Input.new(type: "file", id: "picture")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Disabled', context: self) do
        <<~RUBY
          div(class: 'grid w-full max-w-sm items-center gap-1.5') do
            render Input.new(disabled: true, type: "email", placeholder: "Email")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'With label', context: self) do
        <<~RUBY
          div(class: 'grid w-full max-w-sm items-center gap-1.5') do
            render Label.new(for: "email") { "Email" }
            render Input.new(type: "email", placeholder: "Email", id: "email")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'With button', context: self) do
        <<~RUBY
          div(class: 'flex w-full max-w-sm items-center space-x-2') do
            render Input.new(type: "email", placeholder: "Email")
            render Button.new { "Subscribe" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Form', context: self) do
        <<~RUBY
          render Form.new(class: 'w-full max-w-sm') do
            render FormSpacer.new do
              render FormItem.new do
                render Label.new(for: "username") { "Username" }
                render Input.new(type: "string", placeholder: "Username", id: "username")
                render Hint.new { "We'll never share your email with anyone else." }
              end
              render Button.new(type: "submit") { "Submit" }
            end
          end
        RUBY
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
