# frozen_string_literal: true

class Docs::TypographyView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Typography", description: "Sensible defaults to use for text.")

      TypographyH2 { "Usage" }

      render Docs::VisualCodeExample.new(title: "h1", context: self) do
        <<~RUBY
          TypographyH1 { "This is an H1 title" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "h2", context: self) do
        <<~RUBY
          TypographyH2 { "This is an H2 title" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "h3", context: self) do
        <<~RUBY
          TypographyH3 { "This is an H3 title" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "h4", context: self) do
        <<~RUBY
          TypographyH4 { "This is an H4 title" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "p", context: self) do
        <<~RUBY
          TypographyP { "This is an P tag" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Inline Link", context: self) do
        <<~RUBY
          TypographyP(class: 'text-center') do
            plain "Checkout our "
            TypographyInlineLink(href: helpers.docs_installation_path) { "installation instructions" }
            plain " to get started."
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "List", context: self) do
        <<~RUBY
          TypographyList(items: [
            'Phlex is fast',
            'Phlex is easy to use',
            'Phlex is awesome',
          ])
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Numbered List", context: self) do
        <<~RUBY
          TypographyList(items: [
            'Copy',
            'Paste',
            'Customize',
          ], numbered: true)
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Inline Code", context: self) do
        <<~RUBY
          TypographyInlineCode { "This is an inline code block" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Lead", context: self) do
        <<~RUBY
          TypographyLead { "A modal dialog that interrupts the user with important content and expects a response." }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Large", context: self) do
        <<~RUBY
          TypographyLarge { "Are you sure absolutely sure?" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Small", context: self) do
        <<~RUBY
          TypographySmall { "Email address" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Muted", context: self) do
        <<~RUBY
          TypographyMuted { "Enter your email address." }
        RUBY
      end

      render Docs::ComponentsTable.new(components)
    end
  end

  private

  def components
    [
      Docs::ComponentStruct.new(name: "TypographyH1", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/h1.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "TypographyH2", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/h2.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "TypographyH3", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/h3.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "TypographyH4", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/h4.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "TypographyP", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/p.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "TypographyInlineLink", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/inline_link.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "TypographyList", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/list.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "TypographyListItem", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/list_item.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "TypographyInlineCode", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/inline_code.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "TypographyLead", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/lead.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "TypographyLarge", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/large.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "TypographySmall", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/small.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "TypographyMuted", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/typography/muted.rb", built_using: :phlex)
    ]
  end
end
