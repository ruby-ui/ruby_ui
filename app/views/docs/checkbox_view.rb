# frozen_string_literal: true

class Docs::CheckboxView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render PhlexUI::Typography::H1.new { "Checkbox" }
        render PhlexUI::Typography::P.new { "A control that allows the user to toggle between checked and not checked." }
      end

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          div(class: 'flex items-center space-x-3') do
            render PhlexUI::Checkbox.new(id: 'terms')
            label(for: 'terms', class: 'text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70') { "Accept terms and conditions" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Checked", context: self) do
        <<~RUBY
          div(class: "items-top flex space-x-3") do
            render PhlexUI::Checkbox.new(id: 'terms1', checked: true)
            div(class: "grid gap-1.5 leading-none") do
              label(
                for: "terms1",
                class:
                  "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
              ) { " Accept terms and conditions " }
              p(class: "text-sm text-muted-foreground") { " You agree to our Terms of Service and Privacy Policy." }
            end
          end
        RUBY
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
