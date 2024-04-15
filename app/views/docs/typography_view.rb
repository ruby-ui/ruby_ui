# frozen_string_literal: true

class Docs::TypographyView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Typography", description: "Sensible defaults to use for text.")

      render PhlexUI::Typography::H2.new { "Usage" }

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

      render Docs::VisualCodeExample.new(title: "Inline Link", context: self) do
        <<~RUBY
          render PhlexUI::Typography::P.new(class: 'text-center') do
            plain "Checkout our "
            render PhlexUI::Typography::InlineLink.new(href: helpers.docs_installation_path) { "installation instructions" }
            plain " to get started."
          end
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

      render Docs::ComponentsTable.new(components)
    end
  end

  private

  def components
    [
      Docs::ComponentStruct.new(name: "PhlexUI::Typography::H1", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/h1.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Typography::H2", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/h2.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Typography::H3", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/h3.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Typography::H4", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/h4.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Typography::P", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/p.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Typography::InlineLink", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/inline_link.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Typography::List", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/list.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Typography::ListItem", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/list_item.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Typography::InlineCode", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/inline_code.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Typography::Lead", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/lead.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Typography::Large", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/large.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Typography::Small", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/small.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Typography::Muted", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/muted.rb", built_using: :phlex)
    ]
  end
end
