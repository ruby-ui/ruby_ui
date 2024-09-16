# frozen_string_literal: true

module RBUI
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
        div(class: "w-96") do
          Accordion do
            ITEMS.each do |it|
              AccordionItem do
                AccordionTrigger do
                  p(class: "font-medium") { it[:title] }
                  AccordionIcon()
                end

                AccordionContent do
                  p(class: "text-sm pb-4") do
                    it[:content]
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
