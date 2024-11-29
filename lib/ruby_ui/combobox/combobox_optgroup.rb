# frozen_string_literal: true

module RubyUI
  class ComboboxOptgroup < Base
    LABEL_CLASSES = "before:content-[attr(label)] before:px-2 before:py-1.5 before:text-xs before:font-medium before:text-muted-foreground before:not-italic"

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: ["hidden has-[div:not(.hidden)]:flex flex-col gap-1", LABEL_CLASSES],
        role: "group"
      }
    end
  end
end
