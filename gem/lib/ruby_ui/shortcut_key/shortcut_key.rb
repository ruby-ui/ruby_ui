# frozen_string_literal: true

module RubyUI
  # A keyboard key, like shadcn's <Kbd>. Group several keys of a combo with
  # ShortcutKeyGroup.
  class ShortcutKey < Base
    def view_template(&)
      kbd(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "kbd"},
        class: [
          "pointer-events-none inline-flex h-5 w-fit min-w-5 select-none items-center justify-center gap-1",
          "rounded-sm bg-muted px-1 font-sans text-xs font-medium text-muted-foreground",
          "in-data-[slot=tooltip-content]:bg-background/20 in-data-[slot=tooltip-content]:text-background",
          "dark:in-data-[slot=tooltip-content]:bg-background/10",
          "[&_svg:not([class*='size-'])]:size-3"
        ].join(" ")
      }
    end
  end
end
