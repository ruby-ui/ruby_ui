# frozen_string_literal: true

class Views::Docs::Typography < Views::Base
  def view_template
    component = "Typography"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Typography", description: "Sensible defaults to use for text.")

      Components.Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "h1", context: self) do
        <<~RUBY
          Heading(level: 1) { "This is an H1 title" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "h2", context: self) do
        <<~RUBY
          Heading(level: 2) { "This is an H2 title" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "h3", context: self) do
        <<~RUBY
          Heading(level: 3) { "This is an H3 title" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "h4", context: self) do
        <<~RUBY
          Heading(level: 4) { "This is an H4 title" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "p", context: self) do
        <<~RUBY
          Text { "This is an P tag" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Inline Link", context: self) do
        <<~RUBY
          Text(class: 'text-center') do
            plain "Checkout our "
            InlineLink(href: docs_installation_path) { "installation instructions" }
            plain " to get started."
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "List", context: self) do
        <<~RUBY
          Components.TypographyList(items: [
              'Phlex is fast',
              'Phlex is easy to use',
              'Phlex is awesome',
            ])
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Numbered List", context: self) do
        <<~RUBY
          Components.TypographyList(items: [
              'Copy',
              'Paste',
              'Customize',
            ], numbered: true)
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Inline Code", context: self) do
        <<~RUBY
          InlineCode { "This is an inline code block" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Lead", context: self) do
        <<~RUBY
          Text(as: "p", size: "5", weight: "muted") { "A modal dialog that interrupts the user with important content and expects a response." }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Large", context: self) do
        <<~RUBY
          Text(size: "4", weight: "semibold") { "Are you sure absolutely sure?" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Small", context: self) do
        <<~RUBY
          Text(size: "sm") { "Email address" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Muted", context: self) do
        <<~RUBY
          Text(size: "2", class: "text-muted-foreground") { "Enter your email address." }
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
