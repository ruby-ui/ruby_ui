# frozen_string_literal: true

class Docs::AccordionView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Accordion",
        description: "A vertically stacked set of interactive headings that each reveal a section of content.")

      TypographyH2 { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          div(class: "w-full") do
              Accordion do
                AccordionItem do
                  AccordionTrigger do
                    p(class: "font-medium") { "What is PhlexUI?" }
                    AccordionIcon()
                  end

                  AccordionContent do
                    p(class: "text-sm pb-4") do
                      "PhlexUI is a UI component library for Ruby devs who want to build better, faster."
                    end
                  end
                end
              end

              Accordion do
                AccordionItem do
                  AccordionTrigger do
                    p(class: "font-medium") { "Can I use it with Rils?" }
                    AccordionIcon()
                  end

                  AccordionContent do
                    p(class: "text-sm pb-4") do
                      "Yes, PhlexUI is pure Ruby and works great with Rails. It's a Ruby gem that you can install into your Rails app."
                    end
                  end
                end
              end
            end
        RUBY
      end

      render Docs::ComponentsTable.new(components)
    end
  end

  private

  def components
    [
      Docs::ComponentStruct.new(name: "AccordionController",
        source: "https://github.com/PhlexUI/phlex_ui/blob/v1/lib/rbui/accordion/accordion_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "Accordion",
        source: "https://github.com/PhlexUI/phlex_ui/blob/v1/lib/rbui/accordion/accordion.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "AccordionItem",
        source: "https://github.com/PhlexUI/phlex_ui/blob/v1/lib/rbui/accordion/accordion_item.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "AccordionTrigger",
        source: "https://github.com/PhlexUI/phlex_ui/blob/v1/lib/rbui/accordion/accordion_trigger.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "AccordionContent",
        source: "https://github.com/PhlexUI/phlex_ui/blob/v1/lib/rbui/accordion/accordion_content.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "AccordionIcon",
        source: "https://github.com/PhlexUI/phlex_ui/blob/v1/lib/rbui/accordion/accordion_icon.rb", built_using: :phlex)
    ]
  end
end
