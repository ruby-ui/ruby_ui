# frozen_string_literal: true

class Docs::AccordionView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-8") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Accordion" }
        render Typography::P.new { "A vertically stacked set of interactive headings that each reveal a section of content." }
      end

      render Docs::VisualCodeExample.new do
        render Accordion.new do
          render AccordionItem.new(open: false) do
            render AccordionTrigger.new { "Is it accessbile?" }
            render AccordionContent.new do
              render Typography::P.new { "No not yet..." }
            end
          end
          render AccordionItem.new(open: false) do
            render AccordionTrigger.new { "Is it styled?" }
            render AccordionContent.new do
              render Typography::P.new { "Yes. It comes with default styles that matches the other components' aesthetic." }
            end
          end
          render AccordionItem.new(open: false) do
            render AccordionTrigger.new { "Is it animated?" }
            render AccordionContent.new do
              render Typography::P.new { "Yes. Using Motion One" }
            end
          end
        end 
      end
    end
  end
end
