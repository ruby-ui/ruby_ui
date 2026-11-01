# frozen_string_literal: true

class Views::Docs::Accordion < Views::Base
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      component = "Accordion"
      render Docs::Header.new(title: component,
        description: "A vertically stacked set of interactive headings that each reveal a section of content.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", description: "Built on native <details> and <summary>: no JavaScript. One item opens at a time.", context: self) do
        <<~RUBY
          Accordion(class: "max-w-lg") do
            AccordionItem do
              AccordionTrigger { "What is RubyUI?" }
              AccordionContent { "RubyUI is a UI component library for Ruby devs who want to build better, faster." }
            end
            AccordionItem do
              AccordionTrigger { "Can I use it with Rails?" }
              AccordionContent { "Yes. RubyUI is pure Ruby and works great with Rails. It's a Ruby gem that you can install into your Rails app." }
            end
            AccordionItem do
              AccordionTrigger { "Does it need JavaScript?" }
              AccordionContent { "No. The browser opens and closes each item, and find-in-page reveals a closed item that holds the match." }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Multiple", description: "Pass multiple: true to let several items stay open.", context: self) do
        <<~RUBY
          Accordion(multiple: true, class: "max-w-lg") do
            AccordionItem(open: true) do
              AccordionTrigger { "Notifications" }
              AccordionContent { "Choose how you want to be notified about updates." }
            end
            AccordionItem(open: true) do
              AccordionTrigger { "Privacy" }
              AccordionContent { "Control who can see your profile and activity." }
            end
            AccordionItem do
              AccordionTrigger { "Billing" }
              AccordionContent { "Manage your plan and payment methods." }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", description: "A disabled item can't be opened and leaves the tab order. Pass disabled: true to the Accordion to disable every item.", context: self) do
        <<~RUBY
          Accordion(class: "max-w-lg") do
            AccordionItem do
              AccordionTrigger { "Available" }
              AccordionContent { "This item opens as usual." }
            end
            AccordionItem(disabled: true) do
              AccordionTrigger { "Unavailable" }
              AccordionContent { "This item is disabled." }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Heading level", description: "Each trigger is a heading (h3 by default). Pick the level that fits the page outline.", context: self) do
        <<~RUBY
          Accordion(class: "max-w-lg") do
            AccordionItem do
              AccordionTrigger(level: 2) { "Shipping" }
              AccordionContent { "Orders ship within two business days." }
            end
            AccordionItem do
              AccordionTrigger(level: 2) { "Returns" }
              AccordionContent { "Returns are accepted within 30 days." }
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
