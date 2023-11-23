# frozen_string_literal: true

class Docs::AccordionView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render PhlexUI::Typography::H1.new { "Accordion" }
        render PhlexUI::Typography::P.new { "A vertically stacked set of interactive headings that each reveal a section of content." }
      end

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          render PhlexUI::Accordion.new do |accordion|
            accordion.add_item("Item 1", "Content 1")
            accordion.add_item("Item 2", "Content 2")
            accordion.add_item("Item 3", "Content 3")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Custom Design", context: self) do
        <<~RUBY
          render PhlexUI::Accordion.new(class: 'space-y-1') do
            render PhlexUI::Accordion::Item.new(
                    class!:
                      "data-[accordion-open-value=true]:bg-muted hover:bg-muted rounded-lg pb-3",
                    rotate_icon: 135
                  ) do
              render PhlexUI::Accordion::Trigger.new(class!: "w-full rounded-lg") do
                div(class: "p-6 pb-3 pl-16 relative text-left") do
                  render PhlexUI::Accordion::Icon.new(class: "absolute left-6 top-6") do
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
                  p(class: "font-medium") { "What is PhlexUI?" }
                end
              end

              render PhlexUI::Accordion::Content.new do
                p(class: "pl-16 pr-4 pb-4 text-muted-foreground") do
                  "PhlexUI is a UI component library for Ruby devs who want to build better, faster."
                end
              end
            end

            render PhlexUI::Accordion::Item.new(
                    class!:
                      "data-[accordion-open-value=true]:bg-muted hover:bg-muted rounded-lg pb-3",
                    rotate_icon: 135
                  ) do
              render PhlexUI::Accordion::Trigger.new(class!: "w-full rounded-lg") do
                div(class: "p-6 pb-3 pl-16 relative text-left") do
                  render PhlexUI::Accordion::Icon.new(class: "absolute left-6 top-6") do
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

              render PhlexUI::Accordion::Content.new do
                p(class: "pl-16 pr-4 pb-4 text-muted-foreground") do
                  "Yes, PhlexUI is pure Ruby and works great with Rails. It's a Ruby gem that you can install into your Rails app."
                end
              end
            end
          end
        RUBY
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
