# frozen_string_literal: true

module RubyUI
  # The file name (and an optional icon) in a CodeblockHeader.
  class CodeblockTitle < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "code-block-title"},
        class: [
          "min-w-0 truncate font-sans text-sm font-medium text-foreground",
          "[&_svg]:pointer-events-none [&_svg]:inline-block [&_svg]:align-middle *:[svg]:me-1.5 [&_svg:not([class*='size-'])]:size-4",
          "group-data-[variant=destructive]/code-block:text-destructive",
          "group-data-[size=sm]/code-block:text-xs group-data-[size=sm]/code-block:[&_svg:not([class*='size-'])]:size-3.5"
        ]
      }
    end
  end
end
