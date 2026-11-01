# frozen_string_literal: true

module RubyUI
  class FormFieldGroup < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "field-group"},
        class: [
          "group/field-group @container/field-group flex w-full flex-col gap-7",
          "data-[slot=checkbox-group]:gap-3 *:data-[slot=field-group]:gap-4"
        ]
      }
    end
  end
end
