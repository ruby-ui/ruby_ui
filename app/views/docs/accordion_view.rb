# frozen_string_literal: true

class Docs::AccordionView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Accordion", description: "A vertically stacked set of interactive headings that each reveal a section of content.")

      TypographyH2 { "Usage" }

      render Docs::VisualCodeExample.new(title: "Custom Design", context: self) do
        <<~RUBY
          Accordion(class: 'space-y-1') do
            AccordionItem(
                    class!:
                      "data-[accordion-open-value=true]:bg-muted hover:bg-muted rounded-lg pb-3",
                    rotate_icon: 135
                  ) do
              AccordionTrigger(class!: "w-full rounded-lg") do
                div(class: "p-6 pb-3 pl-16 relative text-left") do
                  AccordionIcon(class: "absolute left-6 top-6") do
                    svg(
                      xmlns: "http://www.w3.org/2000/svg",
                      fill: "none",
                      viewbox: "0 0 24 24",
                      stroke_width: "1.5",
                      stroke: "currentColor",
                      class: "w-6 h-6"
                    ) do |s|
                      s.path(
                        stroke_linecap: "round",
                        stroke_linejoin: "round",
                        d: "M12 9v6m3-3H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z"
                      )
                    end
                  end
                  p(class: "font-medium") { "What is RBUI?" }
                end
              end

              AccordionContent do
                p(class: "pl-16 pr-4 pb-4 text-muted-foreground") do
                  "RBUI is a UI component library for Ruby devs who want to build better, faster."
                end
              end
            end

            AccordionItem(
                    class!:
                      "data-[accordion-open-value=true]:bg-muted hover:bg-muted rounded-lg pb-3",
                    rotate_icon: 135
                  ) do
              AccordionTrigger(class!: "w-full rounded-lg") do
                div(class: "p-6 pb-3 pl-16 relative text-left") do
                  AccordionIcon(class: "absolute left-6 top-6") do
                    svg(
                      xmlns: "http://www.w3.org/2000/svg",
                      fill: "none",
                      viewbox: "0 0 24 24",
                      stroke_width: "1.5",
                      stroke: "currentColor",
                      class: "w-6 h-6"
                    ) do |s|
                      s.path(
                        stroke_linecap: "round",
                        stroke_linejoin: "round",
                        d: "M12 9v6m3-3H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z"
                      )
                    end
                  end
                  p(class: "font-medium") { "Can I use it with Rails?" }
                end
              end

              AccordionContent do
                p(class: "pl-16 pr-4 pb-4 text-muted-foreground") do
                  "Yes, RBUI is pure Ruby and works great with Rails. It's a Ruby gem that you can install into your Rails app."
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
      Docs::ComponentStruct.new(name: "AccordionController", source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/accordion_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "Accordion", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/accordion.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "AccordionItem", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/accordion/item.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "AccordionTrigger", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/accordion/item.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "AccordionContent", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/accordion/content.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "AccordionIcon", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/accordion/icon.rb", built_using: :phlex)
    ]
  end
end
