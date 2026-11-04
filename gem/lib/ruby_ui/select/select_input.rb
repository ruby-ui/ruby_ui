# frozen_string_literal: true

module RubyUI
  # The value carrier, like Base UI's hidden input: a real input (so name:,
  # value: and required: work with forms and FormField) kept out of sight, the
  # tab order and the accessibility tree.
  class SelectInput < Base
    def view_template
      input(**attrs)
    end

    private

    def default_attrs
      {
        tabindex: "-1",
        autocomplete: "off",
        aria: {hidden: "true"},
        class: "sr-only",
        data: {
          ruby_ui__select_target: "input",
          ruby_ui__form_field_target: "input",
          action: "change->ruby-ui--form-field#onChange invalid->ruby-ui--form-field#onInvalid invalid->ruby-ui--select#focusTrigger"
        }
      }
    end
  end
end
