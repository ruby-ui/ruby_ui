# frozen_string_literal: true

module RubyUI
  # The panel of an AccordionItem. Attributes and classes go to the inner
  # element, like shadcn's AccordionContent.
  class AccordionContent < Base
    def view_template(&)
      div(data: {slot: "accordion-content"}, class: "text-sm") do
        div(**attrs, &)
      end
    end

    private

    def default_attrs
      {
        class: "pt-0 pb-4 [&_a]:underline [&_a]:underline-offset-3 [&_a]:hover:text-foreground [&_p:not(:last-child)]:mb-4"
      }
    end
  end
end
