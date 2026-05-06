# frozen_string_literal: true

module RubyUI
  class ComboboxListGroup < Base
    LABEL_CLASSES = "before:content-[attr(label)] before:px-2 before:py-1.5 before:text-xs before:font-medium before:text-muted-foreground before:not-italic"

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: ["hidden has-[label:not(.hidden)]:flex flex-col py-1 gap-1 border-b", LABEL_CLASSES],
        role: "group"
      }
    end
  end
end
