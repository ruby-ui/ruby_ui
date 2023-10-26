# frozen_string_literal: true

class Docs::TypographyView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Typography" }
        render Typography::P.new { "Sensible defaults to use for text." }
      end

      render Docs::VisualCodeExample.new(title: "h1", description: "This is an h1 title", context: self) do
        <<~RUBY
          render Typography::H1.new { "This is an H1 title" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "h2", description: "This is an h2 title", context: self) do
        <<~RUBY
          render Typography::H2.new { "This is an H2 title" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "h3", description: "This is an h3 title", context: self) do
        <<~RUBY
          render Typography::H3.new { "This is an H3 title" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "h4", description: "This is an h4 title", context: self) do
        <<~RUBY
          render Typography::H4.new { "This is an H4 title" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "p", description: "This is an p title", context: self) do
        <<~RUBY
          render Typography::P.new { "This is an P tag" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "List", description: "This is a list", context: self) do
        <<~RUBY
          render Typography::List.new(items: [
            'Phlex is fast',
            'Phlex is easy to use',
            'Phlex is awesome',
          ])
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Inline Code", description: "This is an inline code block", context: self) do
        <<~RUBY
          render Typography::InlineCode.new { "This is an inline code block" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Lead", context: self) do
        <<~RUBY
          render Typography::Lead.new { "A modal dialog that interrupts the user with important content and expects a response." }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Large", context: self) do
        <<~RUBY
          render Typography::Large.new { "Are you sure absolutely sure?" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Small", context: self) do
        <<~RUBY
          render Typography::Small.new { "Email address" }
        RUBY
      end
      
      render Docs::VisualCodeExample.new(title: "Muted", context: self) do
        <<~RUBY
          render Typography::Muted.new { "Enter your email address." }
        RUBY
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
