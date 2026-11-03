# frozen_string_literal: true

module RubyUI
  # A row below the code, for a caption or extra actions.
  class CodeblockFooter < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "code-block-footer"},
        class: [
          "flex min-w-0 shrink-0 items-center gap-2 px-4 pb-4 text-muted-foreground",
          "group-data-[size=sm]/code-block:px-3 group-data-[size=sm]/code-block:pb-3"
        ]
      }
    end
  end
end
