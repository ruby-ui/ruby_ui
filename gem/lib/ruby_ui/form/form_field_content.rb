# frozen_string_literal: true

module RubyUI
  class FormFieldContent < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "field-content"},
        class: "group/field-content flex flex-1 flex-col gap-1 leading-snug"
      }
    end
  end
end
