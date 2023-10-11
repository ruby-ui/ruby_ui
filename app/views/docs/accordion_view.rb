# frozen_string_literal: true

class Docs::AccordionView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-8") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Accordion" }
        render Typography::P.new { "A vertically stacked set of interactive headings that each reveal a section of content." }
      end

      render Docs::Component.new do
        render Accordion.new do
          render AccordionItem.new(open: false) do
            render AccordionTrigger.new { "Is it accessbile?" }
            render AccordionContent.new do
              render Typography::P.new { "No not yet..." }
            end
          end
          render AccordionItem.new(open: false) do
            render AccordionTrigger.new { "Is it accessbile?" }
            render AccordionContent.new do
              render Typography::P.new { "No not yet..." }
            end
          end
        end 
      end
    end
  end
end
