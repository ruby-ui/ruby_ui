# frozen_string_literal: true

module RubyUI
  # shadcn has no CheckboxGroup: its checkbox groups are a
  # FieldGroup with data-slot="checkbox-group". RubyUI keeps a component for
  # the group-level `required` (at least one checked), which neither shadcn
  # nor native HTML provides.
  class CheckboxGroup < Base
    def initialize(required: false, **user_attrs)
      @required = required
      super(**user_attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        role: "group",
        data: {
          slot: "checkbox-group",
          controller: "ruby-ui--checkbox-group",
          required: (true if @required)
        },
        class: "group/field-group @container/field-group flex w-full flex-col gap-3"
      }
    end
  end
end
