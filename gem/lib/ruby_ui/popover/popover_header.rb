# frozen_string_literal: true

module RubyUI
  # Groups PopoverTitle and PopoverDescription at the top of the content.
  class PopoverHeader < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "popover-header"},
        class: "flex flex-col gap-1 text-sm"
      }
    end
  end
end
