# frozen_string_literal: true

module RubyUI
  class AccordionContent < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          rbui__accordion_target: "content"
        },
        class: "overflow-y-hidden",
        style: "height: 0px;"
      }
    end
  end
end
