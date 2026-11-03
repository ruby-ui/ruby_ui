# frozen_string_literal: true

module RubyUI
  class FormFieldSet < Base
    def view_template(&)
      fieldset(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "field-set"},
        class: "flex flex-col gap-6 has-[>[data-slot=checkbox-group]]:gap-3 has-[>[data-slot=radio-group]]:gap-3"
      }
    end
  end
end
