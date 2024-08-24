# frozen_string_literal: true

module Rbui
  class AccordionPreview < Lookbook::Preview
    ITEMS = [
      {title: "Item 1", content: "Content 1"},
      {title: "Item 2", content: "Content 2"},
      {title: "Item 3", content: "Content 3"}
    ]

    # Default Accordion
    # ---------------
    def default
      render(TestView.new) do
        Accordion do
          ITEMS.each do |it|
            AccordionItem do
              AccordionTrigger { AccordionDefaultTrigger { AccordionIcon { it[:title] } } }
              AccordionContent { AccordionDefaultContent { it[:content] } }
            end
          end
        end
      end
    end
  end
end
