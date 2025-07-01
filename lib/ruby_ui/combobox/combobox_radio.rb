# frozen_string_literal: true

module RubyUI
  class ComboboxRadio < Base
    def view_template
      input(type: "radio", **attrs)
    end

    private

    def default_attrs
      {
        class: [
          "aspect-square h-4 w-4 rounded-full border border-primary accent-primary text-primary shadow",
          "focus:outline-none",
          "focus-visible:ring-1 focus-visible:ring-ring",
          "disabled:cursor-not-allowed disabled:opacity-50",
          "checked:bg-primary checked:text-primary-foreground",
          "aria-disabled:cursor-not-allowed aria-disabled:opacity-50 aria-disabled:pointer-events-none"
        ],
        data: {
          ruby_ui__combobox_target: "input",
          ruby_ui__form_field_target: "input",
          action: %w[
            ruby-ui--combobox#inputChanged
            input->ruby-ui--form-field#onInput
            invalid->ruby-ui--form-field#onInvalid
          ]
        }
      }
    end
  end
end
