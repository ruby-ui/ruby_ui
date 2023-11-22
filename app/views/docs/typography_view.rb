# frozen_string_literal: true

class Docs::TypographyView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render PhlexUI::Typography::H1.new { "Typography" }
        render PhlexUI::Typography::P.new { "Sensible defaults to use for text." }
      end

      render Docs::VisualCodeExample.new(title: "h1", context: self) do
        <<~RUBY
          render PhlexUI::Typography::H1.new { "This is an H1 title" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "h2", context: self) do
        <<~RUBY
          render PhlexUI::Typography::H2.new { "This is an H2 title" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "h3", context: self) do
        <<~RUBY
          render PhlexUI::Typography::H3.new { "This is an H3 title" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "h4", context: self) do
        <<~RUBY
          render PhlexUI::Typography::H4.new { "This is an H4 title" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "p", context: self) do
        <<~RUBY
          render PhlexUI::Typography::P.new { "This is an P tag" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "List", context: self) do
        <<~RUBY
          render PhlexUI::Typography::List.new(items: [
            'Phlex is fast',
            'Phlex is easy to use',
            'Phlex is awesome',
          ])
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Numbered List", context: self) do
        <<~RUBY
          render PhlexUI::Typography::List.new(items: [
            'Copy',
            'Paste',
            'Customize',
          ], numbered: true)
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Inline Code", context: self) do
        <<~RUBY
          render PhlexUI::Typography::InlineCode.new { "This is an inline code block" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Lead", context: self) do
        <<~RUBY
          render PhlexUI::Typography::Lead.new { "A modal dialog that interrupts the user with important content and expects a response." }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Large", context: self) do
        <<~RUBY
          render PhlexUI::Typography::Large.new { "Are you sure absolutely sure?" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Small", context: self) do
        <<~RUBY
          render PhlexUI::Typography::Small.new { "Email address" }
        RUBY
      end
      
      render Docs::VisualCodeExample.new(title: "Muted", context: self) do
        <<~RUBY
          render PhlexUI::Typography::Muted.new { "Enter your email address." }
        RUBY
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
