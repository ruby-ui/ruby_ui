# frozen_string_literal: true

module RubyUI
  # A row above the code: a CodeblockTitle and, on the right, CodeblockActions.
  class CodeblockHeader < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "code-block-header"},
        class: [
          "flex min-w-0 shrink-0 items-center gap-2 px-4 pt-4 text-muted-foreground *:has-[>[data-slot=code-block-title]]:min-w-0",
          "group-data-[variant=destructive]/code-block:text-destructive",
          "group-data-[size=sm]/code-block:px-3 group-data-[size=sm]/code-block:pt-3"
        ]
      }
    end
  end
end
