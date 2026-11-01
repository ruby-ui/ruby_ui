# frozen_string_literal: true

module RubyUI
  class FormFieldHint < Base
    def view_template(&)
      p(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          slot: "field-description",
          ruby_ui__form_field_target: "hint"
        },
        class: [
          "empty:hidden text-left text-sm leading-normal font-normal text-muted-foreground",
          # shadcn's last:mt-0 nth-last-2:-mt-1, counting siblings as if an
          # empty FormFieldError (always rendered here, never in shadcn) were absent.
          # Right after a legend they step aside, so the legend rule wins as in shadcn.
          "[&:nth-last-child(1_of_:not([data-slot=field-error]:empty)):not([data-variant=legend]+*)]:mt-0",
          "[&:nth-last-child(2_of_:not([data-slot=field-error]:empty)):not([data-variant=legend]+*)]:-mt-1",
          "[[data-variant=legend]+&]:-mt-1.5",
          "[&>a]:underline [&>a]:underline-offset-4 [&>a:hover]:text-primary"
        ]
      }
    end
  end
end
