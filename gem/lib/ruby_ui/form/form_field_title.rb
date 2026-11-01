# frozen_string_literal: true

module RubyUI
  class FormFieldTitle < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    # Shares the field-label slot with FormFieldLabel, as in shadcn, so a
    # horizontal FormField stretches it the same way.
    def default_attrs
      {
        data: {slot: "field-label"},
        class: "flex w-fit items-center gap-2 text-sm leading-snug font-medium group-data-[disabled=true]/field:opacity-50"
      }
    end
  end
end
