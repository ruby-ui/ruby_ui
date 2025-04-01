# frozen_string_literal: true

class Views::Docs::Accordion < Views::Base
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      component = "Accordion"
      render Docs::Header.new(title: component,
        description: "A vertically stacked set of interactive headings that each reveal a section of content.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        @@code = <<~RUBY
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
                  p(class: "font-medium") { "Can I use it with Rails?" }
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

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
