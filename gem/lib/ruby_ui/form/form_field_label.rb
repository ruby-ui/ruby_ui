# frozen_string_literal: true

module RubyUI
  class FormFieldLabel < Base
    def view_template(&)
      label(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "field-label"},
        class: [
          "empty:hidden flex w-fit items-center gap-2 text-sm leading-snug font-medium select-none",
          "group-data-[disabled=true]/field:opacity-50",
          "peer-disabled:cursor-not-allowed peer-disabled:opacity-50",
          "peer-aria-disabled:cursor-not-allowed peer-aria-disabled:opacity-50 peer-aria-disabled:pointer-events-none",
          # A label wrapping a FormField becomes a selectable card (shadcn's
          # has-data-checked maps to native :checked).
          "has-[>[data-slot=field]]:w-full has-[>[data-slot=field]]:flex-col has-[>[data-slot=field]]:rounded-md has-[>[data-slot=field]]:border *:data-[slot=field]:p-3",
          "has-[>[data-slot=field]]:not-has-[:disabled,[data-disabled]]:hover:bg-muted/50",
          "has-[>[data-slot=field]]:has-[:focus-visible]:border-ring has-[>[data-slot=field]]:has-[:focus-visible]:ring-3 has-[>[data-slot=field]]:has-[:focus-visible]:ring-ring/50",
          "has-checked:border-primary/30 has-checked:bg-primary/5 dark:has-checked:border-primary/20 dark:has-checked:bg-primary/10"
        ]
      }
    end
  end
end
